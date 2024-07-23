-- usage: cabal run . -- <path>

module Main where

import Control.Exception (SomeException, catch, try)
import System.Exit (ExitCode(ExitFailure), exitWith)
import System.FilePath ((</>))
import System.Directory (createDirectoryIfMissing)
import System.Environment (getArgs)
import Network.HTTP.Request (Response(responseStatus), get, responseBody)
import Data.ByteString.Char8 (unpack)

class Status s where
    ok :: s -> Bool
    ok = const False

    disp :: s -> String
    disp = const "encountered bad response (expected OK)"

newtype ResponseCode = ResponseCode Int
instance Status ResponseCode where
    ok (ResponseCode code) = code == 200
    disp (ResponseCode code) =
        "encountered bad response code: "
        ++ show code
        ++ " (expected 200 'OK')"

newtype ResponseMsg = ResponseMsg String
instance Status ResponseMsg where
    ok (ResponseMsg msg) = msg == "success"
    disp (ResponseMsg msg) =
        "encountered bad response message: "
        ++ msg
        ++ " (expected 'success')"

toResponseMsg :: SomeException -> ResponseMsg
toResponseMsg = ResponseMsg . show

baseURL :: String
baseURL = "https://projects.fivethirtyeight.com/polls/data/"

makeEntry :: String -> (String, String)
makeEntry name = (name, baseURL ++ name)

-- only current data is pulled, since historical data does not need to be updated regularly
sources :: [(String, String)]
sources = map makeEntry [
        "favorability_polls.csv",
        "favorability_averages.csv",
        "generic_ballot_polls.csv",
        "president_approval_polls.csv",
        "vp_approval_polls.csv",
        "congress_approval.csv",
        "scotus_approval_polls.csv",
        "approval_averages.csv",
        "president_polls.csv",
        "presidential_general_averages.csv",
        "president_primary_polls.csv",
        "presidential_primary_averages.csv",
        "house_polls.csv",
        "senate_polls.csv"
    ]

fetch :: String -> IO (Either SomeException Response)
fetch = try . get

continue :: (Status s) => s -> IO ()
continue = putStrLn . disp

destruct :: (Status s) => s -> IO () -> IO ()
destruct status success
    | ok status = success
    | otherwise = continue status >> success

fileErr :: SomeException -> IO ()
fileErr e = print e >> putStrLn "error: couldn't write to file"

ping :: [(String, String)] -> (Response -> String -> IO ()) -> IO ()
ping [] _ = putStrLn "finished fetching all data sources"
ping ((name, query):queries) run = do
    res <- fetch query
    case res of
        Left e -> continue (toResponseMsg e) >> ping queries run
        Right r ->
            let status = (ResponseCode . responseStatus) r
                runner = catch (run r name) fileErr
                update = putStrLn ("successfully fetched " ++ name)
                next = ping queries run
            in destruct status (update >> runner >> next)

save :: String -> Response -> String -> IO ()
save path r name = writeFile (path </> name) body where body = (unpack . responseBody) r

crash :: String -> IO ()
crash msg = putStrLn ("error: " ++ msg) >> (exitWith . ExitFailure) 1

setup :: String -> IO ()
setup = createDirectoryIfMissing True

main :: IO ()
main = do
    args <- getArgs
    case args of
        [path :: String] -> setup path >> ping sources (save path)
        _ -> crash "Invalid arguments."
