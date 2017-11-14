module Main where

import qualified Data.ByteString.Char8 as B
import News
import qualified System.Random.MWC as MWC
import qualified Data.Vector.Unboxed as V
import Data.Vector.Unboxed ((!))
import Text.Printf (printf)
import Control.Monad (forever, replicateM, forM_)
import Data.List (sort)
import Data.Number.LogFloat
import System.IO
import System.Environment (getArgs)

writeVec :: FilePath -> V.Vector Int -> IO ()
writeVec file v = withFile file WriteMode $ \h -> do
                    V.forM_ v $ \x -> hPrint h x

main = do
  [newsgrps_path, input_store_path] <- getArgs
  ((words, docs, topics), enc) <- getNews newsgrps_path SingleDoc Nothing [0..]
  writeVec (input_store_path ++ "words") words
  writeVec (input_store_path ++ "docs") docs
  writeVec (input_store_path ++ "topics") topics
  withFile (input_store_path ++ "vocab") WriteMode $ \h -> do
    forM_ (reverse $ vocabReverse enc) $ \x -> B.hPutStrLn h x
