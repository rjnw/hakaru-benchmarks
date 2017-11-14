module Main where

import           Prelude hiding (product, exp, log, (**), pi)

import qualified System.Random.MWC as MWC
import qualified Data.Vector.Unboxed   as UV
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import           Control.Monad

import ClinicalTrial.Prog

main :: IO ()
main = do
  let n = 1000
  dat <- readFile ("../../input/ClinicalTrial/"++show n)
  forM_ (lines dat) $ \line -> do
    let v1 :: [Bool]
        v2 :: [Bool]
        i :: Bool
        ((v1, v2), i) = read line
    g <- MWC.createSystemRandom
    ni <- unMeasure (prog n (UV.fromList v1, UV.fromList v2)) g
    return ()
