{-# LANGUAGE DataKinds, NegativeLiterals #-}
module GmmGibbs.Prog where

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
                ((pose (prob_ 2 ** (nat2real (size t47) * real_ (-1/2)) *
                        exp (summate (nat_ 0) (size t47) (\ _a49 -> t47 ! _a49 ^ nat_ 2) *
                             real_ (-1/2)) *
                        pi ** (nat2real (size t47) * real_ (-1/2)) *
                        product (nat_ 0)
                                (size as45)
                                (\ _b50 ->
                                 product (nat_ 0)
                                         (let_ (bucket (nat_ 0)
                                                       (size t47)
                                                       ((r_index (\ () -> size as45)
                                                                 (\ (_a53,()) -> z46 ! _a53)
                                                                 (r_add (\ (_a53,(_b54,())) ->
                                                                         nat_ 1))))) $ \ summary52 ->
                                          unsafeNat (nat2int (case_ (_b50 == z46 ! docUpdate48)
                                                                    [branch ptrue (nat_ 1),
                                                                     branch pfalse (nat_ 0)]) *
                                                     int_ -1 +
                                                     nat2int (summary52 ! _b50)))
                                         (\ j51 -> nat2prob j51 + as45 ! _b50)) *
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
                                           unsafeProb (fromInt (let_ (bucket (nat_ 0)
                                                                             (size t47)
                                                                             ((r_index (\ () ->
                                                                                        size as45)
                                                                                       (\ (_a73,()) ->
                                                                                        z46
                                                                                        ! _a73)
                                                                                       (r_add (\ (_a73,(zNewd74,())) ->
                                                                                               nat_ 1))))) $ \ summary72 ->
                                                                nat2int (case_ (zNewd60
                                                                                == z46
                                                                                   ! docUpdate48)
                                                                               [branch ptrue
                                                                                       (nat_ 1),
                                                                                branch pfalse
                                                                                       (nat_ 0)]) *
                                                                int_ -1 +
                                                                nat2int (summary72 ! zNewd60)) +
                                                       fromProb (as45 ! zNewd60)) *
                                           exp (summate (nat_ 0)
                                                        (size as45)
                                                        (\ _a61 ->
                                                         (let_ (bucket (nat_ 0)
                                                                       (size t47)
                                                                       ((r_index (\ () -> size as45)
                                                                                 (\ (i63,()) ->
                                                                                  z46
                                                                                  ! i63)
                                                                                 (r_add (\ (i63,(_a64,())) ->
                                                                                         t47
                                                                                         ! i63))))) $ \ summary62 ->
                                                          case_ (_a61 == zNewd60)
                                                                [branch ptrue (t47 ! docUpdate48),
                                                                 branch pfalse (real_ 0)] +
                                                          case_ (_a61 == z46 ! docUpdate48)
                                                                [branch ptrue (t47 ! docUpdate48),
                                                                 branch pfalse (real_ 0)] *
                                                          real_ (-1) +
                                                          summary62 ! _a61)
                                                         ^ nat_ 2 *
                                                         recip (fromInt (let_ (bucket (nat_ 0)
                                                                                      (size t47)
                                                                                      ((r_index (\ () ->
                                                                                                 size as45)
                                                                                                (\ (i66,()) ->
                                                                                                 z46
                                                                                                 ! i66)
                                                                                                (r_add (\ (i66,(_a67,())) ->
                                                                                                        nat_ 1))))) $ \ summary65 ->
                                                                         nat2int (case_ (_a61
                                                                                         == zNewd60)
                                                                                        [branch ptrue
                                                                                                (nat_ 1),
                                                                                         branch pfalse
                                                                                                (nat_ 0)]) +
                                                                         nat2int (case_ (_a61
                                                                                         == z46
                                                                                            ! docUpdate48)
                                                                                        [branch ptrue
                                                                                                (nat_ 1),
                                                                                         branch pfalse
                                                                                                (nat_ 0)]) *
                                                                         int_ -1 +
                                                                         nat2int (summary65
                                                                                  ! _a61)) *
                                                                fromProb (s44 ^ nat_ 2) +
                                                                real_ 1)) *
                                                fromProb (s44 ^ nat_ 2) *
                                                real_ (1/2)) *
                                           recip (nat_ 2
                                                  `thRootOf` (unsafeProb (product (nat_ 0)
                                                                                  (size as45)
                                                                                  (\ _b68 ->
                                                                                   fromInt (let_ (bucket (nat_ 0)
                                                                                                         (size t47)
                                                                                                         ((r_index (\ () ->
                                                                                                                    size as45)
                                                                                                                   (\ (_a70,()) ->
                                                                                                                    z46
                                                                                                                    ! _a70)
                                                                                                                   (r_add (\ (_a70,(_b71,())) ->
                                                                                                                           nat_ 1))))) $ \ summary69 ->
                                                                                            nat2int (case_ (_b68
                                                                                                            == zNewd60)
                                                                                                           [branch ptrue
                                                                                                                   (nat_ 1),
                                                                                                            branch pfalse
                                                                                                                   (nat_ 0)]) +
                                                                                            nat2int (case_ (_b68
                                                                                                            == z46
                                                                                                               ! docUpdate48)
                                                                                                           [branch ptrue
                                                                                                                   (nat_ 1),
                                                                                                            branch pfalse
                                                                                                                   (nat_ 0)]) *
                                                                                            int_ -1 +
                                                                                            nat2int (summary69
                                                                                                     ! _b68)) *
                                                                                   fromProb (s44
                                                                                             ^ nat_ 2) +
                                                                                   real_ 1)))))))),
         branch pfalse
                (case_ (not (size z46 == size t47))
                       [branch ptrue (reject),
                        branch pfalse
                               (case_ (not (docUpdate48 < size z46))
                                      [branch ptrue (reject), branch pfalse (reject)])])]
