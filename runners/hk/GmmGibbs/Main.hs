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
import           System.Directory (doesFileExist, removeFile)

import           Utils (SamplerKnobs(..),
                        Sampler, oneLine,
                        timeJags, gibbsSweep,
                        timeHakaru, paramsFromName)
import           GmmGibbs.Prog

default (Int)

main :: IO ()
main = do  
  [inputs_path, outputs_path] <- getArgs
  let [classes, _] = paramsFromName inputs_path
  dat <- readFile inputs_path
  b <- doesFileExist outputs_path
  when b (removeFile outputs_path)
  g <- MWC.createSystemRandom
  forM_ (lines dat) $ \line -> do
    let ts :: [Double]
        zs :: [Int]
        (ts,zs) = read line
    trial <- oneLine <$> hakaru g classes (U.fromList ts) gmmKnobs
    putStrLn "writing..."
    appendFile outputs_path trial

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
  zs <- U.replicateM (U.length ts) (MWC.uniformR (0, classes - 1) g)
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

