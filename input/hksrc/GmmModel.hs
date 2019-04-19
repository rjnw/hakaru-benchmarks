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
  ((MayBoxVec Prob Prob) ->
   (Int ->
    (Measure ((MayBoxVec Double Double), (MayBoxVec Int Int)))))
prog =
  let_ (lam $ \ as1 ->
        (plate (unsafeNat (nat2int (size as1) +
                           negate (nat2int (nat_ 1)))) $
               \ i3 ->
               beta (summate (i3 + nat_ 1) (size as1) (\ j4 -> as1 ! j4))
                    (as1 ! i3)) >>= \ xs2 ->
        dirac (array (size as1) $
                     \ i5 ->
                     let_ (product (nat_ 0) i5 (\ j7 -> xs2 ! j7)) $ \ x6 ->
                     x6 *
                     case_ (i5 + nat_ 1 == size as1)
                           [branch ptrue (nat2prob (nat_ 1)),
                            branch pfalse
                                   (unsafeProb (nat2real (nat_ 1) +
                                                negate (fromProb (xs2 ! i5))))])) $ \ dirichlet0 ->
  lam $ \ as8 ->
  lam $ \ n9 ->
  dirichlet0 `app` as8 >>= \ theta10 ->
  (plate (size as8) $
         \ k12 ->
         normal (nat2real (nat_ 0)) (nat2prob (nat_ 14))) >>= \ phi11 ->
  (plate n9 $ \ i14 -> categorical theta10) >>= \ z13 ->
  (plate n9 $
         \ i16 ->
         normal (phi11 ! (z13 ! i16)) (nat2prob (nat_ 1))) >>= \ t15 ->
  dirac (ann_ (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SArray SReal)) (SArray SNat)) (SPlus (SEt (SKonst (SArray SReal)) (SEt (SKonst (SArray SNat)) SDone)) SVoid))
              ((pair t15 z13)))

main :: IO ()
main = makeMain prog =<< getArgs
