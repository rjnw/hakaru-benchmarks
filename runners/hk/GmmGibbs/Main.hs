{-# LANGUAGE CPP, DataKinds, NegativeLiterals #-}
module Main where

import           System.IO (hPutStrLn, hClose)
import           System.IO.Temp (withSystemTempFile)
import           Data.Time.Clock (getCurrentTime)
import           System.Process (readProcess)    
import qualified Data.Vector.Unboxed as U
import           Data.List (permutations)
    
import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Control.Monad

import           Utils (SamplerKnobs(..), Sampler,
                        timeJags, gibbsSweep, timeHakaru)
import           GmmGibbs.Prog

default (Int)

main :: IO ()
main = do
  let classes = 3
      points = 1000
  dat <- readFile ("../../../input/GmmGibbs/" ++ show classes
                                    ++ "-" ++ show points)
  putStrLn "(classes,points,sampler,seconds,sweeps,accuracy)"
  forM_ (lines dat) $ \line -> do
    let ts :: [Double]
        zs :: [Int]
        (ts,zs) = read line
    forM_ [("hakaru", hakaru),
           ("jags"  , jags  )] $ \(samplerName, sampler) -> do
      (time1, samples) <- sampler classes (U.fromList ts) gmmKnobs
      print (classes, points, samplerName, time1, 0, 0)

gmmKnobs = Knobs { minSeconds = 10
                 , stepSeconds = 0.5
                 , minSweeps = 100
                 , stepSweeps = 10 }

type GMMSampler = Int -> -- how many clusters to classify points into
                  U.Vector Double -> -- data points to classify
                  Sampler

jags :: GMMSampler
jags classes ts knobs = withSystemTempFile "gmmModel.data" $ \fp h -> do
  hPutStrLn h (unwords (map show (U.toList ts)))
  hClose h
  output <- readProcess "R"
            ["--slave", "-f", "gmmModel.R", "--args",
             show classes, fp,
             show (minSeconds knobs),
             show (stepSeconds knobs),
             show (minSweeps knobs),
             show (stepSweeps knobs)]
            ""
  timeJags output knobs

hakaru :: GMMSampler
hakaru classes ts knobs = do
  g <- MWC.createSystemRandom
  let as = array classes (const 1)
  time0 <- getCurrentTime
  zs <- U.replicateM (U.length ts) (MWC.uniformR (0, classes - 1) g)
  let sweep = gibbsSweep g (prog as zs ts)
  timeHakaru time0 sweep zs knobs

accuracy :: (Fractional ratio, Ord ratio)
         => Int -> U.Vector Int -> U.Vector Int -> ratio
accuracy classes actuals predicts =
  fromIntegral
       (maximum [ U.sum (U.zipWith (\a p -> if a == mapping U.! p
                                            then 1 else 0 :: Int)
                                   actuals predicts)
                | mapping <- U.fromList <$> permutations [0 .. classes - 1] ])
   / fromIntegral (U.length actuals)

