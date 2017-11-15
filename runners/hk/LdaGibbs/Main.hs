module Main where

import qualified Data.Vector.Unboxed as U
import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime)
import           Control.Monad (forM_, when)
import           System.Environment (getArgs)
import           System.Directory (doesFileExist, removeFile)
    
import           Utils (SamplerKnobs(..),
                        Sampler, oneLine,
                        timeJags, gibbsSweep,
                        timeHakaru)
import           News (getNews, SingletonType(..))
import           LdaGibbs.Prog

main = do
  [inputs_path, outputs_path] <- getArgs
  (w,doc,zs) <- fst <$> getNews inputs_path SingleDoc Nothing [0..]
  g <- MWC.createSystemRandom                      -- ^ this retrieves everything
  b <- doesFileExist outputs_path
  when b (removeFile outputs_path)
  let numTopics = U.maximum zs + 1
  trial <- oneLine <$> hakaru g numTopics w doc ldaKnobs
  appendFile outputs_path trial

ldaKnobs = Knobs { minSeconds = 10
                 , stepSeconds = 0.5
                 , minSweeps = 100
                 , stepSweeps = 10 }

type LDASampler = Int ->          -- number of topics
                  U.Vector Int -> -- words array
                  U.Vector Int -> -- doc index of each word
                  Sampler  
                  
hakaru :: MWC.GenIO -> LDASampler
hakaru g numTopics w doc knobs = do
    let numWords   = U.maximum w + 1
        numDocs    = U.last doc
        topicPrior = array numTopics (const 1)
        wordPrior  = array numWords  (const 1)
        update z   = prog topicPrior wordPrior numDocs w doc z
    time0 <- getCurrentTime
    zs <- U.replicateM numDocs (MWC.uniformR (0, numTopics - 1) g)
    timeHakaru time0 (gibbsSweep update g) zs knobs
