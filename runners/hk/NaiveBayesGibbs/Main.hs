module Main where

import qualified Data.Vector.Unboxed as U
import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime)
    
import           Utils (SamplerKnobs(..), Sampler,
                        timeJags, gibbsSweep, timeHakaru)    
import           NaiveBayesGibbs.Prog

main = do
  print "test compile"

type NaiveBayesSampler = Int -> -- number of topics
                         Int -> -- number of words
                         U.Vector Int -> -- words array
                         U.Vector Int -> -- doc index of each word
                         Sampler

nbKnobs = Knobs { minSeconds = 10
                , stepSeconds = 0.5
                , minSweeps = 100
                , stepSweeps = 10 }

hakaru :: NaiveBayesSampler
hakaru numTopics numWords w doc knobs = do
    g <- MWC.createSystemRandom
    let topicPrior = array numTopics (const 1)
        wordPrior  = array numWords  (const 1)
        numDocs    = U.last doc
    time0 <- getCurrentTime
    zs <- U.replicateM numDocs (MWC.uniformR (0, numTopics - 1) g)
    let update = prog topicPrior wordPrior zs w doc
    timeHakaru time0 (gibbsSweep g update) zs knobs
