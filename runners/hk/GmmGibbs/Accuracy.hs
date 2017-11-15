module Main where

import System.Environment (getArgs)
import Data.List (permutations)
import Data.Array (accumArray, elems, assocs, (!))
import qualified Data.Map.Strict as M

import Log

type Input = ([Double], [Int])

parseInput :: String -> Input
parseInput = read

main :: IO ()
main = do
  [inputs_path, logs_path] <- getArgs
  inputs <- readFile inputs_path
  logs   <- readFile logs_path
  let ptsPerLn = 50
      accs = [1/ptsPerLn * i | i <- [1..ptsPerLn]]
      processLn i l = map (process (parseInput i)) (parseTrial l)
  mapM_ print (zipWith (\i -> resampleWith accs . processLn i)
                       (lines inputs) (lines logs))

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

-- | Resample trials at regular accuracy-intervals using linear interpolation
--------------------------------------------------------------------------------

resampleWith :: [Double] -> Trial -> Trial
resampleWith accs trial = fromSamples $ map (\a -> (a, query table a)) accs
    where table = toTable trial
          fromSamples :: [(Double,[Double])] -> Trial
          fromSamples = map (\(a,p) -> Snapshot p [a])

-- | Map from accuracies to (runtime:_)
type Table = M.Map Double [Double]

toTable :: Trial -> Table
toTable = M.fromList . map (\(Snapshot p [acc]) -> (acc,p))

query :: Table -> Double -> [Double]
query table x =
    case (M.lookupLE x table, M.lookupGE x table) of
      (Nothing, Just (b,pb)) -> pb
      (Just (a,pa), Nothing) -> pa
      (Just (a,pa), Just (b,pb)) ->
          if a == b then pa else interpolate (a,pa) (b,pb) x
      (Nothing, Nothing) -> error "query: something went wrong"

-- | Expects the y-coordinate to look like [time,nsweeps]
interpolate :: (Double,[Double]) -> (Double,[Double]) -> Double -> [Double]
interpolate (a,[ta,na]) (b,[tb,nb]) x = [ ta + (tb-ta)*(x-a)/(b-a)
                                        , fromIntegral . floor $ (na + nb) / 2 ]

