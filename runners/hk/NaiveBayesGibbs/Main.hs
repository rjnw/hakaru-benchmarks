module Main where

import qualified Data.Vector.Unboxed as U
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

import           Utils (SamplerKnobs(..), Sampler,
                        oneLine, every, freshFile,
                        timeJags, gibbsSweep, timeHakaru)
import           News (getNews, SingletonType(..))
import           NaiveBayesGibbs.Prog3

main = do
  [inputs_path, jagscodedir, outputs_dir] <- getArgs --change input path to read already parsed news data similar to rkt
  putStrLn "going to get news"
  (w,doc,zs) <- fst <$> getNews (inputs_path </> "20_newsgroups/") SingleDoc Nothing [0..]
  putStrLn "done getting news"                     -- ^ retrieves everything
  g <- MWC.createSystemRandom
  let numTopics = U.maximum zs + 1
      numDocs = U.length zs
      holdouts = filter (\ v -> mod v 100 == 0) $ [0..numDocs - 1]
      numTrials = 1
      fname = show numTopics ++ "-" ++ show numDocs ++ "-10"
      benchmark_dir = outputs_dir </> "NaiveBayesGibbs"
      jagsmodel = jagscodedir </> "NaiveBayesModel.jags"
      jagsrunner = jagscodedir </> "NaiveBayesModel.R"
  hkfile   <- freshFile (benchmark_dir </> "hk") fname
  jagsfile <- freshFile (benchmark_dir </> "jags") fname

  replicateM_ numTrials $ do
    putStrLn "starting a new trial"
    -- hktrial   <- oneLine <$> hakaru g holdouts numTopics numDocs w doc zs nbKnobs
    -- putStrLn "writing haskell..."
    -- appendFile hkfile   hktrial
    jagstrial <- oneLine <$> jags jagsmodel jagsrunner inputs_path nbKnobs
    putStrLn "writing jags..."
    appendFile jagsfile jagstrial

nbKnobs = Knobs { minSeconds = 1
                , stepSeconds = 0.5
                , minSweeps = 1
                , stepSweeps = 1 }

type NBSampler = [Int] ->        -- indices of hold-out docs
                 Int ->          -- number of topics
                 Int ->          -- number of documents
                 U.Vector Int -> -- words array
                 U.Vector Int -> -- doc index of each word
                 U.Vector Int -> -- true document labels
                 Sampler

hakaru :: MWC.GenIO -> NBSampler
hakaru g holdouts numTopics numDocs w doc truth knobs = do
  let numWords   = U.maximum w + 1
      topicPrior = array numTopics (const 1)
      wordPrior  = array numWords  (const 1)
      update = let f = prog topicPrior wordPrior
               in \ z i ->
                   if elem i holdouts
                   then f z w doc i
                   else do
                     -- let n = (z U.! i)
                     -- let t = (truth U.! i)
                     -- putStrLn ("i " ++ (show i) ++ "n " ++ (show n) ++ "t " ++ (show t))
                     return (z U.! i)
  time0 <- getCurrentTime
  zs <- U.generateM numDocs $
        \i -> if elem i holdouts
              then MWC.uniformR (0, numTopics - 1) g
              else return (truth U.! i)

  -- print $ filter (\ v -> (mod v 10 /= 0 && (truth U.! v /= zs U.! v))) [0..numDocs - 1]
  timeHakaru time0 (gibbsSweep update g) zs knobs

jags :: FilePath -> FilePath -> FilePath -> Sampler
jags m r inputs_path knobs = do
  output <- readProcess "R"
            ["--slave", "-f", r, "--args",
             inputs_path,
             show (minSeconds knobs),
             show (stepSeconds knobs),
             show (minSweeps knobs),
             show (stepSweeps knobs),
             m,
             show 10]
            ""
  timeJags output knobs
