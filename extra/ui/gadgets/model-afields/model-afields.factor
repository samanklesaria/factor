! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models models.combinators ui.gadgets
ui.gadgets.editors ui.gestures ui.gadgets.layout-protocol ;
IN: ui.gadgets.model-afields

TUPLE: model-afield < model-field returns output ;

M: model-field output-model output>> ;

: <model-afield> ( model -- gadget )
    model-afield editor new-field swap
    init-model [ f <model> [ updates ] keep ] keep
    [ rot ] dip >>model swap >>returns swap >>output ;

: <model-afield*> ( -- gadget ) "" <model> <model-afield> ;

model-afield H{
    { T{ key-down f f "RET" } [ returns>> t swap set-model ] }
} set-gestures