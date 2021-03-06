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
import           GmmGibbs.Prog

default (Int)

main :: IO ()
main = do
  [inputs_path, outputs_dir] <- getArgs
  let [classes, pts] = paramsFromName inputs_path
      output_fname = show classes ++ "-" ++ show pts
      benchmark_dir = outputs_dir </> "GmmGibbs"
  dat <- readFile inputs_path
  g <- MWC.createSystemRandom
  hkfile   <- freshFile (benchmark_dir </> "hk-sham")   output_fname
  forM_ (lines dat) $ \line -> do
    let ts :: [Double]
        zs :: [Int]
        (ts,zs) = read line
        tsvec = U.fromList ts
    hktrial   <- oneLine <$> hakaru g classes tsvec gmmKnobs
    appendFile hkfile   hktrial

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
