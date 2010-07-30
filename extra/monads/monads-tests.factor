USING: tools.test math kernel monads ;
FROM: monads => do ;
IN: monads.tests

[ 5 ] [ 1 identity-monad return [ 4 + ] fmap run-identity ] unit-test
[ "OH HAI" identity-monad fail ] must-fail

[ T{ identity f 7 } ]
[
    4 identity-monad return
    [ 3 + ] identity-monad return
    identity-monad apply
] unit-test