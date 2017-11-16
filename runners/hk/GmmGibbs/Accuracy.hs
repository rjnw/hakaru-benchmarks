module Main where

import System.Environment (getArgs)
import Data.List (permutations)
import Data.Array (accumArray, elems, assocs, (!))
import qualified Data.Map.Strict as M
import Data.List (intercalate)

import Utils (SamplerKnobs(..), gmmKnobs,
              paramsFromName, freshFile, logsToAccs,
              Trial, parseTrial, Snapshot(..))

type Input = ([Double], [Int])

parseInput :: String -> Input
parseInput = read

main :: IO ()
main = do
  [inputs_path, logs_path] <- getArgs
  inputs <- readFile inputs_path
  let [classes, pts] = paramsFromName inputs_path
      fname          = show classes ++ "-" ++ show pts
  accsFile <- freshFile (logsToAccs logs_path) fname
  logs   <- readFile logs_path
  let times = [i * stepSeconds gmmKnobs | i <- [1..2*minSeconds gmmKnobs]]
      processLn i l = map (process (parseInput i)) (parseTrial l)
      processed = zipWith processLn (lines inputs) (lines logs)
  appendFile accsFile (output times) -- this is the header line
  mapM_ (appendFile accsFile . output . resampleWith times) processed

process :: Input -> Snapshot -> Snapshot
process (_,truth) (Snapshot p predict) = Snapshot p [accuracy]
  where accuracy = fromIntegral (maximum
                     [ sum (zipWith (curry (confusion !)) classes perm)
                     | perm <- permutations classes ])
                 / fromIntegral total
        confusion = accumArray (+) 0 ((0,0), (maxClasses-1,maxClasses-1))
                               (zipWith (\t p -> ((t, floor p), 1))
                                        truth predict)
        classes = [0 .. maximum (do ((t,p),count) <- assocs confusion
                                    if count > 0 then [t,p] else [])]
        total = sum (elems confusion)

maxClasses :: Int
maxClasses = 12 -- factorial 13 is probably too big anyway

-- | Resample trials at regular time-intervals using linear interpolation
--------------------------------------------------------------------------------

-- | Given a list of times, resample a trial at those times
--   to produce a list of accuracies
resampleWith :: [Double] -> Trial -> [Double]
resampleWith times trial = map (query table) times
    where table = toTable trial

-- | Map from runtime to accuracy
type Table = M.Map Double Double

-- | Expects a snapshot to look like Snapshot (time:_) [accuracy]
toTable :: Trial -> Table
toTable = M.fromList . map (\(Snapshot (t:_) [acc]) -> (t,acc))

query :: Table -> Double -> Double
query table x =
    case (M.lookupLE x table, M.lookupGE x table) of
      (Nothing, Just (t2,a2)) -> a2
      (Just (t1,a1), Nothing) -> a1
      (Just (t1,a1), Just (t2,a2)) ->
          if t1 == t2 then a1 else interpolate (t1,a1) (t2,a2) x
      (Nothing, Nothing) -> error "query: something went wrong"

interpolate :: (Double,Double) -> (Double,Double) -> Double -> Double
interpolate (t1,a1) (t2,a2) x = a1 + (a2-a1)*(x-t1)/(t2-t1)

output :: [Double] -> String
output = ($ "\n") . showString . intercalate "\t" . map show
