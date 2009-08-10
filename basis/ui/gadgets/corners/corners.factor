! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces ui.gadgets.frames
ui.pens.image ui.gadgets.icons ui.gadgets.grids ui.gadgets ;
IN: ui.gadgets.corners

CONSTANT: @center { 1 1 }
CONSTANT: @left { 0 1 }
CONSTANT: @right { 2 1 }
CONSTANT: @top { 1 0 }
CONSTANT: @bottom { 1 2 }

CONSTANT: @top-left { 0 0 }
CONSTANT: @top-right { 2 0 }
CONSTANT: @bottom-left { 0 2 }
CONSTANT: @bottom-right { 2 2 }

SYMBOL: name

: corner-image ( name -- image )
    [ name get "-" ] dip 3append theme-image ;

: corner-icon ( name -- icon )
    corner-image <icon> ;

: /-----\ ( corner -- corner )
    "top-left" corner-icon @top-left add-gadget*
    "top-middle" corner-icon @top add-gadget*
    "top-right" corner-icon @top-right add-gadget* ;

: |-----| ( gadget corner -- corner )
    "left-edge" corner-icon @left add-gadget*
    swap @center add-gadget*
    "right-edge" corner-icon @right add-gadget* ;

: \-----/ ( corner -- corner )
    "bottom-left" corner-icon @bottom-left add-gadget*
    "bottom-middle" corner-icon @bottom add-gadget*
    "bottom-right" corner-icon @bottom-right add-gadget* ;

: make-corners ( class name quot -- corners )
    [ [ [ 3 3 ] dip new-frame { 1 1 } >>filled-cell ] dip name ] dip
    with-variable ; inline