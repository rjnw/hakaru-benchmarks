{-# LANGUAGE DataKinds, NegativeLiterals #-}
module LdaGibbs.LdaLikelihood where

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
    (Int ->
     ((MayBoxVec Int Int) ->
      ((MayBoxVec Int Int) -> ((MayBoxVec Int Int) -> Prob))))))
prog =
  lam $ \ topic_prior47 ->
  lam $ \ word_prior48 ->
  lam $ \ numDocs49 ->
  lam $ \ w50 ->
  lam $ \ doc51 ->
  lam $ \ z52 ->
         (product (nat_ 0)
                 (size topic_prior47)
                 (\ d53 ->
                  product (nat_ 0)
                          (size word_prior48)
                          (\ iB54 ->
                           product (nat_ 0)
                                   (let_ (bucket (nat_ 0)
                                                 (size w50)
                                                 ((r_index (\ () -> size word_prior48)
                                                           (\ (iHJ57,()) -> w50 ! iHJ57)
                                                           (r_index (\ (iB58,()) ->
                                                                     size topic_prior47)
                                                                    (\ (iHJ57,(iB58,())) ->
                                                                     z52
                                                                     ! iHJ57)
                                                                    (r_add (\ (iHJ57,(d59,(iB58,()))) ->
                                                                            nat_ 1)))))) $ \ summary56 ->
                                    summary56 ! iB54
                                    ! d53)
                                   (\ j55 -> nat2prob j55 + word_prior48 ! iB54))) *
         product (nat_ 0)
                 numDocs49
                 (\ d60 ->
                  product (nat_ 0)
                          (size topic_prior47)
                          (\ iH61 ->
                           product (nat_ 0)
                                   (let_ (bucket (nat_ 0)
                                                 (size w50)
                                                 ((r_index (\ () -> numDocs49)
                                                           (\ (iHJ64,()) -> doc51 ! iHJ64)
                                                           (r_index (\ (d65,()) ->
                                                                     size topic_prior47)
                                                                    (\ (iHJ64,(d65,())) ->
                                                                     z52
                                                                     ! iHJ64)
                                                                    (r_add (\ (iHJ64,(iH66,(d65,()))) ->
                                                                            nat_ 1)))))) $ \ summary63 ->
                                    summary63 ! d60
                                    ! iH61)
                                   (\ j62 -> nat2prob j62 + topic_prior47 ! iH61))) *
         recip (product (nat_ 0)
                        numDocs49
                        (\ d67 ->
                         product (nat_ 0)
                                 (let_ (bucket (nat_ 0)
                                               (size w50)
                                               ((r_index (\ () -> numDocs49)
                                                         (\ (iHJ70,()) -> doc51 ! iHJ70)
                                                         (r_add (\ (iHJ70,(d71,())) ->
                                                                 nat_ 1))))) $ \ summary69 ->
                                  summary69
                                  ! d67)
                                 (\ iH68 ->
                                  nat2prob iH68 +
                                  summate (nat_ 0)
                                          (size topic_prior47)
                                          (\ iHJ72 -> topic_prior47 ! iHJ72)))) *
         recip (product (nat_ 0)
                        (size topic_prior47)
                        (\ d73 ->
                         product (nat_ 0)
                                 (let_ (bucket (nat_ 0)
                                               (size w50)
                                               ((r_index (\ () -> size topic_prior47)
                                                         (\ (iHJ76,()) -> z52 ! iHJ76)
                                                         (r_add (\ (iHJ76,(d77,())) ->
                                                                 nat_ 1))))) $ \ summary75 ->
                                  summary75
                                  ! d73)
                                 (\ iB74 ->
                                  nat2prob iB74 +
                                  summate (nat_ 0)
                                          (size word_prior48)
                                          (\ iHJ78 -> word_prior48 ! iHJ78)))))
