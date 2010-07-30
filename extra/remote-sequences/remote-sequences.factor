! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel modules.rpc-server
namespaces sequences threads random
remote-sequences.shared words calendar ;
IN: remote-sequences service
 
<PRIVATE

SYMBOL: seqs
H{ } clone seqs set-global

SYMBOL: seq-timeouts
V{ } clone seq-timeouts set-global

PRIVATE>

: (remote-seq) ( seq name -- seq )
    dup seqs get-global at
    [ nip ] [ swap over seqs get-global set-at ] if
    remote-sequence new swap >>id ;

: <remote-seq> ( name -- seq ) V{ } clone swap (remote-seq) ;

: >remote-seq ( seq -- remote-seq ) gensym
    [ (remote-seq) ]
    [ now 1 minutes time+ seq-timeouts get-global set-at ] bi ;

<PRIVATE
: wait ( remote-seq -- remote-seq )
    dup used?>> [ 50 random sleep wait ] when ;
PRIVATE>

: cached ( remote-seq -- seq ) id>> seqs get-global at ;

M: remote-sequence length cached length ;
M: remote-sequence nth cached nth ;
M: remote-sequence like cached like >remote-seq ;
M: remote-sequence set-nth wait id>> seqs get-global [ [ set-nth ] keep ] change-at ;
M: remote-sequence set-length wait id>> seqs get-global [ [ set-length ] keep ] change-at ;
M: remote-sequence lengthen wait id>> seqs get-global [ [ lengthen ] keep ] change-at ;
M: remote-sequence new-sequence cached new-sequence >remote-seq ;

! for non-destructive operations where fetching each time is not wanted
: with-cached ( remote-seq quot -- remote-seq ) over cached swap call ; inline