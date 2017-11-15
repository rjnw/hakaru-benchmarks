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
  ((MayBoxVec Prob Prob) ->
   ((MayBoxVec Int Int) ->
    ((MayBoxVec Double Double) -> (Int -> (Measure Int)))))
prog =
  lam $ \ as42 ->
  lam $ \ z43 ->
  lam $ \ t44 ->
  lam $ \ docUpdate45 ->
  case_ (size z43 == size t44 &&
         docUpdate45 < size z43 &&
         z43 ! docUpdate45 < size as42)
        [branch ptrue
                ((pose (product (nat_ 0)
                                (size as42)
                                (\ _b46 ->
                                 product (nat_ 0)
                                         (let_ (bucket (nat_ 0)
                                                       (size t44)
                                                       ((r_index (\ () -> size as42)
                                                                 (\ (_a49,()) -> z43 ! _a49)
                                                                 (r_add (\ (_a49,(_b50,())) ->
                                                                         nat_ 1))))) $ \ summary48 ->
                                          unsafeNat (nat2int (case_ (_b46 == z43 ! docUpdate45)
                                                                    [branch ptrue (nat_ 1),
                                                                     branch pfalse (nat_ 0)]) *
                                                     int_ -1 +
                                                     nat2int (summary48 ! _b46)))
                                         (\ j47 -> nat2prob j47 + as42 ! _b46)) *
                        prob_ 2
                        ** (nat2real (size as42) * real_ (1/2) +
                            nat2real (size t44) * real_ (-1/2)) *
                        exp (summate (nat_ 0) (size t44) (\ _a51 -> t44 ! _a51 ^ nat_ 2) *
                             real_ (-1/2)) *
                        pi ** (nat2real (size t44) * real_ (-1/2)) *
                        recip (product (nat_ 0)
                                       (summate (nat_ 0)
                                                (size t44)
                                                (\ _a53 ->
                                                 case_ (_a53 == docUpdate45)
                                                       [branch ptrue (nat_ 0),
                                                        branch pfalse (nat_ 1)]))
                                       (\ _b52 ->
                                        nat2prob _b52 +
                                        summate (nat_ 0) (size as42) (\ _a54 -> as42 ! _a54))) *
                        recip (nat2prob (summate (nat_ 0)
                                                 (size t44)
                                                 (\ _a55 ->
                                                  case_ (_a55 == docUpdate45)
                                                        [branch ptrue (nat_ 0),
                                                         branch pfalse (nat_ 1)])) +
                               summate (nat_ 0) (size as42) (\ _a56 -> as42 ! _a56))) $
                       (categorical (array (size as42) $
                                           \ zNewb57 ->
                                           unsafeProb ((fromInt (let_ (bucket (nat_ 0)
                                                                              (size t44)
                                                                              ((r_index (\ () ->
                                                                                         size as42)
                                                                                        (\ (_a59,()) ->
                                                                                         z43
                                                                                         ! _a59)
                                                                                        (r_add (\ (_a59,(zNewb60,())) ->
                                                                                                nat_ 1))))) $ \ summary58 ->
                                                                 nat2int (case_ (zNewb57
                                                                                 == z43
                                                                                    ! docUpdate45)
                                                                                [branch ptrue
                                                                                        (nat_ 1),
                                                                                 branch pfalse
                                                                                        (nat_ 0)]) *
                                                                 int_ -1 +
                                                                 nat2int (summary58 ! zNewb57)) +
                                                        fromProb (as42 ! zNewb57)) *
                                                       fromProb (exp (summate (nat_ 0)
                                                                              (size as42)
                                                                              (\ _a61 ->
                                                                               (let_ (bucket (nat_ 0)
                                                                                             (size t44)
                                                                                             ((r_index (\ () ->
                                                                                                        size as42)
                                                                                                       (\ (i63,()) ->
                                                                                                        z43
                                                                                                        ! i63)
                                                                                                       (r_add (\ (i63,(_a64,())) ->
                                                                                                               t44
                                                                                                               ! i63))))) $ \ summary62 ->
                                                                                case_ (_a61
                                                                                       == zNewb57)
                                                                                      [branch ptrue
                                                                                              (t44
                                                                                               ! docUpdate45),
                                                                                       branch pfalse
                                                                                              (real_ 0)] +
                                                                                case_ (_a61
                                                                                       == z43
                                                                                          ! docUpdate45)
                                                                                      [branch ptrue
                                                                                              (t44
                                                                                               ! docUpdate45),
                                                                                       branch pfalse
                                                                                              (real_ 0)] *
                                                                                real_ (-1) +
                                                                                summary62 ! _a61)
                                                                               ^ nat_ 2 *
                                                                               recip (fromInt (int_ 1 +
                                                                                               (let_ (bucket (nat_ 0)
                                                                                                             (size t44)
                                                                                                             ((r_index (\ () ->
                                                                                                                        size as42)
                                                                                                                       (\ (i66,()) ->
                                                                                                                        z43
                                                                                                                        ! i66)
                                                                                                                       (r_add (\ (i66,(_a67,())) ->
                                                                                                                               nat_ 1))))) $ \ summary65 ->
                                                                                                nat2int (case_ (_a61
                                                                                                                == zNewb57)
                                                                                                               [branch ptrue
                                                                                                                       (nat_ 1),
                                                                                                                branch pfalse
                                                                                                                       (nat_ 0)]) +
                                                                                                nat2int (case_ (_a61
                                                                                                                == z43
                                                                                                                   ! docUpdate45)
                                                                                                               [branch ptrue
                                                                                                                       (nat_ 1),
                                                                                                                branch pfalse
                                                                                                                       (nat_ 0)]) *
                                                                                                int_ -1 +
                                                                                                nat2int (summary65
                                                                                                         ! _a61)) *
                                                                                               int_ 196))) *
                                                                      real_ 98)) *
                                                       fromProb (recip (nat_ 2
                                                                        `thRootOf` (nat2prob (unsafeNat (product (nat_ 0)
                                                                                                                 (size as42)
                                                                                                                 (\ _b68 ->
                                                                                                                  int_ 2 +
                                                                                                                  (let_ (bucket (nat_ 0)
                                                                                                                                (size t44)
                                                                                                                                ((r_index (\ () ->
                                                                                                                                           size as42)
                                                                                                                                          (\ (_a70,()) ->
                                                                                                                                           z43
                                                                                                                                           ! _a70)
                                                                                                                                          (r_add (\ (_a70,(_b71,())) ->
                                                                                                                                                  nat_ 1))))) $ \ summary69 ->
                                                                                                                   nat2int (case_ (_b68
                                                                                                                                   == zNewb57)
                                                                                                                                  [branch ptrue
                                                                                                                                          (nat_ 1),
                                                                                                                                   branch pfalse
                                                                                                                                          (nat_ 0)]) +
                                                                                                                   nat2int (case_ (_b68
                                                                                                                                   == z43
                                                                                                                                      ! docUpdate45)
                                                                                                                                  [branch ptrue
                                                                                                                                          (nat_ 1),
                                                                                                                                   branch pfalse
                                                                                                                                          (nat_ 0)]) *
                                                                                                                   int_ -1 +
                                                                                                                   nat2int (summary69
                                                                                                                            ! _b68)) *
                                                                                                                  int_ 392))))))))))),
         branch pfalse
                (case_ (not (size z43 == size t44))
                       [branch ptrue (reject),
                        branch pfalse
                               (case_ (not (docUpdate45 < size z43))
                                      [branch ptrue (reject), branch pfalse (reject)])])]

