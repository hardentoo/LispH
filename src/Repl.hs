{-# LANGUAGE FlexibleInstances #-}

module Repl(
    mainrepl,
    evalString
) where

import Parser
import Expr
import Eval
import System.IO
import Control.Monad
import Control.Monad.State.Lazy
import Control.Monad.Except
import System.Console.Haskeline

instance MonadException m => MonadException (ExceptT Error m) where
    controlIO f = ExceptT $ controlIO $ \(RunIO run) -> let
                    run' = RunIO (fmap ExceptT . run . runExceptT)
                    in fmap runExceptT $ f run'

repl :: InputT InterpreterM Ex
repl = forever repl1

mainrepl :: IO ()
mainrepl = (evalI (runInputT defaultSettings repl ) emptyStore) >> return ()

inputPrompt :: String
inputPrompt = "Repl> "

repl1 :: InputT InterpreterM Ex
repl1 = do
    inp <- getInputLine inputPrompt
    outputStrLn $ show inp
    case inp of
        Nothing -> lift $ throwI $ ParserError "Nothing"
        Just s -> do
            outputStrLn $ s
            eex <- lift $ evalString s
            outputStrLn $ show eex
            return eex

evalString :: String -> InterpreterM Ex
evalString s = case parseEx s of
    Left err -> do
        liftIO $ putStrLn "parse error"
        throwI $ ParserError $ show err
    Right ex -> eval ex
