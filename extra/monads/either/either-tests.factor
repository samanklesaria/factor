! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel monads.either monads ;
IN: monads.either

[ 100 ] [
    5 either-monad return [ 10 * ] [ 20 * ] if-either
] unit-test

[ T{ left f "OOPS" } ] [
    5 either-monad return >>= [ drop "OOPS" either-monad fail ] swap call
] unit-test