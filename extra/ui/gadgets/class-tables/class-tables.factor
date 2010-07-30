! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators fry generalizations kernel
sequences ui.gadgets.model-tables ui.gadgets.tables
ui.gadgets.tables.renderers unicode.data words
models.slot present ;
IN: ui.gadgets.class-tables

: class-slots ( class -- slots )
    "slots" word-prop [ name>> ] map ;

: upcase-starts ( strs -- strs' )
    [ unclip ch>upper prefix ] map ;

: table-quot ( slots -- quot )
    [ slot>getter ] map [   
        [ [ execute( object -- value ) present ] curry ] map
    ] keep length '[ _ cleave _ narray ] ;

: <class-table> ( model class -- table )
    class-slots
    [ table-quot <quot-renderer> swap >>quot ] keep
    upcase-starts >>column-titles <model-table> ;