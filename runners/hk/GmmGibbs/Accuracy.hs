module Main where

import System.Environment (getArgs)
import Data.List (permutations)
import Data.Array (accumArray, elems, assocs, (!))

import Log

type Input = ([Double], [Int])

parseInput :: String -> Input
parseInput = read

main :: IO ()
main = do
  [inputs_path, logs_path] <- getArgs
  inputs <- readFile inputs_path
  logs   <- readFile logs_path
  mapM_ print (zipWith (\i l -> map (process (parseInput i)) (parseTrial l))
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
