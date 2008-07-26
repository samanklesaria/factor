USING: kernel compiler.tree.builder compiler.tree
compiler.tree.propagation compiler.tree.copy-equiv
compiler.tree.def-use tools.test math math.order
accessors sequences arrays kernel.private vectors
alien.accessors alien.c-types sequences.private
byte-arrays classes.algebra math.functions math.private
strings ;
IN: compiler.tree.propagation.tests

\ propagate must-infer
\ propagate/node must-infer

: final-info ( quot -- seq )
    build-tree
    compute-def-use
    compute-copy-equiv
    propagate
    last-node node-input-infos ;

: final-classes ( quot -- seq )
    final-info [ class>> ] map ;

: final-literals ( quot -- seq )
    final-info [ literal>> ] map ;

[ V{ } ] [ [ ] final-classes ] unit-test

[ V{ fixnum } ] [ [ 1 ] final-classes ] unit-test

[ V{ fixnum } ] [ [ 1 >r r> ] final-classes ] unit-test

[ V{ fixnum object } ] [ [ 1 swap ] final-classes ] unit-test

[ V{ array } ] [ [ 10 f <array> ] final-classes ] unit-test

[ V{ array } ] [ [ { array } declare ] final-classes ] unit-test

[ V{ array } ] [ [ 10 f <array> swap [ ] [ ] if ] final-classes ] unit-test

[ V{ fixnum } ] [ [ dup fixnum? [ ] [ drop 3 ] if ] final-classes ] unit-test

[ V{ 69 } ] [ [ [ 69 ] [ 69 ] if ] final-literals ] unit-test

[ V{ fixnum } ] [ [ { fixnum } declare bitnot ] final-classes ] unit-test

[ V{ number } ] [ [ + ] final-classes ] unit-test

[ V{ float } ] [ [ { float integer } declare + ] final-classes ] unit-test

[ V{ float } ] [ [ /f ] final-classes ] unit-test

[ V{ integer } ] [ [ /i ] final-classes ] unit-test

[ V{ integer } ] [ [ 255 bitand ] final-classes ] unit-test

[ V{ integer } ] [
    [ [ 255 bitand ] [ 65535 bitand ] bi + ] final-classes
] unit-test

[ V{ fixnum } ] [
    [
        { fixnum } declare [ 255 bitand ] [ 65535 bitand ] bi +
    ] final-classes
] unit-test

[ V{ integer } ] [
    [ { fixnum } declare [ 255 bitand ] keep + ] final-classes
] unit-test

[ V{ integer } ] [
    [ { fixnum } declare 615949 * ] final-classes
] unit-test

[ V{ null } ] [
    [ { null null } declare + ] final-classes
] unit-test

[ V{ null } ] [
    [ { null fixnum } declare + ] final-classes
] unit-test

[ V{ float } ] [
    [ { float fixnum } declare + ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 255 bitand >fixnum 3 bitor ] final-classes
] unit-test

[ V{ 0 } ] [
    [ >fixnum 1 mod ] final-literals
] unit-test

[ V{ 69 } ] [
    [ >fixnum swap [ 1 mod 69 + ] [ drop 69 ] if ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 10 > [ 1 - ] when ] final-classes
] unit-test

[ V{ integer } ] [ [ >fixnum 2 * ] final-classes ] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < drop 2 * ] final-classes
] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < [ 2 * ] when ] final-classes
] unit-test

[ V{ integer } ] [
    [ >fixnum dup 10 < [ 2 * ] [ 2 * ] if ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 10 < [ dup -10 > [ 2 * ] when ] when ] final-classes
] unit-test

[ V{ f } ] [
    [ dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if ] final-literals
] unit-test

[ V{ 9 } ] [
    [
        123 bitand
        dup 10 < [ dup 8 > [ drop 9 ] unless ] [ drop 9 ] if
    ] final-literals
] unit-test

[ V{ fixnum } ] [
    [
        >fixnum
        dup [ 10 < ] [ -10 > ] bi and not [ 2 * ] unless
    ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare (clone) ] final-classes
] unit-test

[ V{ vector } ] [
    [ vector new ] final-classes
] unit-test

[ V{ fixnum } ] [
    [
        [ uchar-nth ] 2keep [ uchar-nth ] 2keep uchar-nth
        >r >r 298 * r> 100 * - r> 208 * - 128 + -8 shift
        255 min 0 max
    ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 0 dup 10 > [ 2 * ] when ] final-classes
] unit-test

[ V{ f } ] [
    [ [ 0.0 ] [ -0.0 ] if ] final-literals
] unit-test

[ V{ 1.5 } ] [
    [ /f 1.5 min 1.5 max ] final-literals
] unit-test

[ V{ 1.5 } ] [
    [
        /f
        dup 1.5 <= [ dup 1.5 >= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

[ V{ 1.5 } ] [
    [
        /f
        dup 1.5 <= [ dup 10 >= [ ] [ drop 1.5 ] if ] [ drop 1.5 ] if
    ] final-literals
] unit-test

[ V{ f } ] [
    [
        /f
        dup 0.0 <= [ dup 0.0 >= [ drop 0.0 ] unless ] [ drop 0.0 ] if
    ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ 0 dup 10 > [ 100 * ] when ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ 0 dup 10 > [ drop "foo" ] when ] final-classes
] unit-test

[ V{ fixnum } ] [
    [ { fixnum } declare 3 3 - + ] final-classes
] unit-test

[ V{ t } ] [
    [ dup 10 < [ 3 * 30 < ] [ drop t ] if ] final-literals
] unit-test

[ V{ "d" } ] [
    [
        3 {
            [ "a" ]
            [ "b" ]
            [ "c" ]
            [ "d" ]
            [ "e" ]
            [ "f" ]
            [ "g" ]
            [ "h" ]
        } dispatch
    ] final-literals
] unit-test

[ V{ "hi" } ] [
    [ [ "hi" ] [ 123 3 throw ] if ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ >fixnum dup 100 < [ 1+ ] [ "Oops" throw ] if ] final-classes
] unit-test

[ V{ -1 } ] [
    [ 0 dup 100 < not [ 1+ ] [ 1- ] if ] final-literals
] unit-test

[ V{ fixnum } ] [
    [ [ 1 >r ] [ 2 >r ] if r> 3 + ] final-classes
] unit-test

[ V{ 2 } ] [
    [ [ 1 ] [ 1 ] if 1 + ] final-literals
] unit-test

[ V{ string string } ] [
    [
        2dup [ dup string? [ "Oops" throw ] unless ] bi@ 2drop
    ] final-classes
] unit-test

! Array length propagation
[ V{ t } ] [ [ 10 f <array> length 10 = ] final-literals ] unit-test

[ V{ t } ] [ [ [ 10 f <array> ] [ 10 <byte-array> ] if length 10 = ] final-literals ] unit-test

[ V{ t } ] [ [ [ 1 f <array> ] [ 2 f <array> ] if length 3 < ] final-literals ] unit-test

! Slot propagation
TUPLE: prop-test-tuple { x integer } ;

[ V{ integer } ] [ [ { prop-test-tuple } declare x>> ] final-classes ] unit-test

TUPLE: another-prop-test-tuple { x ratio initial: 1/2 } ;

UNION: prop-test-union prop-test-tuple another-prop-test-tuple ;

[ t ] [
    [ { prop-test-union } declare x>> ] final-classes first
    rational class=
] unit-test

TUPLE: fold-boa-test-tuple { x read-only } { y read-only } { z read-only } ;

[ V{ T{ fold-boa-test-tuple f 1 2 3 } } ]
[ [ 1 2 3 fold-boa-test-tuple boa ] final-literals ]
unit-test

TUPLE: immutable-prop-test-tuple { x sequence read-only } ;

[ V{ T{ immutable-prop-test-tuple f "hey" } } ] [
    [ "hey" immutable-prop-test-tuple boa ] final-literals
] unit-test

[ V{ { 1 2 } } ] [
    [ { 1 2 } immutable-prop-test-tuple boa x>> ] final-literals
] unit-test

[ V{ array } ] [
    [ { array } declare immutable-prop-test-tuple boa x>> ] final-classes
] unit-test

[ V{ complex } ] [
    [ <complex> ] final-classes
] unit-test

[ V{ complex } ] [
    [ { float float } declare dup 0.0 <= [ "Oops" throw ] [ rect> ] if ] final-classes
] unit-test

[ V{ float float } ] [
    [
        { float float } declare
        dup 0.0 <= [ "Oops" throw ] when rect>
        [ real>> ] [ imaginary>> ] bi
    ] final-classes
] unit-test

[ V{ complex } ] [
    [
        { float float object } declare
        [ "Oops" throw ] [ <complex> ] if
    ] final-classes
] unit-test

[ V{ number } ] [ [ [ "Oops" throw ] [ 2 + ] if ] final-classes ] unit-test
[ V{ number } ] [ [ [ 2 + ] [ "Oops" throw ] if ] final-classes ] unit-test

[ V{ POSTPONE: f } ] [
    [ dup 1.0 <= [ drop f ] [ 0 number= ] if ] final-classes
] unit-test

! Don't fold this
TUPLE: mutable-tuple-test { x sequence } ;

[ V{ sequence } ] [
    [ "hey" mutable-tuple-test boa x>> ] final-classes
] unit-test

[ V{ sequence } ] [
    [ T{ mutable-tuple-test f "hey" } x>> ] final-classes
] unit-test

! Mixed mutable and immutable slots
TUPLE: mixed-mutable-immutable { x integer } { y sequence read-only } ;

[ V{ integer array } ] [
    [
        3 { 2 1 } mixed-mutable-immutable boa
        [ x>> ] [ y>> ] bi
    ] final-classes
] unit-test
