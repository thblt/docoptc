This module deals with the parsing of the docopt syntax and the generation of Usage strings.

> module Text.Docoptc.Parser (DocoptSource, makeDocoptSource) where

> import Data.List (isPrefixOf)
> import Data.Char (toLower)

Docopt syntax is made of two main parts:

  1. usage strings, concerned by the relationship between parameters,
their order and compatibility ;

  2. options details, which describes the equivalence between long and
short parameters, solves some ambiguous cases with parameters (mostly
problems of the form: does "-i FILE" means: the option `-i`, *then*
the `FILE` positional, or the option `-i` *with* its mandatory
parameter `FILE`).

> data DocoptSource = DocoptSource {
>                                    dosUnprocessed :: [String], 
>                                    dosUsage :: [String], 
>                                    dosOptions :: [String]
>                                  } deriving (Show)

> makeDocoptSource :: [String] -> DocoptSource
> makeDocoptSource i = extractOptions . extractUsage $ DocoptSource (fmap (dropWhile (`elem` " \t")) i) [] []

The first step of parsing then consists in splitting the file (already
split into lines) in two: a list of lines consisting in the usage
part, another list of lines consisting of option details. Lines who
don't fall in any of these categories are discarded: their existence
is legal by the specification, but we won't be needing them.

The two following functions respectively extract the usage and options
details parts of a docopt file.

> extractUsage :: DocoptSource -> DocoptSource
> extractUsage d@(DocoptSource (x:_) _ _) | "usage" `isPrefixOf` fmap toLower x = extractUsage' d 
>  where
>    extractUsage' d@(DocoptSource ([]:_) _ _) = extractUsage d 
>    extractUsage' d@(DocoptSource xs@(x:xs') u o) = extractUsage' $ DocoptSource xs' o (x:u)  
> | otherwise =  
>
> extractOptions :: DocoptSource -> DocoptSource
> extractOptions d@(DocoptSource xs@(x:xs') u o) | "-" `isPrefixOf` x = DocoptSource xs' u (x:o)
>                                                | otherwise = d

> lambda :: Integer
> lambda = "Canard"
> lambda = 12
> lambda = (32)

