! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models models.merge models.product ;
IN: models.filter

TUPLE: filter-model < merge-model quot ;
M: filter-model model-changed over value>>
   [ [ value>> ] dip 2dup quot>> call( a -- ? )
   [ set-model ] [ 2drop ] if ] [ 2drop ] if ;
: filter-model ( model quot -- filter-model ) [ 1array \ filter-model new-product ] dip >>quot ;
: discrete ( model -- model' ) [ ] filter-model ;