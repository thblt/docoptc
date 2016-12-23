-- This module provides abstract intermediate representations destined
-- to be compiled to actual programming languages.

module Text.Docoptc.IR where

import qualified Data.Map as M

data Type = BoolT
          | CharT
          | StringT
          | IntT
          | FloatT
          | DoubleT
          | Array Type

data Variable = Variable Type String
data Literal a = Literal Type a

data Value = NamedConstant String
data Condition = Not Condition
               | Or Condition Condition
               | And Condition Condition
               | Xor Condition Condition
               | Equals Value Value
               | Lower Value Value
               | LowerEqual Value Value
               | Greater Value Value
               | GreaterEqual Value Value

type StoreTemplate = Type

data ProceduralIR = ProceduralIR StoreTemplate ProceduralPCode

data ProceduralPCode =
