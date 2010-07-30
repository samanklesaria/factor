! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs graphs kernel namespaces sequences ;
IN: graphs.tracked

: tracked-nest ( key -- hash ) graph get [ drop H{ } clone f 2array ] cache ;

: add-tracked-vertex ( vertex edges graph -- )
    [ [ dupd tracked-nest first set-at ] with each ] if-graph ; inline
    
: seen ( model graph -- )
    [ first t 2array ] change-at ;

: seen? ( model graph -- ? ) at second ;

: if-seen ( model graph quot1 quot2 -- )
    [ 2dup seen? ]
    [ [ drop ] swap compose ]
    [ [ dupd seen ] swap compose ] tri*
    if ; inline

: value ( key graph -- value ) at first keys ;

