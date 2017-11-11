{-# LANGUAGE DataKinds, NegativeLiterals #-}
module Prog where

import           Data.Number.LogFloat (LogFloat)
import           Prelude hiding (product, exp, log, (**))
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import           Language.Hakaru.Types.Sing
import qualified System.Random.MWC                as MWC
import           Control.Monad
import           System.Environment (getArgs)

prog ::
  (Int ->
   (((MayBoxVec Bool Bool), (MayBoxVec Bool Bool)) -> (Measure Bool)))
prog =
  lam $ \ n87 ->
  lam $ \ x1888 ->
  case_ x1888
        [branch (ppair PVar PVar)
                (\ a589 a390 ->
                 superpose [(betaFunc (nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4691 ->
                                                          (arrayLit [nat_ 0, nat_ 1])
                                                          ! (case_ (a589 ! x4691)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       prob_ 1)
                                      (nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4692 ->
                                                          (arrayLit [nat_ 1, nat_ 0])
                                                          ! (case_ (a589 ! x4692)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       prob_ 1) *
                             betaFunc (nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4693 ->
                                                          (arrayLit [nat_ 0, nat_ 1])
                                                          ! (case_ (a390 ! x4693)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       prob_ 1)
                                      (nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4694 ->
                                                          (arrayLit [nat_ 1, nat_ 0])
                                                          ! (case_ (a390 ! x4694)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       prob_ 1) *
                             prob_ (1/16),
                             dirac (ann_ (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid)))
                                         (true))),
                            (betaFunc (nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4695 ->
                                                          (arrayLit [nat_ 0, nat_ 1])
                                                          ! (case_ (a589 ! x4695)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4696 ->
                                                          (arrayLit [nat_ 0, nat_ 1])
                                                          ! (case_ (a390 ! x4696)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       prob_ 1)
                                      (nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4697 ->
                                                          (arrayLit [nat_ 1, nat_ 0])
                                                          ! (case_ (a589 ! x4697)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       nat2prob (summate (nat_ 0)
                                                         n87
                                                         (\ x4698 ->
                                                          (arrayLit [nat_ 1, nat_ 0])
                                                          ! (case_ (a390 ! x4698)
                                                                   [branch ptrue (nat_ 0),
                                                                    branch pfalse (nat_ 1)]))) +
                                       prob_ 1) *
                             prob_ (1/16),
                             dirac (ann_ (SData (STyCon (SingSymbol :: Sing "Bool")) (SPlus SDone (SPlus SDone SVoid)))
                                         (false)))])]

