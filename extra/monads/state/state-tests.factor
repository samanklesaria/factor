USING: tools.test math kernel monads monads.state ;
FROM: monads => do ;
IN: monads.state.tests

[ 5 ] [
    5 state-monad return "initial state" run-st
] unit-test

[ 8 ] [
    5 state-monad return [ 3 + state-monad return ] bind
    "initial state" run-st
] unit-test

[ 8 ] [
    5 state-monad return >>=
    [ 3 + state-monad return ] swap call
    "initial state" run-st
] unit-test

[ 11 ] [
    f state-monad return >>=
    [ drop get-st ] swap call
    11 run-st
] unit-test

[ 15 ] [
    f state-monad return
    [ drop get-st ] bind
    [ 4 + put-st ] bind
    [ drop get-st ] bind
    11 run-st
] unit-test

[ 15 ] [
    {
        [ f return-st ]
        [ drop get-st ]
        [ 4 + put-st ]
        [ drop get-st ]
    } do
    11 run-st
] unit-test
