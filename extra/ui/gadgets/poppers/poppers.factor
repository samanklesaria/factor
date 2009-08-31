! Copyright (C) 2009 Sam Anklesaria
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors combinators kernel math
models models.combinators namespaces sequences
ui.gadgets ui.gadgets.layout ui.gadgets.tracks
ui.gestures ui.gadgets.line-support
ui.gadgets.editors fry models.product ;
IN: ui.gadgets.poppers

TUPLE: popped < model-field { fatal? initial: t } ;
TUPLE: popped-editor < multiline-editor ;
TUPLE: popper < track submodels { update? initial: t } focus-hook unfocus-hook ;

: <popped> ( popper text -- gadget ) <model> init-model
    [ [ submodels>> ] dip add-to-product ]
    [ popped popped-editor new-field swap >>model t >>clipped? ] bi ;

: set-expansion ( popped size -- ) over dup parent>> [ children>> index ] [ sizes>> ] bi set-nth relayout ;
: new-popped ( popped -- ) [ insertion-point ] [ parent>> "" <popped> ] bi
    [ rot 1 + f add-gadget-at* drop ] keep [ relayout ] [ request-focus ] bi ;
: focus-prev ( popped -- ) dup parent>> children>> length 1 =
    [ drop ] [
        insertion-point [ 1 - dup -1 = [ drop 1 ] when ] [ children>> ] bi* nth
        [ request-focus ] [ editor>> end-of-document ] bi
    ] if ;
: initial-popped ( popper -- ) dup "" <popped> [ f add-gadget* drop ] keep request-focus ;

: <popper> ( model -- popper ) vertical popper new-track swap >>model
    V{ } clone <product> [ add-connection ] 2keep >>submodels ;

popped H{
    { gain-focus [
        [ 1 set-expansion ]
        [ [ model>> value>> ] [ parent>> focus-hook>> ] bi call( a -- ) ] bi
    ] }
    { lose-focus [ dup parent>>
        [ '[ model>> value>> _ unfocus-hook>> call( a -- ) ] [ f set-expansion ] bi ]
        [ drop ] if*
    ] }
    { T{ key-up f f "RET" } [ dup editor>> delete-previous-character new-popped ] }
    { T{ key-up f f "BACKSPACE" } [ dup editor>> editor-string "" =
        [ dup fatal?>> [ [ focus-prev ] [ unparent ] bi ] [ t >>fatal? drop ] if ]
        [ f >>fatal? drop ] if
    ] }
} set-gestures

M: popper handle-gesture swap T{ button-down f f 1 } =
    [ dup hand-gadget get = hand-click# get 2 = and [ initial-popped f ] [ drop t ] if ]
    [ drop t ] if ;

M: popper model-changed 2dup model>> =
    [ dup update?>>
        [
            [ [ submodels>> clear-product ] [ clear-gadget ] bi ]
            [ dup '[ value>> [ _ swap <popped> ] map ] dip [ f add-gadget* ] reduce request-focus ] bi
        ] [ t >>update? 2drop ] if
    ]
    [ f >>update? [ value>> ] dip model>> set-model ] if ;

M: popped pref-dim* dup focus>>
    [ call-next-method ]
    [ [ call-next-method first ] [ editor>> line-height ] bi 2array ] if ;