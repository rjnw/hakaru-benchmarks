module Main where

import qualified Data.Vector.Unboxed as U
import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime)
import           Control.Monad (forM_)
import           System.Environment (getArgs)
    
import           Utils (SamplerKnobs(..), Sampler, Trial,
                        timeJags, gibbsSweep, timeHakaru)    
import           NaiveBayesGibbs.Prog    

main = do
  [inputs_path] <- getArgs
  let numTopics = 3
  dat <- readFile inputs_path         
  g <- MWC.createSystemRandom
  forM_ (lines dat) $ \line -> do
    let w :: [Int]
        doc :: [Int]
        zs :: [Int]
        ((w,doc),zs) = read line
    trial <- hakaru g numTopics (U.fromList w) (U.fromList doc) nbKnobs
    print trial

nbKnobs = Knobs { minSeconds = 10
                , stepSeconds = 0.5
                , minSweeps = 100
                , stepSweeps = 10 }

type NBSampler = Int ->          -- number of topics
                 U.Vector Int -> -- words array
                 U.Vector Int -> -- doc index of each word
                 Sampler

hakaru :: MWC.GenIO -> NBSampler
hakaru g numTopics w doc knobs = do
  let numWords   = U.maximum w
      numDocs    = U.last doc
      topicPrior = array numTopics (const 1)
      wordPrior  = array numWords  (const 1)
  time0 <- getCurrentTime
  zs <- U.replicateM numDocs (MWC.uniformR (0, numTopics - 1) g)
  let update = prog topicPrior wordPrior zs w doc
  timeHakaru time0 (gibbsSweep update g) zs knobs

             
