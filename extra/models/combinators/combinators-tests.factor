! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math models models.combinators monads
tools.test monads.model locals ;
IN: models.combinators.tests

[ 2 ] [
    1 <model>
    t <model> [ [ 1 + ] fmap ] [ "false called" throw ] if-model
    dup activate-model value>>
] unit-test

[ "false" ] [
    [let 1 <model> :> a
        f <model> [ [ 1 = ] fmap [ a swap [ [ "true" ] <$ ] [ [ "false" ] <$ ] if ] bind
        dup activate-model ] keep 2 swap set-model value>> ]
] unit-test

[ 2 ] [
    1 <model> [ [ 1 + ] fmap ] [ "false called" throw ] if*-model
    dup activate-model value>>
] unit-test

[ f ] [
    f <model> [ [ [ 1 + ] fmap ] [ "ha" <model> ] if*-model
    dup activate-model ] keep f swap set-model value>>
] unit-test