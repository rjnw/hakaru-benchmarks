module Main where

import System.Environment (getArgs)
import qualified Data.Vector.Unboxed as U
import Data.List (permutations)
import qualified Data.Map.Strict as M

import           Language.Hakaru.Runtime.LogFloatPrelude
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime)
import           Control.Monad (replicateM_)
import           System.Environment (getArgs)
import           System.Directory (doesFileExist, removeFile)
import           System.FilePath ((</>))
import           System.IO (hPutStrLn, hClose)
import           System.IO.Temp (withSystemTempFile)
import           System.Process (readProcess)
import Utils (SamplerKnobs(..), gmmKnobs,
              paramsFromName, freshFile, logsToAccs,
              Trial, parseTrial, Snapshot(..))
import           News (getNews, SingletonType(..))
import qualified Data.Text.IO as TIO
import qualified Data.Text as T

import LdaGibbs.LdaLikelihood

main :: IO ()
main = do
  [inputFolder, logFile, outputFile, num_topics] <- getArgs

  words_st <- TIO.readFile $ concat [inputFolder, "words"]
  docs_st <- TIO.readFile $ concat [inputFolder,  "docs"]
  logs <- readFile logFile

  let words = U.fromList $ ((Prelude.map (read . T.unpack) (T.lines words_st)) :: [Int])
      docs = U.fromList $ ((Prelude.map (read . T.unpack) (T.lines docs_st)) :: [Int])
      numTopics = read num_topics :: Int
  let processLn l = map (calculateLikelihood words docs numTopics) (parseTrial l)
      processed = map processLn (lines logs)

  mapM_ (appendFile outputFile . ($ "\n") . showList) processed

calculateLikelihood words docs numTopics (Snapshot p predict) = Snapshot p [Language.Hakaru.Runtime.LogFloatPrelude.log likelihood]
  where
    numWords = U.maximum words + 1
    topicPrior = array numTopics (const 1)
    wordPrior  = array numWords  (const 1)
    numDocs = U.last docs + 1
    likelihood = prog topicPrior wordPrior numDocs words docs $ U.fromList $ map fromIntegral $ map round predict

-- ./hkbin/ldaLikelihood ../input/kos/ ../output/LdaGibbs/kos/rkt-50 ../output/accuracies/LdaGibbs/kos-rkt-50 50
