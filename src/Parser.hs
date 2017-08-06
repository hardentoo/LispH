module Parser
    ( expression,
    parseEx
    ) where

import Expr
import Text.ParserCombinators.Parsec
import Control.Monad

parseEx s = parse expression "" s

expression :: Parser Ex
expression = do 
    skipMany space
    (try list) <|> (try integer) <|> (try symbolOrBool) <|> (try Parser.string)

integer :: Parser Ex
integer = do
    skipMany space
    s <- sign
    dgts <- many1 digit
    return $ ExInteger ( s * (read dgts))

sign :: Parser Integer
sign = do
    hassign <- optionMaybe $ char '-'
    return $ signHelper hassign

signHelper :: Maybe Char -> Integer
signHelper c = case c of 
    Just _ -> -1
    Nothing -> 1

list :: Parser Ex
list = do
    skipMany space
    char '('
    skipMany space
    args <- many (try expression)
    skipMany space
    char ')'
    return (ExList args)

--these are the allowed chars in a symbol
specialChar :: Parser Char
specialChar = oneOf "!#$%&|*+-/:<=>?@^_~"

digestSymbolOrBool :: String -> Ex
digestSymbolOrBool  s = case s of
               "#t" -> ExBool True
               "#f" -> ExBool False
               otherwise -> ExSymbol s

symbolOrBool ::Parser Ex
symbolOrBool = do
    skipMany space
    first <- letter <|> specialChar
    rest <- many (letter <|> digit <|> specialChar)
    return $ digestSymbolOrBool (first:rest)

string :: Parser Ex
string = do
    -- TODO escaping
    char '"'
    content <- many $ noneOf "\"\n"
    char '"'
    return $ ExString content

