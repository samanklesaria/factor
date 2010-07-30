! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel lists lists.lazy monads ;
IN: monads.list

SINGLETON: list-monad
INSTANCE:  list-monad monad
INSTANCE:  list monad

M: list-monad return drop 1list ;
M: list-monad fail   2drop nil ;

M: list monad-of drop list-monad ;

M: list >>= '[ _ swap lazy-map lconcat ] ;