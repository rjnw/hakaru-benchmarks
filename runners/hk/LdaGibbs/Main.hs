module Main where

import qualified Data.Vector.Unboxed as U
import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime)
import           Control.Monad (replicateM_)
import           System.Environment (getArgs)
import           System.Directory (doesFileExist, removeFile)
import           System.FilePath ((</>))
    
import           Utils (SamplerKnobs(..), Sampler,
                        oneLine, every, timeJags,
                        gibbsSweep, freshFile, timeHakaru)
import           News (getNews, SingletonType(..))
import           LdaGibbs.Prog2

main = do
  [inputs_path, outputs_dir] <- getArgs
  (w,doc,zs) <- fst <$> getNews inputs_path SingleDoc Nothing [0..]
  g <- MWC.createSystemRandom                      -- ^ retrieves everything
  let numTopics = U.maximum zs + 1
      numDocs   = U.length zs
      numTrials = 10
      fname     = show numTopics ++ "-" ++ show numDocs
      benchmark_dir = outputs_dir </> "LdaGibbs"
  hkfile <- freshFile (benchmark_dir </> "hk") fname
  replicateM_ numTrials $ do
    trial <- oneLine <$> hakaru g numTopics numDocs w doc ldaKnobs
    appendFile hkfile trial

ldaKnobs = Knobs { minSeconds = 10
                 , stepSeconds = 0.5
                 , minSweeps = 2
                 , stepSweeps = 10 }

type LDASampler = Int ->          -- number of topics
                  Int ->          -- number of documents
                  U.Vector Int -> -- words array
                  U.Vector Int -> -- doc index of each word                
                  Sampler
                  
hakaru :: MWC.GenIO -> LDASampler
hakaru g numTopics numDocs w doc knobs = do
    let numWords   = U.maximum w + 1
        topicPrior = array numTopics (const 1)
        wordPrior  = array numWords  (const 1)
        update     = prog topicPrior wordPrior numDocs w doc
    time0 <- getCurrentTime
    zs <- U.replicateM (U.length w) (MWC.uniformR (0, numTopics - 1) g)
    timeHakaru time0 (gibbsSweep update g) zs knobs
