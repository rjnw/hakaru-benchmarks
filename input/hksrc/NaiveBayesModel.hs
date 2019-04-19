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
  (Int ->
   (Int ->
    (Int ->
     (Int ->
      (Measure
         ((MayBoxVec (MayBoxVec Int Int) (MayBoxVec Int Int)),
          (MayBoxVec Int Int)))))))
prog =
  lam $ \ sizeVocab0 ->
  lam $ \ numLabels1 ->
  lam $ \ numDocs2 ->
  lam $ \ sizeEachDoc3 ->
  let_ (lam $ \ as5 ->
        (plate (unsafeNat (nat2int (size as5) +
                           negate (nat2int (nat_ 1)))) $
               \ i7 ->
               beta (summate (i7 + nat_ 1) (size as5) (\ j8 -> as5 ! j8))
                    (as5 ! i7)) >>= \ xs6 ->
        dirac (array (size as5) $
                     \ i9 ->
                     let_ (product (nat_ 0) i9 (\ j11 -> xs6 ! j11)) $ \ x10 ->
                     x10 *
                     case_ (i9 + nat_ 1 == size as5)
                           [branch ptrue (nat2prob (nat_ 1)),
                            branch pfalse
                                   (unsafeProb (nat2real (nat_ 1) +
                                                negate (fromProb (xs6 ! i9))))])) $ \ dirichlet4 ->
  (plate numLabels1 $
         \ _13 ->
         dirichlet4
         `app` (array sizeVocab0 $ \ _14 -> nat2prob (nat_ 1))) >>= \ β12 ->
  dirichlet4
  `app` (array numLabels1 $ \ _16 -> nat2prob (nat_ 1)) >>= \ θ15 ->
  (plate numDocs2 $ \ _18 -> categorical θ15) >>= \ ζ17 ->
  (plate numDocs2 $
         \ i20 ->
         (plate sizeEachDoc3 $
                \ _21 -> categorical (β12 ! (ζ17 ! i20)))) >>= \ docs19 ->
  dirac (ann_ (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SArray (SArray SNat))) (SArray SNat)) (SPlus (SEt (SKonst (SArray (SArray SNat))) (SEt (SKonst (SArray SNat)) SDone)) SVoid))
              ((pair docs19 ζ17)))

main :: IO ()
main = makeMain prog =<< getArgs
