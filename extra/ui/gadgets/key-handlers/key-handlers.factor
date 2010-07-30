! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel ui.gadgets.borders ui.gestures
ui.gadgets models ;
IN: ui.gadgets.key-handlers

TUPLE: key-handler < border handlers ;

: <keys> ( gadget -- key-handler )
    key-handler new-border { 0 0 } >>size
    f <model> >>model ;

M: key-handler handle-gesture
    tuck handlers>> at [ call( gadget -- ) f ] [ drop t ] if* ;

TUPLE: key < border handler { quot initial: [ t swap set-control-value ] } ;

: <key> ( gadget handler -- key-handler )
    [ key new-border { 0 0 } >>size ] dip >>handler
    f <model> >>model ;

M: key handle-gesture
    tuck handler>> = 
       [ dup quot>> call( key -- ) f ]
       [ drop t ] if ;
