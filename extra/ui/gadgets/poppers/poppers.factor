! Copyright (C) 2009 Sam Anklesaria
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors combinators kernel math
models models.combinators namespaces sequences
ui.gadgets ui.gadgets.layout ui.gadgets.tracks
ui.gestures ui.gadgets.line-support
ui.gadgets.editors fry models.product
ui.tools.inspector ;
IN: ui.gadgets.poppers

TUPLE: popped < model-field { fatal? initial: t } ;
TUPLE: popped-editor < multiline-editor ;
TUPLE: popper < track submodels { update? initial: t }
    { focus-hook initial: [ drop ] } { unfocus-hook initial: [ drop ] }
    { quot initial: [ ] } { setter-quot initial: [ ] } { delete-hook initial: [ drop ] } ;

: <popped> ( popper value -- gadget ) <model>
    [ [ submodels>> ] dip add-to-product ]
    [ popped popped-editor new-field swap >>model t >>clipped? ] bi ;

M: popped model-changed
    2dup model>> = [
        dup update?>>
        [ [ value>> ] [ [ parent>> quot>> call( a -- b ) ] [ editor>> ] bi ] bi* set-editor-string ]
        [ t >>update? 2drop ] if
    ] [
        nip f >>update?
        [ [ editor>> editor-string ] keep parent>> setter-quot>> call( a -- b ) ] [ model>> ] bi set-model
    ] if ;

: <empty-popped> ( popper -- popped ) "" over setter-quot>> call( a -- b ) <popped> ;
: set-expansion ( popped size -- ) over dup parent>> [ children>> index ] [ sizes>> ] bi set-nth relayout ;
: new-popped ( popped -- ) [ insertion-point ] [ parent>> <empty-popped> ] bi
    [ rot 1 + f add-gadget-at* drop ] keep [ relayout ] [ request-focus ] bi ;
: focus-prev ( popped -- ) dup parent>> children>> length 1 =
    [ drop ] [
        insertion-point [ 1 - dup -1 = [ drop 1 ] when ] [ children>> ] bi* nth
        [ request-focus ] [ editor>> end-of-document ] bi
    ] if ;
: initial-popped ( popper -- ) dup <empty-popped> [ f add-gadget* drop ] keep request-focus ;

: (delete-popped) ( popped -- )
    {
        [ dup parent>> delete-hook>> call( a -- ) ]
        [ model>> ] [ parent>> submodels>> product-delete ]
        [ focus-prev ] [ unparent ]
    } cleave ;

: if-empty-editor ( popped quot1 quot2 -- ) [ dup editor>> editor-string empty? ] 2dip if ; inline

: delete-popped ( popped -- )
    [
        dup fatal?>> [ (delete-popped) ] [ t >>fatal? drop ] if
    ] [ f >>fatal? drop ] if-empty-editor ;

: <popper> ( model -- popper ) vertical popper new-track swap >>model
    V{ } clone <product> [ add-connection ] 2keep >>submodels ;

popped H{
    { gain-focus [
        [ 1 set-expansion ]
        [ dup parent>> focus-hook>> call( a -- ) ] bi
    ] }
    { lose-focus [
        dup parent>> dup
        '[
            [ (delete-popped) ]
            [ [ _ unfocus-hook>> call( a -- ) ] [ f set-expansion ] bi ] if-empty-editor
        ] [ drop ] if
    ] }
    { T{ key-up f f "RET" } [ dup editor>> delete-previous-character new-popped ] }
    { T{ key-up f f "BACKSPACE" } [ delete-popped ] }
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

M: popped graft*
    [ dup editor>> model>> add-connection ]
    [ dup model>> add-connection ]
    [ [ model>> ] keep model-changed ] tri ;