{-# LANGUAGE CPP, DataKinds, NegativeLiterals #-}
module Main where

import System.IO (hPutStrLn, hClose)
import System.IO.Temp (withSystemTempFile)
import System.Process (readProcess)
import Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import qualified Data.Vector.Unboxed as U
import Data.List (permutations)
import Control.Monad ((>=>), forM)

import           Data.Number.LogFloat (LogFloat)
import           Prelude hiding (product, exp, log, (**), pi)
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import           Language.Hakaru.Types.Sing
import qualified System.Random.MWC                as MWC
import           Control.Monad
import           System.Environment (getArgs)

default (Int)

main :: IO ()
main = do
  let classes = 3
      points = 1000
  dat <- readFile ("../../input/gmmGibbs/" ++ show classes
                                    ++ "-" ++ show points)
  putStrLn "(classes,points,sampler,seconds,sweeps,accuracy)"
  forM_ (lines dat) $ \line -> do
    let ts :: [Double]
        zs :: [Int]
        (ts,zs) = read line
    forM_ [("hakaru", hakaru),
           ("jags"  , jags  )] $ \(samplerName, sampler) -> do
      (time1, samples) <- sampler classes (U.fromList ts)
      print (classes, points, samplerName, time1, 0, 0)
      mapM_ (\(time2, iter, zs') ->
             let acc = accuracy classes (U.fromList zs) zs' :: Double in
             print (classes, points, samplerName, time2, iter, acc))
            samples

minSeconds, stepSeconds :: Double
minSeconds = 10
stepSeconds = 0.5

minSweeps, stepSweeps :: Int
minSweeps = 100
stepSweeps = 10

type Sampler = Int -> -- how many clusters to classify points into
               U.Vector Double -> -- data points to classify
               IO (Double, -- initialization time in seconds
                   [(Double, -- seconds since beginning of initialization
                     Int, -- sweeps performed so far
                     U.Vector Int)]) -- current classification

jags :: Sampler
jags classes ts = withSystemTempFile "gmmModel.data" $ \fp h -> do
  hPutStrLn h (unwords (map show (U.toList ts)))
  hClose h
  output <- readProcess "R"
                        ["--slave", "-f", "gmmModel.R", "--args",
                         show classes, fp,
                         show minSeconds, show stepSeconds,
                         show minSweeps, show stepSweeps]
                        ""
  let times:samples  = lines output
      [time0, time1] = map read (words times)
      parse (stats:zs_:rest) = (time2 - time0, iter, zs) : parse rest
        where time2           = read time2_
              iter            = read iter_
              [time2_, iter_] = words stats
              zs              = U.fromList . map (pred . read) . words $ zs_
      parse _ = []
  return (time1 - time0, parse samples)

hakaru :: Sampler
hakaru classes ts = do
  g <- MWC.createSystemRandom
  let as = array classes (const 1)
  time0 <- getCurrentTime
  zs <- U.replicateM (U.length ts) (MWC.uniformR (0, classes - 1) g)
  time1 <- getCurrentTime
  let sweep :: U.Vector Int -> IO (U.Vector Int)
      sweep = hakaruSweep as ts g
      sweeps :: Int -> U.Vector Int -> IO (U.Vector Int)
      sweeps 0 = return
      sweeps n = sweep >=> sweeps (n - 1)
      loop :: Int -> Double -> Double -> U.Vector Int
           -> IO [(Double, Int, U.Vector Int)]
      loop iter time2 time2subgoal zs
        | time2 >= minSeconds && iter >= minSweeps = return []
        | otherwise = do
            zs <- sweeps stepSweeps zs
            time2 <- (`diffTime` time0) <$> getCurrentTime
            iter <- return (iter + stepSweeps)
            if time2 >= time2subgoal || time2 >= minSeconds && iter >= minSweeps
            then ((time2, iter, zs) : ) <$>
                 loop iter time2 (time2 + stepSeconds) zs
            else loop iter time2 time2subgoal zs
  samples <- loop 0 0 stepSeconds zs
  return (diffTime time1 time0, samples)

hakaruSweep :: U.Vector Prob
            -> U.Vector Double
            -> MWC.GenIO
            -> U.Vector Int
            -> IO (U.Vector Int)
hakaruSweep as ts g zs | U.length ts == U.length zs = loop (U.length zs) zs
  where loop :: Int -> U.Vector Int -> IO (U.Vector Int)
        loop 0 zs = return zs
        loop i zs = do -- print (as, zs, ts, i - 1)
                       Just zNew <- unMeasure (prog as zs ts (i - 1)) g
                       -- print zNew
                       loop (i - 1) (U.unsafeUpd zs [(i - 1, zNew)])

diffTime :: UTCTime -> UTCTime -> Double
diffTime a b = fromRational . toRational $ diffUTCTime a b

accuracy :: (Fractional ratio, Ord ratio)
         => Int -> U.Vector Int -> U.Vector Int -> ratio
accuracy classes actuals predicts =
  fromIntegral
       (maximum [ U.sum (U.zipWith (\a p -> if a == mapping U.! p
                                            then 1 else 0 :: Int)
                                   actuals predicts)
                | mapping <- U.fromList <$> permutations [0 .. classes - 1] ])
   / fromIntegral (U.length actuals)

prog :: U.Vector Prob
     -> U.Vector Int
     -> U.Vector Double
     -> Int
     -> Measure Int
prog = do {
#include "../hssrc/gmm_gibbs_simp.hs"
}
