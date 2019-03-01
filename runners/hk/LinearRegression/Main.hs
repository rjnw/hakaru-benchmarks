module Main where

import           Prelude hiding (product, exp, log, (**), pi)

import qualified System.Random.MWC as MWC
import qualified Data.Vector.Unboxed   as UV
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import           Control.Monad
import           Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime, addUTCTime)
import           Control.DeepSeq

import LinearRegression.Prog
import Utils

main :: IO ()
main = do
  let n = 10000
  yss    <- readFile ("../input/LinearRegression/y/" ++ show n)
  dataxs <- readFile ("../input/LinearRegression/dataX/" ++ show n)
  let time (t_sofar, totalacc) (ys,dx) = do
         let xs :: [Double]
             truth :: [Double]
             dataX :: [Double]
             (xs, truth) = read ys
             dataX = map read (lines dataxs)
         g <- MWC.createSystemRandom
         timeafterread <- (xs, truth) `deepseq` getCurrentTime
         Just as <- unMeasure (prog (UV.fromList dataX) (UV.fromList xs)) g
         timeaftersample <- getCurrentTime
         let t = diffTime timeaftersample timeafterread
             cartDiff [a,b,c] [x,y,z] = (a-x)^2 + (b-y)^2 + (c-z)^2
         putStrLn $ "time " ++ show t
         return (t + t_sofar, totalacc + cartDiff truth (UV.toList as))
  let lns = zip (lines yss) (lines dataxs)
      numlines = length lns
  (totaltime,totalacc) <- foldM time (0,0) lns
  putStrLn $ show totaltime ++ " " ++
           show (totalacc / fromIntegral numlines)
