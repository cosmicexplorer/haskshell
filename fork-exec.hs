-- let's spawn subprocesses

module ForkExec where

doubleMe x = x + x

initials (f:_) (l:_) = [f] ++ ". " ++ [l] ++ "."
