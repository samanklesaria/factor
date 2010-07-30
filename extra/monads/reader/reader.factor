! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel monads monads.state ;
IN: monads.reader

SINGLETON: reader-monad
INSTANCE:  reader-monad monad

TUPLE: reader quot ;
: reader ( quot -- reader ) \ reader boa ;
INSTANCE: reader monad

M: reader monad-of drop reader-monad ;

M: reader-monad return drop '[ drop _ ] reader ;
M: reader-monad fail   "Fail" throw ;

M: reader >>= '[ _ swap '[ dup _ mcall @ mcall ] reader ] ;

: run-reader ( reader env -- value ) swap quot>> call( env -- value ) ;

: ask ( -- reader ) [ ] reader ;
: local ( reader quot -- reader' ) swap '[ @ _ mcall ] reader ;