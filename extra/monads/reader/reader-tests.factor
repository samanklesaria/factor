USING: tools.test math kernel monads monads.reader ;
FROM: monads => do ;
IN: monads.reader.tests

[ 9/11 ] [
    {
        [ ask ]
    } do 9/11 run-reader
] unit-test

[ 8 ] [
    {
        [ ask ]
        [ 3 + reader-monad return ]
    } do
    5 run-reader
] unit-test

[ 6 ] [
    f reader-monad return [ drop ask ] bind [ 1 + ] local 5 run-reader
] unit-test