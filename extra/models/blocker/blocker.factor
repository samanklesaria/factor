! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors models arrays kernel sequences models.product ;
IN: models.blocker

TUPLE: blocker < model ;

M: blocker model-activated
    dup dependencies>> [ value>> ] map-find drop swap value<< ;

M: blocker model-changed 2drop ;

: <blocker> ( dependency -- blocker )
    1array blocker new-product ;