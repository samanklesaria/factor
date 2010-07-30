USING: accessors combinators kernel models tools.test
ui.gadgets ui.gadgets.debug ui.gadgets.poppers ui.gestures
namespaces ui.private ;
IN: ui.gadgets.poppers.tests

[ "ba" ] [ { "ba" } <model> <popper> [ "a" set-global ] >>delete-hook dup
    [ gadget-child (delete-popped) ] with-grafted-gadget
    "a" get
] unit-test

[ "ra" ] [ { "ra" } <model> <popper> [ "b" set-global ] >>unfocus-hook dup
    [ gadget-child send-lose-focus send-queued-gestures ] with-grafted-gadget
    "b" get control-value
] unit-test

[ V{ } V{ } V{ } V{ } ] [
    { "ha" } <model> <popper> dup [ {
        [ gadget-child (delete-popped) ]
        [ children>> ]
        [ submodels>> dependencies>> ]
        [ submodels>> value>> ]
        [ model>> value>> ]
    } cleave ] with-grafted-gadget
] unit-test

"a" "b" [ off ] bi@