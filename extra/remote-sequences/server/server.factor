! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar concurrency.flags fry
io.servers.connection kernel math math.order namespaces
remote-sequences remote-sequences.private
sequences threads ;
IN: remote-sequences.server

TUPLE: seq-env server flag ;

<PRIVATE

: killem ( seq n -- ) head-slice [ second seqs get-global delete-at ] each ;

: kill-old-seqs ( -- )
    seq-timeouts get-global [
        [ length ]
        [ dup [ first now before=? ] find drop -1 or 1 + [ killem ] keep ]
        bi -
    ] keep shorten ;

PRIVATE>

: start-remote-seqs* ( server -- )
    [ [ kill-old-seqs t ] loop ] in-thread start-server ;

: start-remote-seqs ( server -- seq-env )
    <flag> [ '[ [ kill-old-seqs _ value>> not ] loop ] in-thread ] keep
    swap [ start-server ] in-thread swap seq-env boa ;

: stop-remote-seqs ( seq-env -- )
    [ flag>> raise-flag ] [ server>> stop-server ] bi ;