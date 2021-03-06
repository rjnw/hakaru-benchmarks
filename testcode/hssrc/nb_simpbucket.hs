{-# LANGUAGE DataKinds, NegativeLiterals #-}
module Main where

import           Data.Number.LogFloat (LogFloat)
import           Prelude hiding (product, exp, log, (**))
import           Language.Hakaru.Runtime.LogFloatPrelude

import           Language.Hakaru.Runtime.CmdLine
import           Language.Hakaru.Types.Sing
import qualified System.Random.MWC                as MWC
import           Control.Monad
import           System.Environment (getArgs)

import qualified Data.Time.Clock as C
import qualified System.Environment as SE
import qualified Data.Number.LogFloat as LF
import qualified Data.Vector.Unboxed as UV
import qualified Data.Text.IO as TIO
import qualified Data.Text as T
import qualified Data.Text.Read as TR

prog =
  lam $ \ topic_prior60 ->
  lam $ \ word_prior61 ->
  lam $ \ z62 ->
  lam $ \ w63 ->
  lam $ \ doc64 ->
  lam $ \ docUpdate65 ->
  case_ (docUpdate65 < size z62)
        [branch ptrue
                ((array (size topic_prior60) $
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
                                                                                                   ! iF124)))))))),
         branch pfalse (UV.empty)]

main :: IO ()
main = do
  twds <- SE.getArgs
  print twds
  let [word_f, doc_f, topic_f] = twds
  words_st <- TIO.readFile word_f
  docs_st <- TIO.readFile doc_f
  topics_st <- TIO.readFile topic_f
  let topics =  UV.fromList $ ((Prelude.map (read . T.unpack) (T.lines topics_st)) :: [Int])
  let words = UV.fromList $ ((Prelude.map (read . T.unpack) (T.lines words_st)) :: [Int])
  let docs = UV.fromList $ ((Prelude.map (read . T.unpack) (T.lines docs_st)) :: [Int])

  let numDocs = UV.last docs + 1
  let numTopics = UV.maximum topics + 1
  let numWords = UV.maximum words + 1

  let topic_prior = UV.map LF.logFloat $ UV.replicate numTopics 1.0
  let word_prior = UV.map LF.logFloat  $ UV.replicate numWords 1.0

  let docUpdate = 4
  g <- MWC.createSystemRandom
  zs <- UV.replicateM numDocs (MWC.uniformR (0, numTopics - 1) g)

  print "starting main"
  start_time <- C.getCurrentTime
  result <- return $! (prog topic_prior word_prior zs words docs docUpdate)
  end_time <- C.getCurrentTime

  print "result:"
  print (UV.map LF.logFromLogFloat result)
  print "time:"

  print $ C.diffUTCTime end_time start_time
