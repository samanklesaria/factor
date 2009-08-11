! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models ui.gadgets ui.gadgets.tables ;
IN: ui.gadgets.model-tables

TUPLE: model-table < table actions ;

M: model-table output-model actions>> ;

: <model-table> ( model renderer -- model-table )
    model-table new-table
        f <model> >>actions
        dup actions>> [ set-model ] curry >>action ;

: <model-table*> ( renderer -- model-table ) { } <model> swap <model-table> ;