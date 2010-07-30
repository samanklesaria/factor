! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel monads ;
IN: monads.maybe

SINGLETON: maybe-monad
INSTANCE:  maybe-monad monad

SINGLETON: nothing

TUPLE: just value ;
: just ( value -- just ) \ just boa ;

UNION: maybe just nothing ;
INSTANCE: maybe monad

M: maybe monad-of drop maybe-monad ;

M: maybe-monad return drop just ;
M: maybe-monad fail   2drop nothing ;

M: nothing >>= '[ drop _ ] ;
M: just    >>= value>> '[ _ swap call( x -- y ) ] ;

: if-maybe ( maybe just-quot nothing-quot -- )
    pick nothing? [ 2nip call ] [ drop [ value>> ] dip call ] if ; inline