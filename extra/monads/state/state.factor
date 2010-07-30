! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel monads sequences ;
IN: monads.state

SINGLETON: state-monad
INSTANCE:  state-monad monad

TUPLE: state quot ;
: state ( quot -- state ) \ state boa ;

INSTANCE: state monad

M: state monad-of drop state-monad ;

M: state-monad return drop '[ _ 2array ] state ;
M: state-monad fail   "Fail" throw ;

: mcall ( x state -- y ) quot>> call( x -- y ) ;

M: state >>= '[ _ swap '[ _ mcall first2 @ mcall ] state ] ;

: get-st ( -- state ) [ dup 2array ] state ;
: put-st ( value -- state ) '[ drop _ f 2array ] state ;

: run-st ( state initial -- value ) swap mcall second ;

: return-st ( value -- mvalue ) state-monad return ;