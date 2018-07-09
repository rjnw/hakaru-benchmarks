{-# LANGUAGE DataKinds, NegativeLiterals #-}
module NaiveBayesGibbs.NaiveBayesLikelihood where

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
   ((MayBoxVec Prob Prob) ->
    ((MayBoxVec Int Int) ->
     ((MayBoxVec Int Int) -> ((MayBoxVec Int Int) -> Prob)))))
prog =
  lam $ \ topic_prior41 ->
  lam $ \ word_prior42 ->
  lam $ \ z43 ->
  lam $ \ w44 ->
  lam $ \ doc45 ->
        (product (nat_ 0)
                 (size topic_prior41)
                 (\ i46 ->
                  product (nat_ 0)
                          (size word_prior42)
                          (\ iv47 ->
                           product (nat_ 0)
                                   (let_ (bucket (nat_ 0)
                                                 (size w44)
                                                 ((r_index (\ () -> size word_prior42)
                                                           (\ (iDF50,()) -> w44 ! iDF50)
                                                           (r_index (\ (iv51,()) ->
                                                                     size topic_prior41)
                                                                    (\ (iDF50,(iv51,())) ->
                                                                     z43
                                                                     ! (doc45 ! iDF50))
                                                                    (r_add (\ (iDF50,(i52,(iv51,()))) ->
                                                                            nat_ 1)))))) $ \ summary49 ->
                                    summary49 ! iv47
                                    ! i46)
                                   (\ j48 -> nat2prob j48 + word_prior42 ! iv47))) *
         product (nat_ 0)
                 (size topic_prior41)
                 (\ i53 ->
                  product (nat_ 0)
                          (let_ (bucket (nat_ 0)
                                        (size z43)
                                        ((r_index (\ () -> size topic_prior41)
                                                  (\ (iDF56,()) -> z43 ! iDF56)
                                                  (r_add (\ (iDF56,(i57,())) ->
                                                          nat_ 1))))) $ \ summary55 ->
                           summary55
                           ! i53)
                          (\ j54 -> nat2prob j54 + topic_prior41 ! i53)) *
         recip (product (nat_ 0)
                        (summate (nat_ 0) (size z43) (\ iDF59 -> nat_ 1))
                        (\ i58 ->
                         nat2prob i58 +
                         summate (nat_ 0)
                                 (size topic_prior41)
                                 (\ iDF60 -> topic_prior41 ! iDF60))) *
         recip (product (nat_ 0)
                        (size topic_prior41)
                        (\ i61 ->
                         product (nat_ 0)
                                 (let_ (bucket (nat_ 0)
                                               (size w44)
                                               ((r_index (\ () -> size topic_prior41)
                                                         (\ (iDF64,()) -> z43 ! (doc45 ! iDF64))
                                                         (r_add (\ (iDF64,(i65,())) ->
                                                                 nat_ 1))))) $ \ summary63 ->
                                  summary63
                                  ! i61)
                                 (\ iv62 ->
                                  nat2prob iv62 +
                                  summate (nat_ 0)
                                          (size word_prior42)
                                          (\ iDF66 -> word_prior42 ! iDF66)))))
