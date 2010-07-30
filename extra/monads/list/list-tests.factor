USING: tools.test math kernel lists promises monads ;
FROM: monads => do ;
IN: monads.list.tests

LAZY: nats-from ( n -- list )
    dup 1 + nats-from cons ;

: nats ( -- list ) 0 nats-from ;

[ 3 ] [
    {
        [ nats ]
        [ dup 3 = [ list-monad return ] [ list-monad fail ] if ]
    } do car
] unit-test