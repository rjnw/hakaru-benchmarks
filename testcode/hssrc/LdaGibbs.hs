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
       ((MayBoxVec Int Int) -> (Int -> (Measure Int))))))))
prog =
  lam $ \ topic_prior59 ->
  lam $ \ word_prior60 ->
  lam $ \ numDocs61 ->
  lam $ \ w62 ->
  lam $ \ doc63 ->
  lam $ \ z64 ->
  lam $ \ wordUpdate65 ->
  case_ (wordUpdate65 < size w62 &&
         doc63 ! wordUpdate65 < numDocs61 &&
         w62 ! wordUpdate65 < size word_prior60)
        [branch ptrue
                ((pose (product (nat_ 0)
                                numDocs61
                                (\ d66 ->
                                 product (nat_ 0)
                                         (size topic_prior59)
                                         (\ iH67 ->
                                          product (nat_ 0)
                                                  (let_ (bucket (nat_ 0)
                                                                (size w62)
                                                                ((r_index (\ () -> numDocs61)
                                                                          (\ (iB70,()) ->
                                                                           doc63
                                                                           ! iB70)
                                                                          (r_index (\ (d71,()) ->
                                                                                    size topic_prior59)
                                                                                   (\ (iB70,(d71,())) ->
                                                                                    z64
                                                                                    ! iB70)
                                                                                   (r_add (\ (iB70,(iH72,(d71,()))) ->
                                                                                           nat_ 1)))))) $ \ summary69 ->
                                                   unsafeNat (nat2int (case_ (d66
                                                                              == doc63
                                                                                 ! wordUpdate65 &&
                                                                              not (nat2int (size topic_prior59) +
                                                                                   int_ -1
                                                                                   < nat2int (z64
                                                                                              ! wordUpdate65)) &&
                                                                              iH67
                                                                              == z64 ! wordUpdate65)
                                                                             [branch ptrue (nat_ 1),
                                                                              branch pfalse
                                                                                     (nat_ 0)]) *
                                                              int_ -1 +
                                                              nat2int (summary69 ! d66 ! iH67)))
                                                  (\ j68 -> nat2prob j68 + topic_prior59 ! iH67))) *
                        recip (product (nat_ 0)
                                       numDocs61
                                       (\ d73 ->
                                        product (nat_ 0)
                                                (let_ (bucket (nat_ 0)
                                                              (size w62)
                                                              ((r_index (\ () -> numDocs61)
                                                                        (\ (iB76,()) ->
                                                                         doc63
                                                                         ! iB76)
                                                                        (r_add (\ (iB76,(d77,())) ->
                                                                                nat_ 1))))) $ \ summary75 ->
                                                 unsafeNat (nat2int (case_ (d73
                                                                            == doc63 ! wordUpdate65)
                                                                           [branch ptrue (nat_ 1),
                                                                            branch pfalse
                                                                                   (nat_ 0)]) *
                                                            int_ -1 +
                                                            nat2int (summary75 ! d73)))
                                                (\ iH74 ->
                                                 nat2prob iH74 +
                                                 summate (nat_ 0)
                                                         (size topic_prior59)
                                                         (\ iB78 -> topic_prior59 ! iB78)))) *
                        product (nat_ 0)
                                (size topic_prior59)
                                (\ d79 ->
                                 product (nat_ 0)
                                         (size word_prior60)
                                         (\ ir80 ->
                                          product (nat_ 0)
                                                  (let_ (bucket (nat_ 0)
                                                                (size w62)
                                                                ((r_index (\ () ->
                                                                           size word_prior60)
                                                                          (\ (iB83,()) ->
                                                                           w62
                                                                           ! iB83)
                                                                          (r_index (\ (ir84,()) ->
                                                                                    size topic_prior59)
                                                                                   (\ (iB83,(ir84,())) ->
                                                                                    z64
                                                                                    ! iB83)
                                                                                   (r_add (\ (iB83,(d85,(ir84,()))) ->
                                                                                           nat_ 1)))))) $ \ summary82 ->
                                                   unsafeNat (nat2int (case_ (ir80
                                                                              == w62
                                                                                 ! wordUpdate65 &&
                                                                              not (nat2int (size topic_prior59) +
                                                                                   int_ -1
                                                                                   < nat2int (z64
                                                                                              ! wordUpdate65)) &&
                                                                              d79
                                                                              == z64 ! wordUpdate65)
                                                                             [branch ptrue (nat_ 1),
                                                                              branch pfalse
                                                                                     (nat_ 0)]) *
                                                              int_ -1 +
                                                              nat2int (summary82 ! ir80 ! d79)))
                                                  (\ j81 -> nat2prob j81 + word_prior60 ! ir80))) *
                        recip (product (nat_ 0)
                                       (size topic_prior59)
                                       (\ d86 ->
                                        product (nat_ 0)
                                                (let_ (bucket (nat_ 0)
                                                              (size w62)
                                                              ((r_index (\ () -> size topic_prior59)
                                                                        (\ (iB89,()) -> z64 ! iB89)
                                                                        (r_add (\ (iB89,(d90,())) ->
                                                                                nat_ 1))))) $ \ summary88 ->
                                                 unsafeNat (nat2int (case_ (not (nat2int (size topic_prior59) +
                                                                                 int_ -1
                                                                                 < nat2int (z64
                                                                                            ! wordUpdate65)) &&
                                                                            d86
                                                                            == z64 ! wordUpdate65)
                                                                           [branch ptrue (nat_ 1),
                                                                            branch pfalse
                                                                                   (nat_ 0)]) *
                                                            int_ -1 +
                                                            nat2int (summary88 ! d86)))
                                                (\ ir87 ->
                                                 nat2prob ir87 +
                                                 summate (nat_ 0)
                                                         (size word_prior60)
                                                         (\ iB91 -> word_prior60 ! iB91)))) *
                        recip (nat2prob (summate (nat_ 0)
                                                 (size w62)
                                                 (\ iB92 ->
                                                  case_ (iB92 == wordUpdate65)
                                                        [branch ptrue (nat_ 0),
                                                         branch pfalse
                                                                (case_ (doc63 ! wordUpdate65
                                                                        == doc63 ! iB92)
                                                                       [branch ptrue (nat_ 1),
                                                                        branch pfalse
                                                                               (nat_ 0)])])) +
                               summate (nat_ 0)
                                       (size topic_prior59)
                                       (\ iB93 -> topic_prior59 ! iB93))) $
                       (categorical (array (size topic_prior59) $
                                           \ zNewh94 ->
                                           unsafeProb ((fromInt (let_ (bucket (nat_ 0)
                                                                              (size w62)
                                                                              ((r_index (\ () ->
                                                                                         size topic_prior59)
                                                                                        (\ (iB96,()) ->
                                                                                         z64
                                                                                         ! iB96)
                                                                                        (r_split (\ (iB96,(zNewh97,())) ->
                                                                                                  doc63
                                                                                                  ! wordUpdate65
                                                                                                  == doc63
                                                                                                     ! iB96)
                                                                                                 (r_add (\ (iB96,(zNewh97,())) ->
                                                                                                         nat_ 1))
                                                                                                 r_nop)))) $ \ summary95 ->
                                                                 nat2int (case_ (not (nat2int (size topic_prior59) +
                                                                                      int_ -1
                                                                                      < nat2int (z64
                                                                                                 ! wordUpdate65)) &&
                                                                                 zNewh94
                                                                                 == z64
                                                                                    ! wordUpdate65)
                                                                                [branch ptrue
                                                                                        (nat_ 1),
                                                                                 branch pfalse
                                                                                        (nat_ 0)]) *
                                                                 int_ -1 +
                                                                 nat2int (case_ (summary95
                                                                                 ! zNewh94)
                                                                                [branch (ppair PVar
                                                                                               PVar)
                                                                                        (\ y98
                                                                                           z99 ->
                                                                                         y98)])) +
                                                        fromProb (topic_prior59 ! zNewh94)) *
                                                       (fromInt (let_ (bucket (nat_ 0)
                                                                              (size w62)
                                                                              ((r_index (\ () ->
                                                                                         size topic_prior59)
                                                                                        (\ (iB101,()) ->
                                                                                         z64
                                                                                         ! iB101)
                                                                                        (r_split (\ (iB101,(zNewh102,())) ->
                                                                                                  w62
                                                                                                  ! wordUpdate65
                                                                                                  == w62
                                                                                                     ! iB101)
                                                                                                 (r_add (\ (iB101,(zNewh102,())) ->
                                                                                                         nat_ 1))
                                                                                                 r_nop)))) $ \ summary100 ->
                                                                 nat2int (case_ (not (nat2int (size topic_prior59) +
                                                                                      int_ -1
                                                                                      < nat2int (z64
                                                                                                 ! wordUpdate65)) &&
                                                                                 zNewh94
                                                                                 == z64
                                                                                    ! wordUpdate65)
                                                                                [branch ptrue
                                                                                        (nat_ 1),
                                                                                 branch pfalse
                                                                                        (nat_ 0)]) *
                                                                 int_ -1 +
                                                                 nat2int (case_ (summary100
                                                                                 ! zNewh94)
                                                                                [branch (ppair PVar
                                                                                               PVar)
                                                                                        (\ y103
                                                                                           z104 ->
                                                                                         y103)])) +
                                                        fromProb (word_prior60
                                                                  ! (w62 ! wordUpdate65))) *
                                                       recip (fromInt (let_ (bucket (nat_ 0)
                                                                                    (size w62)
                                                                                    ((r_index (\ () ->
                                                                                               size topic_prior59)
                                                                                              (\ (iB106,()) ->
                                                                                               z64
                                                                                               ! iB106)
                                                                                              (r_add (\ (iB106,(zNewh107,())) ->
                                                                                                      nat_ 1))))) $ \ summary105 ->
                                                                       nat2int (case_ (not (nat2int (size topic_prior59) +
                                                                                            int_ -1
                                                                                            < nat2int (z64
                                                                                                       ! wordUpdate65)) &&
                                                                                       zNewh94
                                                                                       == z64
                                                                                          ! wordUpdate65)
                                                                                      [branch ptrue
                                                                                              (nat_ 1),
                                                                                       branch pfalse
                                                                                              (nat_ 0)]) *
                                                                       int_ -1 +
                                                                       nat2int (summary105
                                                                                ! zNewh94)) +
                                                              fromProb (summate (nat_ 0)
                                                                                (size word_prior60)
                                                                                (\ iB108 ->
                                                                                 word_prior60
                                                                                 ! iB108)))))))),
         branch pfalse
                (case_ (not (wordUpdate65 < size w62))
                       [branch ptrue (reject),
                        branch pfalse
                               (case_ (not (doc63 ! wordUpdate65 < numDocs61))
                                      [branch ptrue (reject), branch pfalse (reject)])])]

