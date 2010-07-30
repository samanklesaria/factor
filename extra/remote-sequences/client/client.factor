! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors sequences kernel destructors remote-sequences.shared ;
IN: remote-sequences.client

M: remote-sequence dispose f >>used? drop ;

: with-transaction ( remote-seq quot -- remote-seq )
    [ t >>used? ] swap compose with-disposal ; inline

: remote-map ( xs quot -- xs' ) [ map ] curry with-transaction ; inline

: remote-reduce ( seq id quot -- result ) [ reduce ] 2curry with-transaction ; inline

: remote-filter ( seq quot -- subseq ) [ filter ] curry with-transaction ; inline

: remote-find ( seq quot -- i elt ) [ find ] curry with-transaction ; inline
: remote-index ( obj seq -- n ) [ index ] with with-transaction ; inline
: remote-each ( seq quot -- ) [ each ] curry with-transaction ; inline
: remote-interleave ( seq between quot -- ) [ interleave ] 2curry with-transaction ; inline
: remote-accumulate ( seq id quot -- final newseq ) [ accumulate ] 2curry with-transaction ; inline
: remote-partition ( seq quot -- trueseq falseseq ) [ partition ] curry with-transaction ; inline
: remote-start ( subseq seq -- i ) [ start ] curry with-transaction ; inline
: remote-find-last ( seq quot -- i elt ) [ find-last ] curry with-transaction ; inline