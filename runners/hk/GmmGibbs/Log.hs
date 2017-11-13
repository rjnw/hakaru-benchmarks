module Log (Trial, Snapshot(..), parseTrial, parseSnapshot) where

import Data.Char (isSpace)
import Data.Function (on)
import Data.List (intercalate)
import Numeric (showFFloat)

type Trial    = [Snapshot]
data Snapshot = Snapshot { progress, state :: [Double] }

instance Show Snapshot where
  show (Snapshot p s) = f p ++ " [" ++ f s ++ "]"
    where f = unwords . map (($ "") . showFFloat Nothing)
  showList = showString . intercalate "\t" . map show

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
