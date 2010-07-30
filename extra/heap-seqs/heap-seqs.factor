! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: make heaps sequences math kernel namespaces ;
IN: heap-seqs

: (heap-head) ( heap n -- ) dup
    building get length >=
    [ 2drop ]
    [ over heap-pop drop , 1 - (heap-head) ] if ;

: heap-head ( heap n -- array ) [ (heap-head) ] { } make ;

: heap>seq ( heap -- array ) [ clone [ , ] slurp-heap ] { } make ;
