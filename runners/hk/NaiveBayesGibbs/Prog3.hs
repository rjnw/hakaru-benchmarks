{-# LANGUAGE DataKinds, NegativeLiterals #-}
module NaiveBayesGibbs.Prog3 where

import           Data.Number.LogFloat (LogFloat)
import           Prelude hiding (product, exp, log, (**))
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
     ((MayBoxVec Int Int) ->
      ((MayBoxVec Int Int) -> (Int -> (Measure Int)))))))
prog =
  lam $ \ topic_prior60 ->
  lam $ \ word_prior61 ->
  lam $ \ z62 ->
  lam $ \ w63 ->
  lam $ \ doc64 ->
  lam $ \ docUpdate65 ->
  case_ (docUpdate65 < size z62)
        [branch ptrue
                ((pose (product (nat_ 0)
                                (size topic_prior60)
                                (\ i66 ->
                                 product (nat_ 0)
                                         (let_ (bucket (nat_ 0)
                                                       (size z62)
                                                       ((r_index (\ () -> size topic_prior60)
                                                                 (\ (iF69,()) -> z62 ! iF69)
                                                                 (r_add (\ (iF69,(i70,())) ->
                                                                         nat_ 1))))) $ \ summary68 ->
                                          unsafeNat (nat2int (case_ (not (nat2int (size topic_prior60) +
                                                                          int_ -1
                                                                          < nat2int (z62
                                                                                     ! docUpdate65)) &&
                                                                     i66 == z62 ! docUpdate65)
                                                                    [branch ptrue (nat_ 1),
                                                                     branch pfalse (nat_ 0)]) *
                                                     int_ -1) +
                                          summary68 ! i66)
                                         (\ j67 -> nat2prob j67 + topic_prior60 ! i66)) *
                        product (nat_ 0)
                                (size topic_prior60)
                                (\ i71 ->
                                 product (nat_ 0)
                                         (size word_prior61)
                                         (\ iB72 ->
                                          product (nat_ 0)
                                                  (let_ (bucket (nat_ 0)
                                                                (size w63)
                                                                ((r_split (\ (iF75,()) ->
                                                                           docUpdate65
                                                                           == doc64 ! iF75)
                                                                          r_nop
                                                                          (r_index (\ () ->
                                                                                    size word_prior61)
                                                                                   (\ (iF75,()) ->
                                                                                    w63
                                                                                    ! iF75)
                                                                                   (r_index (\ (iB76,()) ->
                                                                                             size topic_prior60)
                                                                                            (\ (iF75,(iB76,())) ->
                                                                                             z62
                                                                                             ! (doc64
                                                                                                ! iF75))
                                                                                            (r_add (\ (iF75,(i77,(iB76,()))) ->
                                                                                                    nat_ 1))))))) $ \ summary74 ->
                                                   case_ summary74
                                                         [branch (ppair PVar PVar)
                                                                 (\ y78 z79 -> z79)]
                                                   ! iB72
                                                   ! i71)
                                                  (\ j73 -> nat2prob j73 + word_prior61 ! iB72))) *
                        recip (product (nat_ 0)
                                       (summate (nat_ 0)
                                                (size z62)
                                                (\ iF81 ->
                                                 case_ (iF81 == docUpdate65)
                                                       [branch ptrue (nat_ 0),
                                                        branch pfalse (nat_ 1)]))
                                       (\ i80 ->
                                        nat2prob i80 +
                                        summate (nat_ 0)
                                                (size topic_prior60)
                                                (\ iF82 -> topic_prior60 ! iF82))) *
                        recip (product (nat_ 0)
                                       (size topic_prior60)
                                       (\ i83 ->
                                        product (nat_ 0)
                                                (let_ (bucket (nat_ 0)
                                                              (size w63)
                                                              ((r_split (\ (iF86,()) ->
                                                                         docUpdate65
                                                                         == doc64 ! iF86)
                                                                        r_nop
                                                                        (r_index (\ () ->
                                                                                  size topic_prior60)
                                                                                 (\ (iF86,()) ->
                                                                                  z62
                                                                                  ! (doc64 ! iF86))
                                                                                 (r_add (\ (iF86,(i87,())) ->
                                                                                         nat_ 1)))))) $ \ summary85 ->
                                                 case_ summary85
                                                       [branch (ppair PVar PVar) (\ y88 z89 -> z89)]
                                                 ! i83)
                                                (\ iB84 ->
                                                 nat2prob iB84 +
                                                 summate (nat_ 0)
                                                         (size word_prior61)
                                                         (\ iF90 -> word_prior61 ! iF90)))) *
                        recip (nat2prob (summate (nat_ 0)
                                                 (size z62)
                                                 (\ iF91 ->
                                                  case_ (iF91 == docUpdate65)
                                                        [branch ptrue (nat_ 0),
                                                         branch pfalse (nat_ 1)])) +
                               summate (nat_ 0)
                                       (size topic_prior60)
                                       (\ iF92 -> topic_prior60 ! iF92))) $
                       (categorical (array (size topic_prior60) $
                                           \ zNewf93 ->
                                           unsafeProb (fromInt (let_ (bucket (nat_ 0)
                                                                             (size z62)
                                                                             ((r_index (\ () ->
                                                                                        size topic_prior60)
                                                                                       (\ (iF95,()) ->
                                                                                        z62
                                                                                        ! iF95)
                                                                                       (r_add (\ (iF95,(zNewf96,())) ->
                                                                                               nat_ 1))))) $ \ summary94 ->
                                                                nat2int (case_ (not (nat2int (size topic_prior60) +
                                                                                     int_ -1
                                                                                     < nat2int (z62
                                                                                                ! docUpdate65)) &&
                                                                                zNewf93
                                                                                == z62
                                                                                   ! docUpdate65)
                                                                               [branch ptrue
                                                                                       (nat_ 1),
                                                                                branch pfalse
                                                                                       (nat_ 0)]) *
                                                                int_ -1 +
                                                                nat2int (summary94 ! zNewf93)) +
                                                       fromProb (topic_prior60 ! zNewf93)) *
                                           product (nat_ 0)
                                                   (size topic_prior60)
                                                   (\ i97 ->
                                                    product (nat_ 0)
                                                            (size word_prior61)
                                                            (\ iB98 ->
                                                             product (nat_ 0)
                                                                     (let_ (bucket (nat_ 0)
                                                                                   (size w63)
                                                                                   ((r_fanout (r_split (\ (iF101,()) ->
                                                                                                        docUpdate65
                                                                                                        == doc64
                                                                                                           ! iF101)
                                                                                                       (r_index (\ () ->
                                                                                                                 size word_prior61)
                                                                                                                (\ (iF101,()) ->
                                                                                                                 w63
                                                                                                                 ! iF101)
                                                                                                                (r_add (\ (iF101,(iB102,())) ->
                                                                                                                        nat_ 1)))
                                                                                                       r_nop)
                                                                                              r_nop))) $ \ summary100 ->
                                                                      case_ (i97 == zNewf93)
                                                                            [branch ptrue
                                                                                    (case_ (case_ summary100
                                                                                                  [branch (ppair PVar
                                                                                                                 PVar)
                                                                                                          (\ y103
                                                                                                             z104 ->
                                                                                                           y103)])
                                                                                           [branch (ppair PVar
                                                                                                          PVar)
                                                                                                   (\ y105
                                                                                                      z106 ->
                                                                                                    y105)]
                                                                                     ! iB98),
                                                                             branch pfalse
                                                                                    (nat_ 0)])
                                                                     (\ j99 ->
                                                                      nat2prob (let_ (bucket (nat_ 0)
                                                                                             (size w63)
                                                                                             ((r_split (\ (iF108,()) ->
                                                                                                        doc64
                                                                                                        ! iF108
                                                                                                        == docUpdate65)
                                                                                                       r_nop
                                                                                                       (r_index (\ () ->
                                                                                                                 size word_prior61)
                                                                                                                (\ (iF108,()) ->
                                                                                                                 w63
                                                                                                                 ! iF108)
                                                                                                                (r_index (\ (iB109,()) ->
                                                                                                                          size topic_prior60)
                                                                                                                         (\ (iF108,(iB109,())) ->
                                                                                                                          z62
                                                                                                                          ! (doc64
                                                                                                                             ! iF108))
                                                                                                                         (r_add (\ (iF108,(i110,(iB109,()))) ->
                                                                                                                                 nat_ 1))))))) $ \ summary107 ->
                                                                                case_ summary107
                                                                                      [branch (ppair PVar
                                                                                                     PVar)
                                                                                              (\ y111
                                                                                                 z112 ->
                                                                                               z112)]
                                                                                ! iB98
                                                                                ! i97) +
                                                                      nat2prob j99 +
                                                                      word_prior61 ! iB98))) *
                                           recip (product (nat_ 0)
                                                          (size topic_prior60)
                                                          (\ i113 ->
                                                           product (nat_ 0)
                                                                   (let_ (bucket (nat_ 0)
                                                                                 (size w63)
                                                                                 ((r_fanout (r_split (\ (iF116,()) ->
                                                                                                      docUpdate65
                                                                                                      == doc64
                                                                                                         ! iF116)
                                                                                                     (r_add (\ (iF116,()) ->
                                                                                                             nat_ 1))
                                                                                                     r_nop)
                                                                                            r_nop))) $ \ summary115 ->
                                                                    case_ (i113 == zNewf93)
                                                                          [branch ptrue
                                                                                  (case_ (case_ summary115
                                                                                                [branch (ppair PVar
                                                                                                               PVar)
                                                                                                        (\ y117
                                                                                                           z118 ->
                                                                                                         y117)])
                                                                                         [branch (ppair PVar
                                                                                                        PVar)
                                                                                                 (\ y119
                                                                                                    z120 ->
                                                                                                  y119)]),
                                                                           branch pfalse (nat_ 0)])
                                                                   (\ iB114 ->
                                                                    nat2prob (let_ (bucket (nat_ 0)
                                                                                           (size w63)
                                                                                           ((r_split (\ (iF122,()) ->
                                                                                                      doc64
                                                                                                      ! iF122
                                                                                                      == docUpdate65)
                                                                                                     r_nop
                                                                                                     (r_index (\ () ->
                                                                                                               size topic_prior60)
                                                                                                              (\ (iF122,()) ->
                                                                                                               z62
                                                                                                               ! (doc64
                                                                                                                  ! iF122))
                                                                                                              (r_add (\ (iF122,(i123,())) ->
                                                                                                                      nat_ 1)))))) $ \ summary121 ->
                                                                              case_ summary121
                                                                                    [branch (ppair PVar
                                                                                                   PVar)
                                                                                            (\ y124
                                                                                               z125 ->
                                                                                             z125)]
                                                                              ! i113) +
                                                                    nat2prob iB114 +
                                                                    summate (nat_ 0)
                                                                            (size word_prior61)
                                                                            (\ iF126 ->
                                                                             word_prior61
                                                                             ! iF126)))))))),
         branch pfalse (reject)]


