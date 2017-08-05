module Repl(
    repl
) where

import Parser
import Expr
import Eval
import System.IO
import Control.Monad
import Control.Monad.State.Lazy 

repl :: InterpreterM Ex
repl = forever repl1

repl1 :: InterpreterM Ex
repl1 = do
    liftIO $ putStr "lisp>"
    liftIO $ hFlush stdout
    ex <- liftIO readEx
    liftIO $ putStrLn $ show ex
    liftIO $ putStrLn $ toString ex
    exres <- eval ex
    liftIO $ putStrLn $ show exres
    return exres

readEx :: IO Ex
readEx = do
    line <- getLine
    case parseEx line of
        Left err -> do 
            print err
            readEx
        Right ex -> return ex
