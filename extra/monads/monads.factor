! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel locals sequences ;
IN: monads

! Functors
GENERIC# fmap 1 ( functor quot -- functor' )
GENERIC# <$ 1 ( functor quot -- functor' )
GENERIC# $> 1 ( functor quot -- functor' )

! Monads

! Mixin type for monad singleton classes, used for return/fail only
MIXIN: monad

GENERIC: monad-of ( mvalue -- singleton )
GENERIC: return ( value singleton -- mvalue )
GENERIC: fail ( value singleton -- mvalue )
GENERIC: >>= ( mvalue -- quot )

M: monad return monad-of return ;
M: monad fail   monad-of fail   ;

: bind ( mvalue quot -- mvalue' ) swap >>= call( quot -- mvalue ) ;
: bind* ( mvalue quot -- mvalue' ) '[ drop @ ] bind ;
: >>   ( mvalue k -- mvalue' ) '[ drop _ ] bind ;

:: lift-m2 ( m1 m2 f monad -- m3 )
    m1 [| x1 | m2 [| x2 | x1 x2 f monad return ] bind ] bind ;

:: apply ( mvalue mquot monad -- result )
    mvalue [| value |
        mquot [| quot |
            value quot call( value -- mvalue ) monad return
        ] bind
    ] bind ;

M: monad fmap over '[ @ _ return ] bind ;

! 'do' notation
: do ( quots -- result ) unclip [ call( -- mvalue ) ] curry dip [ bind ] each ;

! Identity
SINGLETON: identity-monad
INSTANCE:  identity-monad monad

TUPLE: identity value ;
INSTANCE: identity monad

M: identity monad-of drop identity-monad ;

M: identity-monad return drop identity boa ;
M: identity-monad fail   "Fail" throw ;

M: identity >>= value>> '[ _ swap call( x -- y ) ] ;

: run-identity ( identity -- value ) value>> ;
