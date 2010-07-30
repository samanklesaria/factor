! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models sequences models.product models.blocker ;
IN: models.merge

TUPLE: merge-model < model ;

M: merge-model model-activated
    dup dependencies>>
    [ [ blocker? not ] [ value>> ] bi and ] find nip
    [ swap model-changed ] [ drop ] if* ;

M: merge-model model-changed [ value>> ] dip set-model ;

: merge ( models -- model ) merge-model new-product ;
: 2merge ( model1 model2 -- model ) 2array merge ;

: <basic> ( value -- model ) merge-model new-model ;