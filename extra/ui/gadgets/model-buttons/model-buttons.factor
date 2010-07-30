! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences ui.gadgets ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.image-buttons models ;
IN: ui.gadgets.model-buttons

TUPLE: model-button < button value ;

: new-model-button ( label class -- button )
    [ [ [ value>> ] keep or ] keep set-control-value ] swap
    new-button f <model> >>model ;

: <model-button> ( label -- button ) model-button new-model-button ;

: <model-border-button> ( label -- button ) <model-button> border-button-theme ;

SYNTAX: IMG-MODEL-BUTTON: image-prep [ <model-button> ] curry over push-all ;