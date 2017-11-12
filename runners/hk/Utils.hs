module Utils where

import qualified Data.Vector.Unboxed as U
import           Language.Hakaru.Runtime.LogFloatPrelude
import           Language.Hakaru.Runtime.CmdLine
import qualified System.Random.MWC                as MWC
import           Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import           Control.Monad ((>=>), forM)

gibbsSweep :: MWC.GenIO
           -> (Int -> Measure Int) -- update one dimension
           -> U.Vector Int         -- start state
           -> IO (U.Vector Int)    -- state after one sweep
gibbsSweep g update zs = loop (U.length zs) zs
    where loop :: Int -> U.Vector Int -> IO (U.Vector Int)
          loop 0 zs = return zs
          loop i zs = do
            Just zNew <- unMeasure (update (i-1)) g
            loop (i-1) (U.unsafeUpd zs [(i-1, zNew)])    

data SamplerKnobs = Knobs { minSeconds :: Double
                          , stepSeconds :: Double
                          , minSweeps :: Int
                          , stepSweeps :: Int }

type Snapshot = (Double,       -- seconds since beginning of initialization
                 Int,          -- sweeps performed so far
                 U.Vector Int) -- current classification

type Trial = [Snapshot]

type Sampler = SamplerKnobs -> IO (Double, Trial) 
                                   -- ^ initialization time in seconds

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
      loop :: Int -> Double -> Double -> U.Vector Int -> IO Trial
      loop iter time2 time2subgoal zs
        | threshCond time2 iter = return []
        | otherwise = do
            zs <- sweeps (stepSweeps knobs) zs
            time2 <- (`diffTime` time0) <$> getCurrentTime
            iter  <- return (iter + stepSweeps knobs)
            if time2 >= time2subgoal || threshCond time2 iter
            then ((time2, iter, zs) : ) <$>
                 loop iter time2 (time2 + stepSeconds knobs) zs
            else loop iter time2 time2subgoal zs
  samples <- loop 0 0 (stepSeconds knobs) zs
  return (diffTime time1 time0, samples)
  
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
         
