module Main where

import           Prelude hiding (product, exp, log, (**), pi)

import qualified System.Random.MWC as MWC
import qualified Data.Vector.Unboxed   as UV
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import           Control.Monad
import           Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime, addUTCTime)
import           Control.DeepSeq

import ClinicalTrial.Prog
import Utils

main :: IO ()
main = do
  let n = 10000
  dat <- readFile ("../../input/ClinicalTrial/"++show n)
  let time (t_sofar, numright) line = do
         let v1 :: [Bool]
             v2 :: [Bool]
             i :: Bool
             ((v1, v2), i) = read line
         g <- MWC.createSystemRandom
         timeafterread <- ((v1,v2),i) `deepseq` getCurrentTime
         Just ni <- unMeasure (prog n (UV.fromList v1, UV.fromList v2)) g
         timeaftersample <- getCurrentTime
         let t = diffTime timeaftersample timeafterread
         putStrLn $ "time: " ++ show t
         return (t + t_sofar, if ni==i then numright+1 else numright)
  let lns = lines dat
      numlines = length lns
  (totaltime,totalright) <- foldM time (0,0) lns
  putStrLn $ show totaltime ++ " " ++
           show (totalright / fromIntegral numlines)
