! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models models.multi ;
IN: models.filter

TUPLE: filter-model < multi-model quot ;
M: filter-model model-changed over value>>
   [ [ value>> ] dip 2dup quot>> call( a -- ? )
   [ set-model ] [ 2drop ] if ] [ 2drop ] if ;
: filter-model ( model quot -- filter-model ) [ 1array \ filter-model <multi-model> ] dip >>quot ;
: <discrete> ( model -- model' ) [ ] filter-model ;