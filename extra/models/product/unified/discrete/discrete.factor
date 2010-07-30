! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models models.product.unified ;
EXCLUDE: sequences => product ;
IN: models.product.unified.discrete

TUPLE: discrete-unified < unified-product ;

M: discrete-unified model-changed
    nip dup values>> [ value>> ] all?
    [ dup [ value>> ] unified-value >>value notify-connections ]
    [ drop ] if ;

M: discrete-unified model-activated dup model-changed ;

: <discrete-unified> ( models -- product )
    discrete-unified new-unified ;