! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel monads ;
IN: monads.either

SINGLETON: either-monad
INSTANCE:  either-monad monad

TUPLE: left value ;
: left ( value -- left ) \ left boa ;

TUPLE: right value ;
: right ( value -- right ) \ right boa ;

UNION: either left right ;
INSTANCE: either monad

M: either monad-of drop either-monad ;

M: either-monad return  drop right ;
M: either-monad fail    drop left ;

M: left  >>= '[ drop _ ] ;
M: right >>= value>> '[ _ swap call( x -- y ) ] ;

: if-either ( value left-quot right-quot -- )
    [ [ value>> ] [ left? ] bi ] 2dip if ; inline