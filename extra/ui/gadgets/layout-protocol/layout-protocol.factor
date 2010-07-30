! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel locals sequences ui.gadgets
ui.gadgets.private vectors ui.gadgets.tracks ui.gadgets.grids
ui.gadgets.grids.private ui.gadgets.tables ui.gadgets.sliders
ui.gadgets.scrollers models models.range arrays ui.gadgets.packs
ui.gadgets.books ui.gadgets.frames ;
IN: ui.gadgets.layout-protocol

SYMBOL: default ! no given extra info

GENERIC: remove-info ( gadget parent -- )
M: gadget remove-info 2drop ;

GENERIC: clear-info ( parent -- )
M: gadget clear-info drop ;

GENERIC: (layout-info) ( gadget parent -- info )
M: gadget (layout-info) 2drop default ;

GENERIC: add-info ( info parent -- )
M: gadget add-info 2drop ;

GENERIC# add-info-at 1 ( info parent index -- )
M: gadget add-info-at 3drop ;

: layout-info ( gadget -- info ) dup parent>> (layout-info) ;

: unparent ( gadget -- )
    not-in-layout
    [
        dup parent>> dup
        [
            [ remove-info ] [
                over (unparent)
                [ unfocus-gadget ]
                [ children>> remove! drop ]
                [ nip relayout ]
                2tri
            ] 2bi
        ] [ 2drop ] if
    ] when* ;

<PRIVATE

: (clear-gadget) ( gadget -- )
    dup [ (unparent) ] each-child
    f >>focus f >>children drop ;

PRIVATE>

: clear-gadget ( gadget -- )
    dup clear-info
    not-in-layout
    [ (clear-gadget) ] [ relayout ] bi ;

<PRIVATE

: with-layout ( quot -- parent )
    not-in-layout call dup relayout ; inline

: with-unparent ( child parent quot -- ) -rot
    {
        [ drop unparent ]
        [ >>parent drop ]
        [ rot call ]
        [ graft-state>> second [ graft ] [ drop ] if ]
    } 2cleave ; inline

: ((add-gadget)) ( child parent info -- ) over
    [ [ [ ?push ] change-children drop ] with-unparent ] 2dip add-info ;

: (add-gadget) ( child parent -- ) default ((add-gadget)) ;

: (add-raw-gadget) ( child parent -- )
   [ [ ?push ] change-children drop ] with-unparent ;

PRIVATE>

: add-gadget ( parent child -- parent )
    [ over (add-gadget) ] with-layout ;

: add-gadget* ( parent child info -- parent )
    [ [ over ] dip ((add-gadget)) ] with-layout ;

: add-gadgets ( parent children -- parent )
    [ [ over (add-gadget) ] each ] with-layout ;

: add-raw-gadget ( parent children -- parent )
    [ over (add-raw-gadget) ] with-layout ;

: add-raw-gadgets ( parent children -- parent )
    [ [ over (add-raw-gadget) ] each ] with-layout ;

:: add-gadget-at* ( parent child index info -- parent )
    [ child parent
        [ [ index swap insert-nth ] change-children
        info swap index add-info-at parent ] with-unparent
    ] with-layout ;

: add-gadget-at ( parent child index -- parent ) default add-gadget-at* ;

GENERIC: output-model ( gadget -- model )
M: model output-model ;
M: gadget output-model model>> ;

! Grids

M: grid add-info over default =
    [ 2drop ]
    [
        [ swap grid-child unparent ]
        [ [ children>> last ] keep rot grid@ set-nth ] 2bi
    ] if ;

M: grid clear-info grid>> delete-all ;

M: grid add-info-at drop add-info ;

! Tracks

M: track (layout-info)
    [ children>> index ] [ sizes>> ] bi nth ;

: check-default ( info gadget -- info' gadget )
    over default = [ [ drop f ] dip ] when ;

M: track add-info check-default sizes>> push ;

M: track add-info-at [ check-default ] dip
    swap [ insert-nth ] change-sizes drop ;

M: track remove-info
    [ [ children>> index ] keep sizes>> remove-nth! drop ] [ call-next-method ] 2bi ;

! Output Models
M: table output-model selection>> ;
M: slider output-model model>> range-model ;
M: scroller output-model viewport>> children>> first output-model ;
M: pack output-model drop f ;
M: track output-model drop f ;
M: grid output-model drop f ;
M: book output-model drop f ;
M: frame output-model drop f ;
