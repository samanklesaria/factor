! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models models.product ;
EXCLUDE: sequences => product ;
IN: models.product.discrete

TUPLE: discrete-product < product ;

M: discrete-product model-changed
    nip dup dependencies>> [ value>> ] all?
    [ dup [ value>> ] product-value >>value notify-connections ]
    [ drop ] if ;

: <discrete-product> ( models -- product )
    discrete-product new-product ;