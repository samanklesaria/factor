! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators kernel math.intervals
math math.order sequences variants generic.single ;
IN: math.intervals.generalized
! shamelessly copied from math.intervals

! generalized positive + negative infinities
VARIANT: infinity start end ;
M: start <=> 2drop +gt+ ;
M: end <=> 2drop +lt+ ;
M: infinity fp-infinity? drop t ;
: (<=>) ( a b -- <=> ) over infinity? [ swap >=< ] [ <=> ] if ;
: gen-after? ( a b -- <=> ) (<=>) +gt+ eq? ;
: gen-after=? ( a b -- <=> ) (<=>) +lt+ eq? not ;
: gen-before? ( a b -- <=> ) (<=>) +lt+ eq? ;
: gen-before=? ( a b -- <=> ) (<=>) +gt+ eq? not ;

: <interval> ( from to -- interval ) ! use special cases for start and end
    {
        { [ 2dup [ first ] bi@ gen-after? ] [ 2drop empty-interval ] }
        { [ 2dup [ first ] bi@ = ] [
            2dup [ second ] both?
            [ interval boa ] [ 2drop empty-interval ] if
        ] }
        { [ 2dup [ { start t } = ] [ { end t } = ] bi* and ] [
            2drop full-interval
        ] }
        [ interval boa ]
    } cond ;

: open-point ( n -- endpoint ) f 2array ;

: closed-point ( n -- endpoint ) t 2array ;

: [a,b] ( a b -- interval )
    [ closed-point ] dip closed-point <interval> ; foldable

: (a,b) ( a b -- interval )
    [ open-point ] dip open-point <interval> ; foldable

: [a,b) ( a b -- interval )
    [ closed-point ] dip open-point <interval> ; foldable

: (a,b] ( a b -- interval )
    [ open-point ] dip closed-point <interval> ; foldable

: [a,a] ( a -- interval )
    closed-point dup <interval> ; foldable

: [start,a] ( a -- interval ) start swap [a,b] ; inline

: [start,a) ( a -- interval ) start swap [a,b) ; inline

: [a,end] ( a -- interval ) end [a,b] ; inline

: (a,end] ( a -- interval ) end (a,b] ; inline

: [start,end] ( -- interval ) full-interval ; inline

: compare-endpoints ( p1 p2 quot -- ? )
    [ 2dup [ first ] bi@ ] dip call [
        2drop t
    ] [
        2dup [ first ] bi@ = [
            [ second ] bi@ not or
        ] [
            2drop f
        ] if
    ] if ; inline

: endpoint= ( p1 p2 -- ? )
    [ [ first ] bi@ = ] [ [ second ] bi@ eq? ] 2bi and ;

: endpoint< ( p1 p2 -- ? ) [ gen-before? ] compare-endpoints ;

: endpoint<= ( p1 p2 -- ? ) [ endpoint< ] [ endpoint= ] 2bi or ;

: endpoint> ( p1 p2 -- ? ) [ gen-after? ] compare-endpoints ;

: endpoint>= ( p1 p2 -- ? ) [ endpoint> ] [ endpoint= ] 2bi or ;

: endpoint-min ( p1 p2 -- p3 ) [ endpoint< ] most ;

: endpoint-max ( p1 p2 -- p3 ) [ endpoint> ] most ;

: interval>points ( int -- from to )
    [ from>> ] [ to>> ] bi ;

: points>interval ( seq -- interval )
    [ [ ] [ endpoint-min ] map-reduce ]
    [ [ ] [ endpoint-max ] map-reduce ] bi
    <interval> ;

: (interval-op) ( p1 p2 quot -- p3 )
    [ [ first ] [ first ] [ call ] tri* ]
    [ drop [ second ] both? ]
    3bi 2array ; inline

: interval-op ( i1 i2 quot -- i3 )
    {
        [ [ from>> ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ to>>   ] [ ] tri* (interval-op) ]
        [ [ from>> ] [ to>>   ] [ ] tri* (interval-op) ]
    } 3cleave 4array points>interval ; inline

: do-empty-interval ( i1 i2 quot -- i3 )
    {
        { [ pick empty-interval eq? ] [ 2drop ] }
        { [ over empty-interval eq? ] [ drop nip ] }
        { [ pick full-interval eq? ] [ 2drop ] }
        { [ over full-interval eq? ] [ drop nip ] }
        [ call ]
    } cond ; inline

: interval-intersect ( i1 i2 -- i3 )
    {
        { [ over empty-interval eq? ] [ drop ] }
        { [ dup empty-interval eq? ] [ nip ] }
        { [ over full-interval eq? ] [ nip ] }
        { [ dup full-interval eq? ] [ drop ] }
        [
            [ interval>points ] bi@
            [ [ swap endpoint< ] most ]
            [ [ swap endpoint> ] most ] bi-curry* bi*
            <interval>
        ]
    } cond ;

: intervals-intersect? ( i1 i2 -- ? )
    interval-intersect empty-interval eq? not ;

: interval-union ( i1 i2 -- i3 )
    {
        { [ over empty-interval eq? ] [ nip ] }
        { [ dup empty-interval eq? ] [ drop ] }
        { [ over full-interval eq? ] [ drop ] }
        { [ dup full-interval eq? ] [ nip ] }
        [ [ interval>points 2array ] bi@ append points>interval ]
    } cond ;

: interval-subset? ( i1 i2 -- ? )
    dupd interval-intersect = ;

: interval-contains? ( x int -- ? )
    dup empty-interval eq? [ 2drop f ] [
        dup full-interval eq? [ 2drop t ] [
            [ from>> first2 [ gen-after=? ] [ gen-after? ] if ]
            [ to>>   first2 [ gen-before=? ] [ gen-before? ] if ]
            2bi and
        ] if
    ] if ;

: special-interval? ( interval -- ? )
    { empty-interval full-interval } member-eq? ;

: interval-singleton? ( int -- ? )
    dup special-interval? [
        drop f
    ] [
        interval>points
        2dup [ second ] both?
        [ [ first ] bi@ = ]
        [ 2drop f ] if
    ] if ;

: interval-closure ( i1 -- i2 )
    dup [ interval>points [ first ] bi@ [a,b] ] when ;

: interval-max ( i1 i2 -- i3 )
    {
        { [ over empty-interval eq? ] [ drop ] }
        { [ dup empty-interval eq? ] [ nip ] }
        { [ 2dup [ full-interval eq? ] both? ] [ drop ] }
        { [ over full-interval eq? ] [ nip from>> first [a,inf] ] }
        { [ dup full-interval eq? ] [ drop from>> first [a,inf] ] }
        [ [ interval-closure ] bi@ [ max ] interval-op ]
    } cond ;

: interval-min ( i1 i2 -- i3 )
    {
        { [ over empty-interval eq? ] [ drop ] }
        { [ dup empty-interval eq? ] [ nip ] }
        { [ 2dup [ full-interval eq? ] both? ] [ drop ] }
        { [ over full-interval eq? ] [ nip to>> first [-inf,a] ] }
        { [ dup full-interval eq? ] [ drop to>> first [-inf,a] ] }
        [ [ interval-closure ] bi@ [ min ] interval-op ]
    } cond ;

: interval-interior ( i1 -- i2 )
    dup special-interval? [
        interval>points [ first ] bi@ (a,b)
    ] unless ;

SYMBOL: incomparable

: left-endpoint-< ( i1 i2 -- ? )
    [ swap interval-subset? ]
    [ nip interval-singleton? ]
    [ [ from>> ] bi@ endpoint= ]
    2tri and and ;

: right-endpoint-< ( i1 i2 -- ? )
    [ interval-subset? ]
    [ drop interval-singleton? ]
    [ [ to>> ] bi@ endpoint= ]
    2tri and and ;

: (interval<) ( i1 i2 -- i1 i2 ? )
    2dup [ from>> ] bi@ endpoint< ;

: interval< ( i1 i2 -- ? )
    {
        { [ 2dup [ special-interval? ] either? ] [ incomparable ] }
        { [ 2dup interval-intersect empty-interval eq? ] [ (interval<) ] }
        { [ 2dup left-endpoint-< ] [ f ] }
        { [ 2dup right-endpoint-< ] [ f ] }
        [ incomparable ]
    } cond 2nip ;

: left-endpoint-<= ( i1 i2 -- ? )
    [ from>> ] [ to>> ] bi* endpoint= ;

: right-endpoint-<= ( i1 i2 -- ? )
    [ to>> ] [ from>> ] bi* endpoint= ;

: interval<= ( i1 i2 -- ? )
    {
        { [ 2dup [ special-interval? ] either? ] [ incomparable ] }
        { [ 2dup interval-intersect empty-interval eq? ] [ (interval<) ] }
        { [ 2dup right-endpoint-<= ] [ t ] }
        [ incomparable ]
    } cond 2nip ;

: interval> ( i1 i2 -- ? )
    swap interval< ;

: interval>= ( i1 i2 -- ? )
    swap interval<= ;

: assume< ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        to>> first [-inf,a) interval-intersect
    ] if ;

: assume<= ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        to>> first [-inf,a] interval-intersect
    ] if ;

: assume> ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        from>> first (a,inf] interval-intersect
    ] if ;

: assume>= ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        from>> first [a,inf] interval-intersect
    ] if ;
