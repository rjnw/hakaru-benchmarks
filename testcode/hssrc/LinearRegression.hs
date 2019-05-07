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
  ((MayBoxVec Double Double) ->
   ((MayBoxVec Double Double) -> (Measure (MayBoxVec Double Double))))
prog =
  lam $ \ dataX94 ->
  lam $ \ x695 ->
  (pose (unsafeProb ((fromInt (nat2int (size dataX94) * int_ -20 +
                               int_ -6) *
                      summate (nat_ 0)
                              (size dataX94)
                              (\ x1896 -> dataX94 ! x1896 ^ nat_ 2) +
                      summate (nat_ 0) (size dataX94) (\ x1897 -> dataX94 ! x1897)
                      ^ nat_ 2 *
                      real_ 20 +
                      fromInt (nat2int (size dataX94) * int_ -20) +
                      real_ (-6)) *
                     recip (((summate (nat_ 0)
                                      (size dataX94)
                                      (\ x1898 -> x695 ! x1898 ^ nat_ 2) *
                              real_ (-10) +
                              real_ (-95)) *
                             nat2real (size dataX94) +
                             summate (nat_ 0) (size dataX94) (\ x1899 -> x695 ! x1899)
                             ^ nat_ 2 *
                             real_ 10 +
                             summate (nat_ 0) (size dataX94) (\ x18100 -> x695 ! x18100) *
                             real_ 30 +
                             summate (nat_ 0)
                                     (size dataX94)
                                     (\ x18101 -> x695 ! x18101 ^ nat_ 2) *
                             real_ (-3) +
                             real_ (-6)) *
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18102 -> dataX94 ! x18102 ^ nat_ 2) +
                            (summate (nat_ 0)
                                     (size dataX94)
                                     (\ x18103 -> x695 ! x18103 * dataX94 ! x18103)
                             ^ nat_ 2 *
                             real_ 10 +
                             summate (nat_ 0)
                                     (size dataX94)
                                     (\ x18104 -> x695 ! x18104 ^ nat_ 2) *
                             real_ (-10) +
                             real_ (-95)) *
                            nat2real (size dataX94) +
                            (summate (nat_ 0) (size dataX94) (\ x18105 -> dataX94 ! x18105)
                             ^ nat_ 2 *
                             real_ 10 +
                             real_ (-3)) *
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18106 -> x695 ! x18106 ^ nat_ 2) +
                            summate (nat_ 0) (size dataX94) (\ x18107 -> dataX94 ! x18107)
                            ^ nat_ 2 *
                            real_ 95 +
                            (summate (nat_ 0) (size dataX94) (\ x18108 -> x695 ! x18108) *
                             summate (nat_ 0)
                                     (size dataX94)
                                     (\ x18109 -> x695 ! x18109 * dataX94 ! x18109) *
                             real_ (-20) +
                             summate (nat_ 0)
                                     (size dataX94)
                                     (\ x18110 -> x695 ! x18110 * dataX94 ! x18110) *
                             real_ (-30)) *
                            summate (nat_ 0) (size dataX94) (\ x18111 -> dataX94 ! x18111) +
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18112 -> x695 ! x18112 * dataX94 ! x18112)
                            ^ nat_ 2 *
                            real_ 3 +
                            summate (nat_ 0) (size dataX94) (\ x18113 -> x695 ! x18113)
                            ^ nat_ 2 *
                            real_ 10 +
                            summate (nat_ 0) (size dataX94) (\ x18114 -> x695 ! x18114) *
                            real_ 30 +
                            real_ (-6))) *
         nat_ 2 `thRootOf` (prob_ 3) *
         pi ** (nat2real (size dataX94) * real_ (-1/2)) *
         gammaFunc (real_ 1 + nat2real (size dataX94) * real_ (1/2)) *
         nat_ 2
         `thRootOf` (unsafeProb (recip (nat2real (size dataX94 * nat_ 10 +
                                                  nat_ 3) *
                                        summate (nat_ 0)
                                                (size dataX94)
                                                (\ x18115 -> dataX94 ! x18115 ^ nat_ 2) +
                                        summate (nat_ 0)
                                                (size dataX94)
                                                (\ x18116 -> dataX94 ! x18116)
                                        ^ nat_ 2 *
                                        real_ (-10) +
                                        nat2real (size dataX94 * nat_ 10) +
                                        real_ 3))) *
         unsafeProb ((nat2real (size dataX94 * nat_ 10 + nat_ 3) *
                      summate (nat_ 0)
                              (size dataX94)
                              (\ x18117 -> dataX94 ! x18117 ^ nat_ 2) +
                      summate (nat_ 0) (size dataX94) (\ x18118 -> dataX94 ! x18118)
                      ^ nat_ 2 *
                      real_ (-10) +
                      nat2real (size dataX94 * nat_ 10) +
                      real_ 3) *
                     recip ((nat2real (size dataX94 * nat_ 10 + nat_ 3) *
                             summate (nat_ 0)
                                     (size dataX94)
                                     (\ x18119 -> x695 ! x18119 ^ nat_ 2) +
                             summate (nat_ 0) (size dataX94) (\ x18120 -> x695 ! x18120)
                             ^ nat_ 2 *
                             real_ (-10) +
                             nat2real (size dataX94 * nat_ 95) +
                             summate (nat_ 0) (size dataX94) (\ x18121 -> x695 ! x18121) *
                             real_ (-30) +
                             real_ 6) *
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18122 -> dataX94 ! x18122 ^ nat_ 2) +
                            (summate (nat_ 0) (size dataX94) (\ x18123 -> dataX94 ! x18123)
                             ^ nat_ 2 *
                             real_ (-10) +
                             nat2real (size dataX94 * nat_ 10) +
                             real_ 3) *
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18124 -> x695 ! x18124 ^ nat_ 2) +
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18125 -> x695 ! x18125 * dataX94 ! x18125)
                            ^ nat_ 2 *
                            nat2real (size dataX94) *
                            real_ (-10) +
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18126 -> x695 ! x18126 * dataX94 ! x18126) *
                            summate (nat_ 0) (size dataX94) (\ x18127 -> dataX94 ! x18127) *
                            summate (nat_ 0) (size dataX94) (\ x18128 -> x695 ! x18128) *
                            real_ 20 +
                            summate (nat_ 0) (size dataX94) (\ x18129 -> x695 ! x18129)
                            ^ nat_ 2 *
                            real_ (-10) +
                            summate (nat_ 0) (size dataX94) (\ x18130 -> dataX94 ! x18130)
                            ^ nat_ 2 *
                            real_ (-95) +
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18131 -> x695 ! x18131 * dataX94 ! x18131) *
                            summate (nat_ 0) (size dataX94) (\ x18132 -> dataX94 ! x18132) *
                            real_ 30 +
                            summate (nat_ 0)
                                    (size dataX94)
                                    (\ x18133 -> x695 ! x18133 * dataX94 ! x18133)
                            ^ nat_ 2 *
                            real_ (-3) +
                            nat2real (size dataX94 * nat_ 95) +
                            summate (nat_ 0) (size dataX94) (\ x18134 -> x695 ! x18134) *
                            real_ (-30) +
                            real_ 6))
         ** (nat2real (size dataX94) * real_ (1/2))) $
        (gamma (prob_ 1 + nat2prob (size dataX94) * prob_ (1/2))
               (unsafeProb ((nat2real (size dataX94 * nat_ 20 + nat_ 6) *
                             summate (nat_ 0)
                                     (size dataX94)
                                     (\ x18136 -> dataX94 ! x18136 ^ nat_ 2) +
                             summate (nat_ 0) (size dataX94) (\ x18137 -> dataX94 ! x18137)
                             ^ nat_ 2 *
                             real_ (-20) +
                             nat2real (size dataX94 * nat_ 20) +
                             real_ 6) *
                            recip ((nat2real (size dataX94 * nat_ 10 + nat_ 3) *
                                    summate (nat_ 0)
                                            (size dataX94)
                                            (\ x18138 -> x695 ! x18138 ^ nat_ 2) +
                                    summate (nat_ 0) (size dataX94) (\ x18139 -> x695 ! x18139)
                                    ^ nat_ 2 *
                                    real_ (-10) +
                                    nat2real (size dataX94 * nat_ 95) +
                                    summate (nat_ 0) (size dataX94) (\ x18140 -> x695 ! x18140) *
                                    real_ (-30) +
                                    real_ 6) *
                                   summate (nat_ 0)
                                           (size dataX94)
                                           (\ x18141 -> dataX94 ! x18141 ^ nat_ 2) +
                                   (summate (nat_ 0) (size dataX94) (\ x18142 -> dataX94 ! x18142)
                                    ^ nat_ 2 *
                                    real_ (-10) +
                                    nat2real (size dataX94 * nat_ 10) +
                                    real_ 3) *
                                   summate (nat_ 0)
                                           (size dataX94)
                                           (\ x18143 -> x695 ! x18143 ^ nat_ 2) +
                                   summate (nat_ 0)
                                           (size dataX94)
                                           (\ x18144 -> x695 ! x18144 * dataX94 ! x18144)
                                   ^ nat_ 2 *
                                   nat2real (size dataX94) *
                                   real_ (-10) +
                                   summate (nat_ 0)
                                           (size dataX94)
                                           (\ x18145 -> x695 ! x18145 * dataX94 ! x18145) *
                                   summate (nat_ 0) (size dataX94) (\ x18146 -> dataX94 ! x18146) *
                                   summate (nat_ 0) (size dataX94) (\ x18147 -> x695 ! x18147) *
                                   real_ 20 +
                                   summate (nat_ 0) (size dataX94) (\ x18148 -> x695 ! x18148)
                                   ^ nat_ 2 *
                                   real_ (-10) +
                                   summate (nat_ 0) (size dataX94) (\ x18149 -> dataX94 ! x18149)
                                   ^ nat_ 2 *
                                   real_ (-95) +
                                   summate (nat_ 0)
                                           (size dataX94)
                                           (\ x18150 -> x695 ! x18150 * dataX94 ! x18150) *
                                   summate (nat_ 0) (size dataX94) (\ x18151 -> dataX94 ! x18151) *
                                   real_ 30 +
                                   summate (nat_ 0)
                                           (size dataX94)
                                           (\ x18152 -> x695 ! x18152 * dataX94 ! x18152)
                                   ^ nat_ 2 *
                                   real_ (-3) +
                                   nat2real (size dataX94 * nat_ 95) +
                                   summate (nat_ 0) (size dataX94) (\ x18153 -> x695 ! x18153) *
                                   real_ (-30) +
                                   real_ 6))) >>= \ invNoiseb135 ->
         normal ((summate (nat_ 0)
                          (size dataX94)
                          (\ x18155 -> x695 ! x18155 * dataX94 ! x18155) *
                  (nat2real (size dataX94) * real_ 10 + real_ 3) +
                  (summate (nat_ 0) (size dataX94) (\ x18156 -> x695 ! x18156) *
                   real_ (-10) +
                   real_ (-15)) *
                  summate (nat_ 0) (size dataX94) (\ x18157 -> dataX94 ! x18157)) *
                 recip (nat2real (size dataX94 * nat_ 10 + nat_ 3) *
                        summate (nat_ 0)
                                (size dataX94)
                                (\ x18158 -> dataX94 ! x18158 ^ nat_ 2) +
                        summate (nat_ 0) (size dataX94) (\ x18159 -> dataX94 ! x18159)
                        ^ nat_ 2 *
                        real_ (-10) +
                        nat2real (size dataX94 * nat_ 10) +
                        real_ 3))
                (recip (nat_ 2 `thRootOf` invNoiseb135) *
                 nat_ 2
                 `thRootOf` (unsafeProb (recip (nat2real (size dataX94 * nat_ 10 +
                                                          nat_ 3) *
                                                summate (nat_ 0)
                                                        (size dataX94)
                                                        (\ x18160 -> dataX94 ! x18160 ^ nat_ 2) +
                                                summate (nat_ 0)
                                                        (size dataX94)
                                                        (\ x18161 -> dataX94 ! x18161)
                                                ^ nat_ 2 *
                                                real_ (-10) +
                                                nat2real (size dataX94 * nat_ 10) +
                                                real_ 3)) *
                             (nat2prob (size dataX94) * prob_ 10 + prob_ 3))) >>= \ a9154 ->
         normal ((a9154 *
                  summate (nat_ 0) (size dataX94) (\ x18163 -> dataX94 ! x18163) *
                  real_ (-10) +
                  summate (nat_ 0) (size dataX94) (\ x18164 -> x695 ! x18164) *
                  real_ 10 +
                  real_ 15) *
                 fromProb (recip (nat2prob (size dataX94 * nat_ 10 + nat_ 3))))
                (nat_ 2 `thRootOf` (prob_ 10) *
                 recip (nat_ 2 `thRootOf` invNoiseb135) *
                 nat_ 2
                 `thRootOf` (recip (nat2prob (size dataX94 * nat_ 10 +
                                              nat_ 3)))) >>= \ b7162 ->
         dirac (arrayLit [a9154, b7162, fromProb invNoiseb135])))

