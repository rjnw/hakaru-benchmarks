module Main where


import qualified Data.Vector.Unboxed as U
import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime)
    
import           Utils (SamplerKnobs(..), Sampler,
                        timeJags, gibbsSweep, timeHakaru)
import           LdaGibbs.Prog

main = do
  print "test compile"

type LDASampler = Int -> -- number of topics
                  Int -> -- number of words
                  U.Vector Int -> -- words array
                  U.Vector Int -> -- doc index of each word in words array
                  Sampler

ldaKnobs = Knobs { minSeconds = 10
                 , stepSeconds = 0.5
                 , minSweeps = 100
                 , stepSweeps = 10 }

hakaru :: LDASampler
hakaru numTopics numWords w doc knobs = do
    g <- MWC.createSystemRandom
    let topicPrior = array numTopics (const 1)
        wordPrior  = array numWords  (const 1)
        numDocs    = U.last w
    time0 <- getCurrentTime
    zs <- U.replicateM numDocs (MWC.uniformR (0, numTopics - 1) g)
    let update = prog topicPrior wordPrior numDocs w doc zs
    timeHakaru time0 (gibbsSweep g update) zs knobs
