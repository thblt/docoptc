> module Main (main) where

> import Text.Docoptc.Types
> import Text.Docoptc.Parser
> 
> main = interact $ show . makeDocoptSource . lines
