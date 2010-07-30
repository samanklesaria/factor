! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel locals math sequences ;
IN: sequences.appended

: appended-length ( seq1 seq2 -- length ) [ length ] bi@ + ;

:: appended-nth ( n seq1 seq2 -- elt )
    n seq1 ?nth
    [ n seq1 length - seq2 nth ] unless* ;

: appended-random ( seq1 seq2 ) [ appended-length random ] 2keep appended-nth ;