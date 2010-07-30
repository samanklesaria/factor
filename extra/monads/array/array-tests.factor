! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel monads ;
IN: monads.array.tests

[ { 10 20 30 } ] [
    { 1 2 3 } [ 10 * ] fmap
] unit-test

[ { } ] [
    { 1 2 3 } [ drop "OOPS" array-monad fail ] bind
] unit-test