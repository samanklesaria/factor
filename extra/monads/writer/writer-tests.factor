USING: tools.test math kernel monads monads.writer ;
FROM: monads => do ;
IN: monads.writer.tests

[ f { 1 2 3 } ] [
    5 writer-monad return
    [ drop { 1 2 3 } tell ] bind
    run-writer
] unit-test