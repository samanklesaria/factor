! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ui.gadgets.model-buttons ui.gadgets.key-handlers
ui.gadgets ui.gadgets.buttons ui.gestures kernel fry ;
IN: ui.gadgets.default-buttons

TUPLE: default-button < model-button key ;

M: default-button graft* key>> request-focus ;

: <default-button> ( label -- key )
    default-button new-model-button
    [ [ T{ key-down f f "RET" } <key> ] keep over >>key model>> >>model ]
    [ '[ drop _ t swap set-control-value ] ] bi >>quot ;

! old method took over the world
! M: default-button graft*
!     dup find-world dup gadget-child
!     T{ key-down f f "RET" } <key>
!     rot '[ drop "coolo" throw _ button-clicked ] >>quot
!     [ add-gadget drop ] keep request-focus ;
! 
! : <default-button> ( label -- key )
!     default-button new-model-button ;