! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models sequences ;
IN: models.multi

: <multi-model> ( models kind -- model ) f swap new-model [ [ add-dependency ] curry each ] keep ;
TUPLE: multi-model < model ;
M: multi-model model-activated dup dependencies>>
    [ value>> ] find nip
    [ swap model-changed ] [ drop ] if* ;
M: multi-model model-changed [ value>> ] dip set-model ;

: merge ( models -- model ) multi-model <multi-model> ;
: 2merge ( model1 model2 -- model ) 2array merge ;

: <basic> ( value -- model ) multi-model new-model ;