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
import           System.Environment (getArgs)    

import           Utils (SamplerKnobs(..), Sampler, Trial,
                        timeJags, gibbsSweep, timeHakaru)
import           GmmGibbs.Prog

default (Int)

main :: IO ()
main = do  
  [inputs_path] <- getArgs
  let classes = 3
  dat <- readFile inputs_path
  g <- MWC.createSystemRandom
  forM_ (lines dat) $ \line -> do
    let ts :: [Double]
        zs :: [Int]
        (ts,zs) = read line
    trial <- hakaru g classes (U.fromList ts) gmmKnobs
    print trial

gmmKnobs = Knobs { minSeconds = 10
                 , stepSeconds = 0.5
                 , minSweeps = 100
                 , stepSweeps = 10 }

type GMMSampler = Int -> -- how many clusters to classify points into
                  U.Vector Double -> -- data points to classify
                  Sampler

hakaru :: MWC.GenIO -> GMMSampler
hakaru g classes ts knobs = do
  let as = array classes (const 1)
  time0 <- getCurrentTime
  zs <- U.replicateM (U.length ts) (MWC.uniformR (0, U.length as - 1) g)
  let sweep = gibbsSweep (prog as zs ts) g
  timeHakaru time0 sweep zs knobs

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

