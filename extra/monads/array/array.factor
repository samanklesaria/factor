! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel monads sequences ;
IN: monads.array

SINGLETON: array-monad
INSTANCE:  array-monad monad
INSTANCE:  array monad

M: array-monad return  drop 1array ;
M: array-monad fail   2drop { } ;

M: array monad-of drop array-monad ;

M: array >>= '[ _ swap map concat ] ;