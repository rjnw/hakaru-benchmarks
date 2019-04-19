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
   (Measure (((MayBoxVec Bool Bool), (MayBoxVec Bool Bool)), Bool)))
prog =
  lam $ \ n0 ->
  let_ (lam $ \ m12 ->
        lam $ \ m23 ->
        m12 >>= \ a4 ->
        m23 >>= \ b5 ->
        dirac (ann_ (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SPlus (SEt (SKonst (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SEt (SKonst (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) SDone)) SVoid))
                    ((pair a4 b5)))) $ \ liftArrayPair1 ->
  let_ (lam $ \ p7 ->
        categorical (arrayLit [p7,
                               unsafeProb (nat2real (nat_ 1) + negate (fromProb p7))]) >>= \ i8 ->
        dirac ((arrayLit [ann_ (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid)))
                               (true),
                          ann_ (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid)))
                               (false)])
               ! i8)) $ \ bern6 ->
  bern6 `app` (prob_ (1/2)) >>= \ isEffective9 ->
  beta (nat2prob (nat_ 1)) (nat2prob (nat_ 1)) >>= \ probControl10 ->
  beta (nat2prob (nat_ 1)) (nat2prob (nat_ 1)) >>= \ probTreated11 ->
  beta (nat2prob (nat_ 1)) (nat2prob (nat_ 1)) >>= \ probAll12 ->
  case_ isEffective9
        [branch ptrue
                (liftArrayPair1
                 `app` (plate n0 $ \ _14 -> bern6 `app` probControl10)
                 `app` (plate n0 $ \ _15 -> bern6 `app` probTreated11)),
         branch pfalse
                (liftArrayPair1 `app` (plate n0 $ \ _16 -> bern6 `app` probAll12)
                 `app` (plate n0 $
                              \ _17 -> bern6 `app` probAll12))] >>= \ groups13 ->
  dirac (ann_ (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SPlus (SEt (SKonst (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SEt (SKonst (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) SDone)) SVoid))) (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid)))) (SPlus (SEt (SKonst (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SPlus (SEt (SKonst (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) (SEt (SKonst (SArray (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid))))) SDone)) SVoid))) (SEt (SKonst (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid)))) SDone)) SVoid))
              ((pair groups13 isEffective9)))

main :: IO ()
main = makeMain prog =<< getArgs
