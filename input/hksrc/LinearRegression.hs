{-# LANGUAGE DataKinds, NegativeLiterals #-}
module Main where

import           Prelude hiding (product)
import           Language.Hakaru.Runtime.Prelude

import           Language.Hakaru.Runtime.CmdLine
import           Language.Hakaru.Types.Sing
import qualified System.Random.MWC                as MWC
import           Control.Monad
import           System.Environment (getArgs)

prog ::
  ((MayBoxVec Double Double) ->
   (Measure ((MayBoxVec Double Double), (MayBoxVec Double Double))))
prog =
  lam $ \ dataX0 ->
  gamma (nat2prob (nat_ 1)) (nat2prob (nat_ 1)) >>= \ invNoise1 ->
  normal (nat2real (nat_ 0))
         (recip (nat_ 2 `thRootOf` invNoise1)) >>= \ a2 ->
  normal (nat2real (nat_ 5))
         (nat_ 2 `thRootOf` (prob_ (10/3)) *
          recip (nat_ 2 `thRootOf` invNoise1)) >>= \ b3 ->
  (plate (size dataX0) $
         \ i5 ->
         normal (a2 * dataX0 ! i5 + b3)
                (recip (nat_ 2 `thRootOf` invNoise1))) >>= \ y4 ->
  dirac (ann_ (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SArray SReal)) (SArray SReal)) (SPlus (SEt (SKonst (SArray SReal)) (SEt (SKonst (SArray SReal)) SDone)) SVoid))
              ((pair y4 (arrayLit [a2, b3, fromProb invNoise1]))))

main :: IO ()
main = makeMain prog =<< getArgs
