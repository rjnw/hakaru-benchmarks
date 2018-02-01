module Utils where

import qualified Data.Vector.Unboxed as U
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import           Control.Monad ((>=>), forM, when)
import           Data.Char (isSpace)
import           Data.Function (on)
import           Data.List (intercalate)
import           Numeric (showFFloat)
import           System.FilePath (takeBaseName, takeDirectory, replaceDirectory, (</>))
import           Data.List.Split (wordsBy)
import           System.Directory (createDirectoryIfMissing)
import Debug.Trace

gibbsSweep :: (U.Vector Int -> Int -> Measure Int) -- update one dimension
           -> MWC.GenIO
           -> U.Vector Int         -- start state
           -> IO (U.Vector Int)    -- state after one sweep
gibbsSweep update g zs = loop (U.length zs) zs
    where loop :: Int -> U.Vector Int -> IO (U.Vector Int)
          loop 0 zs = return zs
          loop i zs = do
            t1 <- getCurrentTime
            Just zNew <- unMeasure (update zs (i-1)) g
            -- when (i `mod` 1000 == 0) $
            --      putStrLn $ "sampled new topic for doc " ++
            --                 show i ++ ", time = " ++ show t1 ++
            --                 "original topic: " ++ show (zs U.! i) ++
            --                 " new: " ++ show zNew
            loop (i-1) (U.unsafeUpd zs [(i-1, zNew)])

data SamplerKnobs = Knobs { minSeconds :: Double
                          , stepSeconds :: Double
                          , minSweeps :: Int
                          , stepSweeps :: Int }

gmmKnobs = Knobs { minSeconds = 1
                 , stepSeconds = 0.01
                 , minSweeps = 100
                 , stepSweeps = 10 }

-- | Called "sweep" here:
-- https://github.com/rjnw/hakaru-benchmarks/tree/master/output
type Log = (Double,       -- seconds since beginning of initialization
            Int,          -- sweeps performed so far
            U.Vector Int) -- current classification

type LogsWithInit = (Double, [Log])
                    -- ^ initialization time in seconds

onlyLogs :: LogsWithInit -> [Log]
onlyLogs = snd

type Sampler = SamplerKnobs -> IO LogsWithInit

timeHakaru :: UTCTime -- time0
           -> (U.Vector Int -> IO (U.Vector Int)) -- sweeper function
           -> U.Vector Int -- start state
           -> Sampler
timeHakaru time0 sweep zs knobs = do
  time1 <- getCurrentTime
  let sweeps :: Int -> U.Vector Int -> IO (U.Vector Int)
      sweeps 0 = return
      sweeps n = sweep >=> sweeps (n-1)
      threshCond t i = t >= minSeconds knobs &&
                       i >= minSweeps  knobs
      loop :: Int -> Double -> Double -> U.Vector Int -> IO [Log]
      loop iter time2 time2subgoal zs
        | threshCond time2 iter = return []
        | otherwise = do
            -- putStrLn $ "done " ++ show iter ++ " sweeps"
            zs <- sweeps (stepSweeps knobs) zs
            time2 <- (`diffTime` time0) <$> getCurrentTime
            iter  <- return (iter + stepSweeps knobs)
            if time2 >= time2subgoal || threshCond time2 iter
            then ((time2, iter, zs) : ) <$>
                 loop iter time2 (time2 + stepSeconds knobs) zs
            else loop iter time2 time2subgoal zs
  samples <- loop 0 0 (stepSeconds knobs) zs
  return (diffTime time1 time0 , samples)

diffTime :: UTCTime -> UTCTime -> Double
diffTime a b = fromRational . toRational $ diffUTCTime a b

timeJags :: String -- output from R-JAGS driver
         -> Sampler
timeJags output = const $ do
  let times:samples  = lines output
      [time0, time1] = map read (words times)
      parse (stats:zs_:rest) = (time2 - time0, iter, zs) : parse rest
        where time2           = read time2_
              iter            = read iter_
              [time2_, iter_] = words stats
              zs              = U.fromList . map (pred . read) . words $ zs_
      parse _ = []
  return (time1 - time0, parse samples)

data Snapshot = Snapshot { progress, state :: [Double] }

toSnapshot :: Log -> Snapshot
toSnapshot (seconds, sweeps, labels) =
    Snapshot { progress = [seconds, fromIntegral sweeps]
             , state = U.toList $ U.map fromIntegral labels }

instance Show Snapshot where
  show (Snapshot p s) = f p ++ " [" ++ f s ++ "]"
    where f = unwords . map (($ "") . showFFloat Nothing)
  showList = showString . intercalate "\t" . map show

-- | Called "line" here:
-- https://github.com/rjnw/hakaru-benchmarks/tree/master/output
type Trial = [Snapshot]

oneLine :: LogsWithInit -> String
oneLine = ($ "\n") . showList . map toSnapshot . onlyLogs

parseTrial :: String -> Trial
parseTrial = parseTrial' . dropWhile delim
  where parseTrial' "" = []
        parseTrial' s | all isSpace s1 = parseTrial s2
                      | otherwise      = parseSnapshot s1
                                       : parseTrial s2
          where (s1,s2) = break delim s
        delim = (`elem` "\t()")

parseSnapshot :: String -> Snapshot
parseSnapshot s | all isSpace s'' = Snapshot (f s1) (f s2)
  where (s1, '[':s' ) = break ('[' ==) s
        (s2, ']':s'') = break (']' ==) s'
        f             = map read . words

paramsFromName :: FilePath -> [Int]
paramsFromName = map read . wordsBy (== '-') . takeBaseName

freshFile :: FilePath -- path to backend subdirectory
          -> String -- name of file
          -> IO FilePath
freshFile backend_dir fname = do
  createDirectoryIfMissing True backend_dir
  let backend_file = backend_dir </> fname
  writeFile backend_file ""
  return backend_file

logsToAccs :: FilePath -> FilePath
logsToAccs logs_path =
    let logs_dir = takeDirectory logs_path
        backend  = takeBaseName logs_dir
        g        = takeDirectory logs_dir
    in replaceDirectory g (takeDirectory g </> "accuracies") </> backend

every :: Int -> [Int] -> [Int]
every n xs = case drop (n-1) xs of
               (y:ys) -> y : every n ys
               [] -> []
