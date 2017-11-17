{-# LANGUAGE DataKinds, NegativeLiterals #-}
module LinearRegression.Prog where

import           Data.Number.LogFloat (LogFloat)
import           Prelude hiding (product, exp, log, (**), pi)
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import           Language.Hakaru.Types.Sing
import qualified System.Random.MWC                as MWC
import           Control.Monad
import           System.Environment (getArgs)

gammaFunc = undefined    

prog ::
  ((MayBoxVec Double Double) ->
   ((MayBoxVec Double Double) -> (Measure (MayBoxVec Double Double))))
prog =
  lam $ \ dataX125 ->
  lam $ \ x6126 ->
  (pose (unsafeProb (fromProb (pi
                               ** (nat2real (size dataX125) * real_ (-1/2))) *
                     fromProb (nat_ 2 `thRootOf` (prob_ 3)) *
                     fromProb (nat_ 2
                               `thRootOf` (unsafeProb (recip (nat2real (size dataX125) *
                                                              summate (nat_ 0)
                                                                      (size dataX125)
                                                                      (\ x18127 ->
                                                                       dataX125 ! x18127
                                                                       ^ nat_ 2) *
                                                              real_ 10 +
                                                              summate (nat_ 0)
                                                                      (size dataX125)
                                                                      (\ x18128 ->
                                                                       dataX125
                                                                       ! x18128)
                                                              ^ nat_ 2 *
                                                              real_ (-10) +
                                                              nat2real (size dataX125 * nat_ 10) +
                                                              summate (nat_ 0)
                                                                      (size dataX125)
                                                                      (\ x18129 ->
                                                                       dataX125 ! x18129
                                                                       ^ nat_ 2) *
                                                              real_ 3 +
                                                              real_ 3)))) *
                     recip (nat2real (size dataX125) *
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18130 -> dataX125 ! x18130 ^ nat_ 2) *
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18131 -> x6126 ! x18131 ^ nat_ 2) *
                            real_ 10 +
                            nat2real (size dataX125) *
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18132 -> x6126 ! x18132 * dataX125 ! x18132)
                            ^ nat_ 2 *
                            real_ (-10) +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18133 -> dataX125 ! x18133 ^ nat_ 2) *
                            summate (nat_ 0) (size dataX125) (\ x18134 -> x6126 ! x18134)
                            ^ nat_ 2 *
                            real_ (-10) +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18135 -> x6126 ! x18135 ^ nat_ 2) *
                            summate (nat_ 0) (size dataX125) (\ x18136 -> dataX125 ! x18136)
                            ^ nat_ 2 *
                            real_ (-10) +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18137 -> x6126 ! x18137 * dataX125 ! x18137) *
                            summate (nat_ 0) (size dataX125) (\ x18138 -> dataX125 ! x18138) *
                            summate (nat_ 0) (size dataX125) (\ x18139 -> x6126 ! x18139) *
                            real_ 20 +
                            nat2real (size dataX125) *
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18140 -> dataX125 ! x18140 ^ nat_ 2) *
                            real_ 95 +
                            nat2real (size dataX125) *
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18141 -> x6126 ! x18141 ^ nat_ 2) *
                            real_ 10 +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18142 -> dataX125 ! x18142 ^ nat_ 2) *
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18143 -> x6126 ! x18143 ^ nat_ 2) *
                            real_ 3 +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18144 -> dataX125 ! x18144 ^ nat_ 2) *
                            summate (nat_ 0) (size dataX125) (\ x18145 -> x6126 ! x18145) *
                            real_ (-30) +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18146 -> x6126 ! x18146 * dataX125 ! x18146)
                            ^ nat_ 2 *
                            real_ (-3) +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18147 -> x6126 ! x18147 * dataX125 ! x18147) *
                            summate (nat_ 0) (size dataX125) (\ x18148 -> dataX125 ! x18148) *
                            real_ 30 +
                            summate (nat_ 0) (size dataX125) (\ x18149 -> dataX125 ! x18149)
                            ^ nat_ 2 *
                            real_ (-95) +
                            summate (nat_ 0) (size dataX125) (\ x18150 -> x6126 ! x18150)
                            ^ nat_ 2 *
                            real_ (-10) +
                            nat2real (size dataX125 * nat_ 95) +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18151 -> dataX125 ! x18151 ^ nat_ 2) *
                            real_ 6 +
                            summate (nat_ 0)
                                    (size dataX125)
                                    (\ x18152 -> x6126 ! x18152 ^ nat_ 2) *
                            real_ 3 +
                            summate (nat_ 0) (size dataX125) (\ x18153 -> x6126 ! x18153) *
                            real_ (-30) +
                            real_ 6) *
                     (nat2real (size dataX125) *
                      summate (nat_ 0)
                              (size dataX125)
                              (\ x18154 -> dataX125 ! x18154 ^ nat_ 2) *
                      real_ 10 +
                      summate (nat_ 0) (size dataX125) (\ x18155 -> dataX125 ! x18155)
                      ^ nat_ 2 *
                      real_ (-10) +
                      nat2real (size dataX125 * nat_ 10) +
                      summate (nat_ 0)
                              (size dataX125)
                              (\ x18156 -> dataX125 ! x18156 ^ nat_ 2) *
                      real_ 3 +
                      real_ 3) *
                     fromProb (unsafeProb (recip (nat2real (size dataX125) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18157 -> dataX125 ! x18157 ^ nat_ 2) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18158 -> x6126 ! x18158 ^ nat_ 2) *
                                                  real_ 10 +
                                                  nat2real (size dataX125) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18159 ->
                                                           x6126 ! x18159 *
                                                           dataX125 ! x18159)
                                                  ^ nat_ 2 *
                                                  real_ (-10) +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18160 -> dataX125 ! x18160 ^ nat_ 2) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18161 -> x6126 ! x18161)
                                                  ^ nat_ 2 *
                                                  real_ (-10) +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18162 -> x6126 ! x18162 ^ nat_ 2) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18163 -> dataX125 ! x18163)
                                                  ^ nat_ 2 *
                                                  real_ (-10) +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18164 ->
                                                           x6126 ! x18164 *
                                                           dataX125 ! x18164) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18165 -> dataX125 ! x18165) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18166 -> x6126 ! x18166) *
                                                  real_ 20 +
                                                  nat2real (size dataX125) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18167 -> dataX125 ! x18167 ^ nat_ 2) *
                                                  real_ 95 +
                                                  nat2real (size dataX125) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18168 -> x6126 ! x18168 ^ nat_ 2) *
                                                  real_ 10 +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18169 -> dataX125 ! x18169 ^ nat_ 2) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18170 -> x6126 ! x18170 ^ nat_ 2) *
                                                  real_ 3 +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18171 -> dataX125 ! x18171 ^ nat_ 2) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18172 -> x6126 ! x18172) *
                                                  real_ (-30) +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18173 ->
                                                           x6126 ! x18173 *
                                                           dataX125 ! x18173)
                                                  ^ nat_ 2 *
                                                  real_ (-3) +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18174 ->
                                                           x6126 ! x18174 *
                                                           dataX125 ! x18174) *
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18175 -> dataX125 ! x18175) *
                                                  real_ 30 +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18176 -> dataX125 ! x18176)
                                                  ^ nat_ 2 *
                                                  real_ (-95) +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18177 -> x6126 ! x18177)
                                                  ^ nat_ 2 *
                                                  real_ (-10) +
                                                  nat2real (size dataX125 * nat_ 95) +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18178 -> dataX125 ! x18178 ^ nat_ 2) *
                                                  real_ 6 +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18179 -> x6126 ! x18179 ^ nat_ 2) *
                                                  real_ 3 +
                                                  summate (nat_ 0)
                                                          (size dataX125)
                                                          (\ x18180 -> x6126 ! x18180) *
                                                  real_ (-30) +
                                                  real_ 6) *
                                           (nat2real (size dataX125) *
                                            summate (nat_ 0)
                                                    (size dataX125)
                                                    (\ x18181 -> dataX125 ! x18181 ^ nat_ 2) *
                                            real_ 10 +
                                            summate (nat_ 0)
                                                    (size dataX125)
                                                    (\ x18182 -> dataX125 ! x18182)
                                            ^ nat_ 2 *
                                            real_ (-10) +
                                            nat2real (size dataX125 * nat_ 10) +
                                            summate (nat_ 0)
                                                    (size dataX125)
                                                    (\ x18183 -> dataX125 ! x18183 ^ nat_ 2) *
                                            real_ 3 +
                                            real_ 3))
                               ** (nat2real (size dataX125) * real_ (1/2))) *
                     fromProb (gammaFunc (real_ 1 +
                                          nat2real (size dataX125) * real_ (1/2))) *
                     real_ 2)) $
        (gamma (prob_ 1 + nat2prob (size dataX125) * prob_ (1/2))
               (unsafeProb (recip (nat2real (size dataX125) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18185 -> dataX125 ! x18185 ^ nat_ 2) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18186 -> x6126 ! x18186 ^ nat_ 2) *
                                   real_ 10 +
                                   nat2real (size dataX125) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18187 -> x6126 ! x18187 * dataX125 ! x18187)
                                   ^ nat_ 2 *
                                   real_ (-10) +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18188 -> dataX125 ! x18188 ^ nat_ 2) *
                                   summate (nat_ 0) (size dataX125) (\ x18189 -> x6126 ! x18189)
                                   ^ nat_ 2 *
                                   real_ (-10) +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18190 -> x6126 ! x18190 ^ nat_ 2) *
                                   summate (nat_ 0) (size dataX125) (\ x18191 -> dataX125 ! x18191)
                                   ^ nat_ 2 *
                                   real_ (-10) +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18192 -> x6126 ! x18192 * dataX125 ! x18192) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18193 -> dataX125 ! x18193) *
                                   summate (nat_ 0) (size dataX125) (\ x18194 -> x6126 ! x18194) *
                                   real_ 20 +
                                   nat2real (size dataX125) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18195 -> dataX125 ! x18195 ^ nat_ 2) *
                                   real_ 95 +
                                   nat2real (size dataX125) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18196 -> x6126 ! x18196 ^ nat_ 2) *
                                   real_ 10 +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18197 -> dataX125 ! x18197 ^ nat_ 2) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18198 -> x6126 ! x18198 ^ nat_ 2) *
                                   real_ 3 +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18199 -> dataX125 ! x18199 ^ nat_ 2) *
                                   summate (nat_ 0) (size dataX125) (\ x18200 -> x6126 ! x18200) *
                                   real_ (-30) +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18201 -> x6126 ! x18201 * dataX125 ! x18201)
                                   ^ nat_ 2 *
                                   real_ (-3) +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18202 -> x6126 ! x18202 * dataX125 ! x18202) *
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18203 -> dataX125 ! x18203) *
                                   real_ 30 +
                                   summate (nat_ 0) (size dataX125) (\ x18204 -> dataX125 ! x18204)
                                   ^ nat_ 2 *
                                   real_ (-95) +
                                   summate (nat_ 0) (size dataX125) (\ x18205 -> x6126 ! x18205)
                                   ^ nat_ 2 *
                                   real_ (-10) +
                                   nat2real (size dataX125 * nat_ 95) +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18206 -> dataX125 ! x18206 ^ nat_ 2) *
                                   real_ 6 +
                                   summate (nat_ 0)
                                           (size dataX125)
                                           (\ x18207 -> x6126 ! x18207 ^ nat_ 2) *
                                   real_ 3 +
                                   summate (nat_ 0) (size dataX125) (\ x18208 -> x6126 ! x18208) *
                                   real_ (-30) +
                                   real_ 6) *
                            (nat2real (size dataX125) *
                             summate (nat_ 0)
                                     (size dataX125)
                                     (\ x18209 -> dataX125 ! x18209 ^ nat_ 2) *
                             real_ 10 +
                             summate (nat_ 0) (size dataX125) (\ x18210 -> dataX125 ! x18210)
                             ^ nat_ 2 *
                             real_ (-10) +
                             nat2real (size dataX125 * nat_ 10) +
                             summate (nat_ 0)
                                     (size dataX125)
                                     (\ x18211 -> dataX125 ! x18211 ^ nat_ 2) *
                             real_ 3 +
                             real_ 3) *
                            real_ 2)) >>= \ invNoiseb184 ->
         normal ((nat2real (size dataX125) *
                  summate (nat_ 0)
                          (size dataX125)
                          (\ x18213 -> x6126 ! x18213 * dataX125 ! x18213) *
                  real_ 10 +
                  summate (nat_ 0) (size dataX125) (\ x18214 -> dataX125 ! x18214) *
                  summate (nat_ 0) (size dataX125) (\ x18215 -> x6126 ! x18215) *
                  real_ (-10) +
                  summate (nat_ 0)
                          (size dataX125)
                          (\ x18216 -> x6126 ! x18216 * dataX125 ! x18216) *
                  real_ 3 +
                  summate (nat_ 0) (size dataX125) (\ x18217 -> dataX125 ! x18217) *
                  real_ (-15)) *
                 recip (nat2real (size dataX125) *
                        summate (nat_ 0)
                                (size dataX125)
                                (\ x18218 -> dataX125 ! x18218 ^ nat_ 2) *
                        real_ 10 +
                        summate (nat_ 0) (size dataX125) (\ x18219 -> dataX125 ! x18219)
                        ^ nat_ 2 *
                        real_ (-10) +
                        nat2real (size dataX125 * nat_ 10) +
                        summate (nat_ 0)
                                (size dataX125)
                                (\ x18220 -> dataX125 ! x18220 ^ nat_ 2) *
                        real_ 3 +
                        real_ 3))
                (recip (nat_ 2 `thRootOf` invNoiseb184) *
                 nat_ 2
                 `thRootOf` (unsafeProb (recip (nat2real (size dataX125) *
                                                summate (nat_ 0)
                                                        (size dataX125)
                                                        (\ x18221 -> dataX125 ! x18221 ^ nat_ 2) *
                                                real_ 10 +
                                                summate (nat_ 0)
                                                        (size dataX125)
                                                        (\ x18222 -> dataX125 ! x18222)
                                                ^ nat_ 2 *
                                                real_ (-10) +
                                                nat2real (size dataX125 * nat_ 10) +
                                                summate (nat_ 0)
                                                        (size dataX125)
                                                        (\ x18223 -> dataX125 ! x18223 ^ nat_ 2) *
                                                real_ 3 +
                                                real_ 3) *
                                         nat2real (size dataX125 * nat_ 10 +
                                                   nat_ 3)))) >>= \ a9212 ->
         normal ((summate (nat_ 0)
                          (size dataX125)
                          (\ x18225 -> dataX125 ! x18225) *
                  a9212 *
                  real_ 2 +
                  summate (nat_ 0) (size dataX125) (\ x18226 -> x6126 ! x18226) *
                  real_ (-2) +
                  real_ (-3)) *
                 fromProb (recip (nat2prob (size dataX125 * nat_ 10 + nat_ 3))) *
                 real_ (-5))
                (nat_ 2 `thRootOf` (prob_ 10) *
                 recip (nat_ 2 `thRootOf` invNoiseb184) *
                 nat_ 2
                 `thRootOf` (recip (nat2prob (size dataX125 * nat_ 10 +
                                              nat_ 3)))) >>= \ b7224 ->
         dirac (arrayLit [a9212, b7224, fromProb invNoiseb184])))

