! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel ui.gadgets.tables ;
IN: ui.gadgets.tables.renderers

! Rendering with quots
TUPLE: quot-renderer
{ quot initial: [ ] }
{ val-quot initial: [ ] }
{ color-quot initial: [ drop f ] }
column-titles column-alignment ;

: <quot-renderer> ( -- quots ) quot-renderer new ;

M: quot-renderer column-titles column-titles>> ;
M: quot-renderer column-alignment column-alignment>> ;
M: quot-renderer row-columns quot>> call( a -- b ) ;
M: quot-renderer row-value val-quot>> call( a -- b ) ;
M: quot-renderer row-color color-quot>> call( a -- b ) ;

! Rendering basic lists
SINGLETON: list-renderer
M: list-renderer row-columns drop 1array ;