{-# LANGUAGE DataKinds, NegativeLiterals #-}
module Prog where

import           Data.Number.LogFloat (LogFloat)
import           Prelude hiding (product, exp, log, (**), pi)
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import           Language.Hakaru.Types.Sing
import qualified System.Random.MWC                as MWC
import           Control.Monad
import           System.Environment (getArgs)

prog ::
  (Prob ->
   ((MayBoxVec Prob Prob) ->
    ((MayBoxVec Int Int) ->
     ((MayBoxVec Double Double) -> (Int -> (Measure Int))))))
prog =
  lam $ \ s44 ->
  lam $ \ as45 ->
  lam $ \ z46 ->
  lam $ \ t47 ->
  lam $ \ docUpdate48 ->
  case_ (size z46 == size t47 &&
         docUpdate48 < size z46 &&
         z46 ! docUpdate48 < size as45)
        [branch ptrue
                ((pose (product (nat_ 0)
                                (size as45)
                                (\ _b49 ->
                                 product (nat_ 0)
                                         (let_ (bucket (nat_ 0)
                                                       (size t47)
                                                       ((r_index (\ () -> size as45)
                                                                 (\ (_a52,()) -> z46 ! _a52)
                                                                 (r_add (\ (_a52,(_b53,())) ->
                                                                         nat_ 1))))) $ \ summary51 ->
                                          unsafeNat (nat2int (case_ (_b49 == z46 ! docUpdate48)
                                                                    [branch ptrue (nat_ 1),
                                                                     branch pfalse (nat_ 0)]) *
                                                     int_ -1) +
                                          summary51 ! _b49)
                                         (\ j50 -> nat2prob j50 + as45 ! _b49)) *
                        exp (summate (nat_ 0) (size t47) (\ _a54 -> t47 ! _a54 ^ nat_ 2) *
                             real_ (-1/2)) *
                        prob_ 2 ** (nat2real (size t47) * real_ (-1/2)) *
                        pi ** (nat2real (size t47) * real_ (-1/2)) *
                        recip (product (nat_ 0)
                                       (summate (nat_ 0)
                                                (size t47)
                                                (\ _a56 ->
                                                 case_ (_a56 == docUpdate48)
                                                       [branch ptrue (nat_ 0),
                                                        branch pfalse (nat_ 1)]))
                                       (\ _b55 ->
                                        nat2prob _b55 +
                                        summate (nat_ 0) (size as45) (\ _a57 -> as45 ! _a57))) *
                        recip (nat2prob (summate (nat_ 0)
                                                 (size t47)
                                                 (\ _a58 ->
                                                  case_ (_a58 == docUpdate48)
                                                        [branch ptrue (nat_ 0),
                                                         branch pfalse (nat_ 1)])) +
                               summate (nat_ 0) (size as45) (\ _a59 -> as45 ! _a59))) $
                       (categorical (array (size as45) $
                                           \ zNewd60 ->
                                           unsafeProb ((fromInt (let_ (bucket (nat_ 0)
                                                                              (size t47)
                                                                              ((r_index (\ () ->
                                                                                         size as45)
                                                                                        (\ (_a62,()) ->
                                                                                         z46
                                                                                         ! _a62)
                                                                                        (r_add (\ (_a62,(zNewd63,())) ->
                                                                                                nat_ 1))))) $ \ summary61 ->
                                                                 nat2int (case_ (zNewd60
                                                                                 == z46
                                                                                    ! docUpdate48)
                                                                                [branch ptrue
                                                                                        (nat_ 1),
                                                                                 branch pfalse
                                                                                        (nat_ 0)]) *
                                                                 int_ -1 +
                                                                 nat2int (summary61 ! zNewd60)) +
                                                        fromProb (as45 ! zNewd60)) *
                                                       fromProb (recip (nat_ 2
                                                                        `thRootOf` (unsafeProb (product (nat_ 0)
                                                                                                        (size as45)
                                                                                                        (\ _b71 ->
                                                                                                         fromInt (let_ (bucket (nat_ 0)
                                                                                                                               (size t47)
                                                                                                                               ((r_index (\ () ->
                                                                                                                                          size as45)
                                                                                                                                         (\ (_a73,()) ->
                                                                                                                                          z46
                                                                                                                                          ! _a73)
                                                                                                                                         (r_add (\ (_a73,(_b74,())) ->
                                                                                                                                                 nat_ 1))))) $ \ summary72 ->
                                                                                                                  nat2int (case_ (_b71
                                                                                                                                  == zNewd60)
                                                                                                                                 [branch ptrue
                                                                                                                                         (nat_ 1),
                                                                                                                                  branch pfalse
                                                                                                                                         (nat_ 0)]) +
                                                                                                                  nat2int (case_ (_b71
                                                                                                                                  == z46
                                                                                                                                     ! docUpdate48)
                                                                                                                                 [branch ptrue
                                                                                                                                         (nat_ 1),
                                                                                                                                  branch pfalse
                                                                                                                                         (nat_ 0)]) *
                                                                                                                  int_ -1 +
                                                                                                                  nat2int (summary72
                                                                                                                           ! _b71)) *
                                                                                                         fromProb (s44
                                                                                                                   ^ nat_ 2) +
                                                                                                         real_ 1)))))) *
                                           exp (summate (nat_ 0)
                                                        (size as45)
                                                        (\ _a64 ->
                                                         (let_ (bucket (nat_ 0)
                                                                       (size t47)
                                                                       ((r_index (\ () -> size as45)
                                                                                 (\ (i66,()) ->
                                                                                  z46
                                                                                  ! i66)
                                                                                 (r_add (\ (i66,(_a67,())) ->
                                                                                         t47
                                                                                         ! i66))))) $ \ summary65 ->
                                                          case_ (_a64 == zNewd60)
                                                                [branch ptrue (t47 ! docUpdate48),
                                                                 branch pfalse (real_ 0)] +
                                                          case_ (_a64 == z46 ! docUpdate48)
                                                                [branch ptrue (t47 ! docUpdate48),
                                                                 branch pfalse (real_ 0)] *
                                                          real_ (-1) +
                                                          summary65 ! _a64)
                                                         ^ nat_ 2 *
                                                         recip (fromInt (let_ (bucket (nat_ 0)
                                                                                      (size t47)
                                                                                      ((r_index (\ () ->
                                                                                                 size as45)
                                                                                                (\ (i69,()) ->
                                                                                                 z46
                                                                                                 ! i69)
                                                                                                (r_add (\ (i69,(_a70,())) ->
                                                                                                        nat_ 1))))) $ \ summary68 ->
                                                                         nat2int (case_ (_a64
                                                                                         == zNewd60)
                                                                                        [branch ptrue
                                                                                                (nat_ 1),
                                                                                         branch pfalse
                                                                                                (nat_ 0)]) +
                                                                         nat2int (case_ (_a64
                                                                                         == z46
                                                                                            ! docUpdate48)
                                                                                        [branch ptrue
                                                                                                (nat_ 1),
                                                                                         branch pfalse
                                                                                                (nat_ 0)]) *
                                                                         int_ -1 +
                                                                         nat2int (summary68
                                                                                  ! _a64)) *
                                                                fromProb (s44 ^ nat_ 2) +
                                                                real_ 1)) *
                                                fromProb (s44 ^ nat_ 2) *
                                                real_ (1/2)))))),
         branch pfalse
                (case_ (not (size z46 == size t47))
                       [branch ptrue (reject),
                        branch pfalse
                               (case_ (not (docUpdate48 < size z46))
                                      [branch ptrue (reject), branch pfalse (reject)])])]

