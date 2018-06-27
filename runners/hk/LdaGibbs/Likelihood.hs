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

import LdaGibbs.LdaLikelihood

main :: IO ()
main = do
  [inputs_path, log_file, output_file] <- getArgs
  putStrLn "getting news"
  (w,doc,zs) <- fst <$> getNews (inputs_path </> "20_newsgroups/") SingleDoc Nothing [0..]
  putStrLn "done getting news"                     -- ^ retrieves everything
  logs <- readFile log_file
  let processLn l = map (calculateLikelihood w doc zs) (parseTrial l)
      processed = map processLn (lines logs)
  mapM_ (appendFile output_file . ($ "\n") . showList) processed

--calculateLikelihood ::[Int] -> [Int] -> [Int] -> Snapshot -> Snapshot
calculateLikelihood w doc zs (Snapshot p predict) = Snapshot p [fromProb likelihood]
  where
    numTopics = U.maximum zs + 1
    numWords = U.maximum w + 1
    topicPrior = array numTopics (const 1)
    wordPrior  = array numWords  (const 1)
    numDocs = U.length zs
    likelihood = prog topicPrior wordPrior numDocs w doc $ U.fromList $ map fromIntegral $ map round predict
