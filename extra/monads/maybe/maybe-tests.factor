USING: tools.test math kernel monads monads.maybe sequences ;
FROM: monads => do ;
IN: monads.tests

[ 666 ] [
    111 just [ 6 * ] fmap [ ] [ "OOPS" throw ] if-maybe
] unit-test

[ nothing ] [
    111 just [ maybe-monad fail ] bind
] unit-test

[ nothing ] [
    {
        [ "hi" just ]
        [ " bye" append just ]
        [ drop nothing ]
        [ reverse just ]
    } do
] unit-test

[ nothing ] [
    5 just nothing maybe-monad apply
] unit-test

[ T{ just f 15 } ] [
    5 just [ 10 + ] just maybe-monad apply
] unit-test
