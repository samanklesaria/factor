! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models sequences ui.gadgets
ui.gadgets.tables ui.gestures ;
FROM: models => change-model ;
IN: ui.gadgets.model-tables

TUPLE: model-table < table actions delete-hook ;

: <model-table> ( model renderer -- model-table )
    model-table new-table
        f <model> >>actions
        f <model> >>selection-index
        dup actions>> [ set-model ] curry >>action ;

: <model-table*> ( renderer -- model-table ) { } <model> swap <model-table> ;

model-table H{ { T{ key-up f f "DELETE" } [
    [ [ selection>> value>> ] [ delete-hook>> ] bi call( object -- ) ]
    [ [ selection-index>> value>> ] [ model>> ] bi [ remove-nth ] change-model ] bi
] } } set-gestures