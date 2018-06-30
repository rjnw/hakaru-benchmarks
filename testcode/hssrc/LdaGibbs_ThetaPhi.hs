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
  ((MayBoxVec Prob Prob) ->
   ((MayBoxVec Prob Prob) ->
    (Int ->
     ((MayBoxVec Int Int) ->
      ((MayBoxVec Int Int) ->
       ((MayBoxVec Int Int) ->
        (Measure
           ((MayBoxVec (MayBoxVec Prob Prob) (MayBoxVec Prob Prob)),
            (MayBoxVec (MayBoxVec Prob Prob) (MayBoxVec Prob Prob))))))))))
prog =
  summarize lam $ \ topic_prior25 ->
            lam $ \ word_prior26 ->
            lam $ \ numDocs27 ->
            lam $ \ w28 ->
            lam $ \ doc29 ->
            lam $ \ z30 ->
            (pose (product (nat_ 0)
                           (size topic_prior25)
                           (\ d31 ->
                            product (nat_ 0)
                                    (size word_prior26)
                                    (\ iB32 ->
                                     product (nat_ 0)
                                             (summate (nat_ 0)
                                                      (size w28)
                                                      (\ dL34 ->
                                                       case_ (iB32 == w28 ! dL34 &&
                                                              d31 == z30 ! dL34)
                                                             [branch ptrue (nat_ 1),
                                                              branch pfalse (nat_ 0)]))
                                             (\ j33 -> nat2prob j33 + word_prior26 ! iB32))) *
                   product (nat_ 0)
                           numDocs27
                           (\ d35 ->
                            product (nat_ 0)
                                    (size topic_prior25)
                                    (\ i1236 ->
                                     product (nat_ 0)
                                             (summate (nat_ 0)
                                                      (size w28)
                                                      (\ dL38 ->
                                                       case_ (d35 == doc29 ! dL38 &&
                                                              i1236 == z30 ! dL38)
                                                             [branch ptrue (nat_ 1),
                                                              branch pfalse (nat_ 0)]))
                                             (\ j37 -> nat2prob j37 + topic_prior25 ! i1236))) *
                   recip (product (nat_ 0)
                                  numDocs27
                                  (\ d39 ->
                                   product (nat_ 0)
                                           (summate (nat_ 0)
                                                    (size w28)
                                                    (\ dL41 ->
                                                     case_ (d39 == doc29 ! dL41)
                                                           [branch ptrue (nat_ 1),
                                                            branch pfalse (nat_ 0)]))
                                           (\ i1240 ->
                                            nat2prob i1240 +
                                            summate (nat_ 0)
                                                    (size topic_prior25)
                                                    (\ dL42 -> topic_prior25 ! dL42)))) *
                   recip (product (nat_ 0)
                                  (size topic_prior25)
                                  (\ d43 ->
                                   product (nat_ 0)
                                           (summate (nat_ 0)
                                                    (size w28)
                                                    (\ dL45 ->
                                                     case_ (d43 == z30 ! dL45)
                                                           [branch ptrue (nat_ 1),
                                                            branch pfalse (nat_ 0)]))
                                           (\ iB44 ->
                                            nat2prob iB44 +
                                            summate (nat_ 0)
                                                    (size word_prior26)
                                                    (\ dL46 -> word_prior26 ! dL46))))) $
                  ((plate numDocs27 $
                          \ d48 ->
                          (plate (unsafeNat (nat2int (size topic_prior25) + int_ -1)) $
                                 \ i49 ->
                                 beta (nat2prob (summate (nat_ 0)
                                                         (size w28)
                                                         (\ dL50 ->
                                                          case_ (not (nat2int (z30 ! dL50) + int_ -1
                                                                      < nat2int i49) &&
                                                                 d48 == doc29 ! dL50)
                                                                [branch ptrue (nat_ 1),
                                                                 branch pfalse (nat_ 0)])) +
                                       summate (i49 + nat_ 1)
                                               (size topic_prior25)
                                               (\ dL51 -> topic_prior25 ! dL51))
                                      (nat2prob (summate (nat_ 0)
                                                         (size w28)
                                                         (\ dL52 ->
                                                          case_ (not (z30 ! dL52 + nat_ 1
                                                                      == size topic_prior25) &&
                                                                 d48 == doc29 ! dL52 &&
                                                                 i49 == z30 ! dL52)
                                                                [branch ptrue (nat_ 1),
                                                                 branch pfalse (nat_ 0)])) +
                                       topic_prior25 ! i49))) >>= \ xsh47 ->
                   (plate (size topic_prior25) $
                          \ k54 ->
                          (plate (unsafeNat (nat2int (size word_prior26) + int_ -1)) $
                                 \ i55 ->
                                 beta (nat2prob (summate (nat_ 0)
                                                         (size w28)
                                                         (\ kp56 ->
                                                          case_ (not (nat2int (w28 ! kp56) + int_ -1
                                                                      < nat2int i55) &&
                                                                 k54 == z30 ! kp56)
                                                                [branch ptrue (nat_ 1),
                                                                 branch pfalse (nat_ 0)])) +
                                       summate (i55 + nat_ 1)
                                               (size word_prior26)
                                               (\ kp57 -> word_prior26 ! kp57))
                                      (nat2prob (summate (nat_ 0)
                                                         (size w28)
                                                         (\ kp58 ->
                                                          case_ (not (w28 ! kp58 + nat_ 1
                                                                      == size word_prior26) &&
                                                                 k54 == z30 ! kp58 &&
                                                                 i55 == w28 ! kp58)
                                                                [branch ptrue (nat_ 1),
                                                                 branch pfalse (nat_ 0)])) +
                                       word_prior26 ! i55))) >>= \ xsf53 ->
                   dirac (ann_ (SData (STyApp (STyApp (STyCon (SingSymbol :: Sing "Pair")) (SArray (SArray SProb))) (SArray (SArray SProb))) (SPlus (SEt (SKonst (SArray (SArray SProb))) (SEt (SKonst (SArray (SArray SProb))) SDone)) SVoid))
                               ((pair (array numDocs27 $
                                             \ d59 ->
                                             (array (size topic_prior25) $
                                                    \ i60 ->
                                                    unsafeProb (case_ (i60 + nat_ 1
                                                                       == size topic_prior25)
                                                                      [branch ptrue (real_ 1),
                                                                       branch pfalse
                                                                              (real_ 1 +
                                                                               fromProb (xsh47 ! d59
                                                                                         ! i60) *
                                                                               real_ (-1))]) *
                                                    product (nat_ 0)
                                                            i60
                                                            (\ j61 -> xsh47 ! d59 ! j61)))
                                      (array (size topic_prior25) $
                                             \ k62 ->
                                             (array (size word_prior26) $
                                                    \ i63 ->
                                                    unsafeProb (case_ (i63 + nat_ 1
                                                                       == size word_prior26)
                                                                      [branch ptrue (real_ 1),
                                                                       branch pfalse
                                                                              (real_ 1 +
                                                                               fromProb (xsf53 ! k62
                                                                                         ! i63) *
                                                                               real_ (-1))]) *
                                                    product (nat_ 0)
                                                            i63
                                                            (\ j64 -> xsf53 ! k62 ! j64))))))))

