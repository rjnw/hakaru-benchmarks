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
                                (\ i75 ->
                                 product (nat_ 0)
                                         (let_ (bucket (nat_ 0)
                                                       (size z62)
                                                       ((r_index (\ () -> size topic_prior60)
                                                                 (\ (iF78,()) -> z62 ! iF78)
                                                                 (r_add (\ (iF78,(i79,())) ->
                                                                         nat_ 1))))) $ \ summary77 ->
                                          unsafeNat (nat2int (case_ (not (nat2int (size topic_prior60) +
                                                                          int_ -1
                                                                          < nat2int (z62
                                                                                     ! docUpdate65)) &&
                                                                     i75 == z62 ! docUpdate65)
                                                                    [branch ptrue (nat_ 1),
                                                                     branch pfalse (nat_ 0)]) *
                                                     int_ -1) +
                                          summary77 ! i75)
                                         (\ j76 -> nat2prob j76 + topic_prior60 ! i75)) *
                        product (nat_ 0)
                                (size topic_prior60)
                                (\ i66 ->
                                 product (nat_ 0)
                                         (size word_prior61)
                                         (\ iB67 ->
                                          product (nat_ 0)
                                                  (let_ (bucket (nat_ 0)
                                                                (size w63)
                                                                ((r_split (\ (iF70,()) ->
                                                                           docUpdate65
                                                                           == doc64 ! iF70)
                                                                          r_nop
                                                                          (r_index (\ () ->
                                                                                    size word_prior61)
                                                                                   (\ (iF70,()) ->
                                                                                    w63
                                                                                    ! iF70)
                                                                                   (r_index (\ (iB71,()) ->
                                                                                             size topic_prior60)
                                                                                            (\ (iF70,(iB71,())) ->
                                                                                             z62
                                                                                             ! (doc64
                                                                                                ! iF70))
                                                                                            (r_add (\ (iF70,(i72,(iB71,()))) ->
                                                                                                    nat_ 1))))))) $ \ summary69 ->
                                                   case_ summary69
                                                         [branch (ppair PVar PVar)
                                                                 (\ y73 z74 -> z74)]
                                                   ! iB67
                                                   ! i66)
                                                  (\ j68 -> nat2prob j68 + word_prior61 ! iB67))) *
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
                                                                                       (\ (iF111,()) ->
                                                                                        z62
                                                                                        ! iF111)
                                                                                       (r_add (\ (iF111,(zNewf112,())) ->
                                                                                               nat_ 1))))) $ \ summary110 ->
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
                                                                nat2int (summary110 ! zNewf93)) +
                                                       fromProb (topic_prior60 ! zNewf93)) *
                                           product (nat_ 0)
                                                   (size topic_prior60)
                                                   (\ i94 ->
                                                    product (nat_ 0)
                                                            (size word_prior61)
                                                            (\ iB95 ->
                                                             product (nat_ 0)
                                                                     (let_ (bucket (nat_ 0)
                                                                                   (size w63)
                                                                                   ((r_fanout (r_split (\ (iF98,()) ->
                                                                                                        docUpdate65
                                                                                                        == doc64
                                                                                                           ! iF98)
                                                                                                       (r_index (\ () ->
                                                                                                                 size word_prior61)
                                                                                                                (\ (iF98,()) ->
                                                                                                                 w63
                                                                                                                 ! iF98)
                                                                                                                (r_add (\ (iF98,(iB99,())) ->
                                                                                                                        nat_ 1)))
                                                                                                       r_nop)
                                                                                              r_nop))) $ \ summary97 ->
                                                                      case_ (i94 == zNewf93)
                                                                            [branch ptrue
                                                                                    (case_ (case_ summary97
                                                                                                  [branch (ppair PVar
                                                                                                                 PVar)
                                                                                                          (\ y100
                                                                                                             z101 ->
                                                                                                           y100)])
                                                                                           [branch (ppair PVar
                                                                                                          PVar)
                                                                                                   (\ y102
                                                                                                      z103 ->
                                                                                                    y102)]
                                                                                     ! iB95),
                                                                             branch pfalse
                                                                                    (nat_ 0)])
                                                                     (\ j96 ->
                                                                      nat2prob (let_ (bucket (nat_ 0)
                                                                                             (size w63)
                                                                                             ((r_split (\ (iF105,()) ->
                                                                                                        doc64
                                                                                                        ! iF105
                                                                                                        == docUpdate65)
                                                                                                       r_nop
                                                                                                       (r_index (\ () ->
                                                                                                                 size word_prior61)
                                                                                                                (\ (iF105,()) ->
                                                                                                                 w63
                                                                                                                 ! iF105)
                                                                                                                (r_index (\ (iB106,()) ->
                                                                                                                          size topic_prior60)
                                                                                                                         (\ (iF105,(iB106,())) ->
                                                                                                                          z62
                                                                                                                          ! (doc64
                                                                                                                             ! iF105))
                                                                                                                         (r_add (\ (iF105,(i107,(iB106,()))) ->
                                                                                                                                 nat_ 1))))))) $ \ summary104 ->
                                                                                case_ summary104
                                                                                      [branch (ppair PVar
                                                                                                     PVar)
                                                                                              (\ y108
                                                                                                 z109 ->
                                                                                               z109)]
                                                                                ! iB95
                                                                                ! i94) +
                                                                      nat2prob j96 +
                                                                      word_prior61 ! iB95))) *
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

