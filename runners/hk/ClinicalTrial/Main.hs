module Main where

import qualified System.Random.MWC as MWC
import qualified Data.Vector.Unboxed   as UV
import           Language.Hakaru.Runtime.LogFloatPrelude

import Prog

main :: IO ()
main = do
  let v1 = UV.fromList [False, False, False, False, False, True, False, False, False, True]
  let v2 = UV.fromList [False, False, False, False, False, False, False, False, False, True]
  let n = 10
  let a = prog n (v1, v2)
  g <- MWC.createSystemRandom
  run g a
  print "test compile"
