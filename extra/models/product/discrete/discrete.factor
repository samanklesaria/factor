! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models models.multi models.product
sequences ;
IN: models.product.discrete

TUPLE: discrete-product < multi-model ;
: <discrete-product> ( models -- product ) discrete-product <multi-model> ;
M: discrete-product model-changed
    nip
    dup dependencies>> [ value>> ] all?
    [ dup [ value>> ] product-value swap set-model ]
    [ drop ] if ;