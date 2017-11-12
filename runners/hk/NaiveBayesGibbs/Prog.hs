{-# LANGUAGE DataKinds, NegativeLiterals #-}
module NaiveBayesGibbs.Prog where

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
                        product (nat_ 0)
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
                                                     int_ -1 +
                                                     nat2int (summary77 ! i75)))
                                         (\ j76 -> nat2prob j76 + topic_prior60 ! i75)) *
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
                                           unsafeProb (fromProb (product (nat_ 0)
                                                                         (size topic_prior60)
                                                                         (\ i94 ->
                                                                          product (nat_ 0)
                                                                                  (size word_prior61)
                                                                                  (\ iB95 ->
                                                                                   product (nat_ 0)
                                                                                           (let_ (bucket (nat_ 0)
                                                                                                         (size w63)
                                                                                                         ((r_fanout (r_index (\ () ->
                                                                                                                              size z62)
                                                                                                                             (\ (iF98,()) ->
                                                                                                                              doc64
                                                                                                                              ! iF98)
                                                                                                                             (r_index (\ (docUpdate99,()) ->
                                                                                                                                       size word_prior61)
                                                                                                                                      (\ (iF98,(docUpdate99,())) ->
                                                                                                                                       w63
                                                                                                                                       ! iF98)
                                                                                                                                      (r_add (\ (iF98,(iB100,(docUpdate99,()))) ->
                                                                                                                                              nat_ 1))))
                                                                                                                    r_nop))) $ \ summary97 ->
                                                                                            case_ (i94
                                                                                                   == zNewf93)
                                                                                                  [branch ptrue
                                                                                                          (case_ summary97
                                                                                                                 [branch (ppair PVar
                                                                                                                                PVar)
                                                                                                                         (\ y101
                                                                                                                            z102 ->
                                                                                                                          y101)]
                                                                                                           ! docUpdate65
                                                                                                           ! iB95),
                                                                                                   branch pfalse
                                                                                                          (nat_ 0)])
                                                                                           (\ j96 ->
                                                                                            nat2prob (let_ (bucket (nat_ 0)
                                                                                                                   (size w63)
                                                                                                                   ((r_split (\ (iF104,()) ->
                                                                                                                              doc64
                                                                                                                              ! iF104
                                                                                                                              == docUpdate65)
                                                                                                                             r_nop
                                                                                                                             (r_index (\ () ->
                                                                                                                                       size word_prior61)
                                                                                                                                      (\ (iF104,()) ->
                                                                                                                                       w63
                                                                                                                                       ! iF104)
                                                                                                                                      (r_index (\ (iB105,()) ->
                                                                                                                                                size topic_prior60)
                                                                                                                                               (\ (iF104,(iB105,())) ->
                                                                                                                                                z62
                                                                                                                                                ! (doc64
                                                                                                                                                   ! iF104))
                                                                                                                                               (r_add (\ (iF104,(i106,(iB105,()))) ->
                                                                                                                                                       nat_ 1))))))) $ \ summary103 ->
                                                                                                      case_ summary103
                                                                                                            [branch (ppair PVar
                                                                                                                           PVar)
                                                                                                                    (\ y107
                                                                                                                       z108 ->
                                                                                                                     z108)]
                                                                                                      ! iB95
                                                                                                      ! i94) +
                                                                                            nat2prob j96 +
                                                                                            word_prior61
                                                                                            ! iB95)))) *
                                                       (fromInt (let_ (bucket (nat_ 0)
                                                                              (size z62)
                                                                              ((r_index (\ () ->
                                                                                         size topic_prior60)
                                                                                        (\ (iF110,()) ->
                                                                                         z62
                                                                                         ! iF110)
                                                                                        (r_add (\ (iF110,(zNewf111,())) ->
                                                                                                nat_ 1))))) $ \ summary109 ->
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
                                                                 nat2int (summary109 ! zNewf93)) +
                                                        fromProb (topic_prior60 ! zNewf93)) *
                                                       fromProb (recip (product (nat_ 0)
                                                                                (size topic_prior60)
                                                                                (\ i112 ->
                                                                                 product (nat_ 0)
                                                                                         (let_ (bucket (nat_ 0)
                                                                                                       (size w63)
                                                                                                       ((r_fanout (r_index (\ () ->
                                                                                                                            size z62)
                                                                                                                           (\ (iF115,()) ->
                                                                                                                            doc64
                                                                                                                            ! iF115)
                                                                                                                           (r_add (\ (iF115,(docUpdate116,())) ->
                                                                                                                                   nat_ 1)))
                                                                                                                  r_nop))) $ \ summary114 ->
                                                                                          case_ (i112
                                                                                                 == zNewf93)
                                                                                                [branch ptrue
                                                                                                        (case_ summary114
                                                                                                               [branch (ppair PVar
                                                                                                                              PVar)
                                                                                                                       (\ y117
                                                                                                                          z118 ->
                                                                                                                        y117)]
                                                                                                         ! docUpdate65),
                                                                                                 branch pfalse
                                                                                                        (nat_ 0)])
                                                                                         (\ iB113 ->
                                                                                          nat2prob (let_ (bucket (nat_ 0)
                                                                                                                 (size w63)
                                                                                                                 ((r_split (\ (iF120,()) ->
                                                                                                                            doc64
                                                                                                                            ! iF120
                                                                                                                            == docUpdate65)
                                                                                                                           r_nop
                                                                                                                           (r_index (\ () ->
                                                                                                                                     size topic_prior60)
                                                                                                                                    (\ (iF120,()) ->
                                                                                                                                     z62
                                                                                                                                     ! (doc64
                                                                                                                                        ! iF120))
                                                                                                                                    (r_add (\ (iF120,(i121,())) ->
                                                                                                                                            nat_ 1)))))) $ \ summary119 ->
                                                                                                    case_ summary119
                                                                                                          [branch (ppair PVar
                                                                                                                         PVar)
                                                                                                                  (\ y122
                                                                                                                     z123 ->
                                                                                                                   z123)]
                                                                                                    ! i112) +
                                                                                          nat2prob iB113 +
                                                                                          summate (nat_ 0)
                                                                                                  (size word_prior61)
                                                                                                  (\ iF124 ->
                                                                                                   word_prior61
                                                                                                   ! iF124)))))))))),
         branch pfalse (reject)]

