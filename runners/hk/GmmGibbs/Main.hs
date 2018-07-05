{-# LANGUAGE CPP, DataKinds, NegativeLiterals #-}
module Main where

import           System.IO (hPutStrLn, hClose)
import           System.IO.Temp (withSystemTempFile)
import           Data.Time.Clock (getCurrentTime)
import           System.Process (readProcess)
import qualified Data.Vector.Unboxed as U

import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Control.Monad
import           System.Environment (getArgs)
import           System.Directory (doesFileExist, removeFile,
                                   createDirectoryIfMissing)
import           System.FilePath ((</>))
import           Utils (SamplerKnobs(..), freshFile,
                        Sampler, oneLine, gmmKnobs,
                        timeJags, gibbsSweep,
                        timeHakaru, paramsFromName)
import           GmmGibbs.Prog4

default (Int)

main :: IO ()
main = do
  [inputs_path, jagscodedir, outputs_dir] <- getArgs
  let [classes, pts] = paramsFromName inputs_path
      output_fname = show classes ++ "-" ++ show pts
      benchmark_dir = outputs_dir </> "GmmGibbs"
      jagsmodel = jagscodedir </> "GmmModel.jags"
      jagsrunner = jagscodedir </> "GmmModel.R"
  dat <- readFile inputs_path
  g <- MWC.createSystemRandom
  hkfile   <- freshFile (benchmark_dir </> "hk")   output_fname
  jagsfile <- freshFile (benchmark_dir </> "jags") output_fname
  forM_ (lines dat) $ \line -> do
    let ts :: [Double]
        zs :: [Int]
        (ts,zs) = read line
        tsvec = U.fromList ts
    hktrial   <- oneLine <$> hakaru g classes tsvec gmmKnobs
    jagstrial <- oneLine <$> jags jagsmodel jagsrunner classes tsvec gmmKnobs
    appendFile hkfile   hktrial
    appendFile jagsfile jagstrial


type GMMSampler = Int -> -- how many clusters to classify points into
                  U.Vector Double -> -- data points to classify
                  Sampler

hakaru :: MWC.GenIO -> GMMSampler
hakaru g classes ts knobs = do
  let stddev = 14
      as = array classes (const 1)
      sweep = gibbsSweep (\z -> prog stddev as z ts) g
  time0 <- getCurrentTime
  zs <- U.replicateM (U.length ts) (MWC.uniformR (0, classes - 1) g)
  timeHakaru time0 sweep zs knobs

jags :: FilePath -> FilePath -> GMMSampler
jags m r classes ts knobs = withSystemTempFile "GmmModel.data" $ \fp h -> do
  hPutStrLn h (unwords (map show (U.toList ts)))
  hClose h
  output <- readProcess "R"
            ["--slave", "-f", r, "--args",
             show classes, fp,
             show (minSeconds knobs),
             show (stepSeconds knobs),
             show (minSweeps knobs),
             show (stepSweeps knobs), m]
            ""
  timeJags output knobs
