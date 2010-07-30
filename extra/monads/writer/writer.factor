! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel monads sequences ;
IN: monads.writer

SINGLETON: writer-monad
INSTANCE:  writer-monad monad

TUPLE: writer value log ;
: writer ( value log -- writer ) \ writer boa ;

M: writer monad-of drop writer-monad ;

M: writer-monad return drop { } writer ;
M: writer-monad fail   "Fail" throw ;

: run-writer ( writer -- value log ) [ value>> ] [ log>> ] bi ;

M: writer >>= '[ [ _ run-writer ] dip '[ @ run-writer ] dip append writer ] ;

: pass ( writer -- writer' ) run-writer [ first2 ] dip swap call( x -- y ) writer ;
: listen ( writer -- writer' ) run-writer [ 2array ] keep writer ;
: tell ( seq -- writer ) f swap writer ;