! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators hashtables kernel locals
models models.merge models.proxy math math.order sequences graphs.tracked ;
FROM: models.product => product new-product ;
IN: models.product.unified

TUPLE: unified-product < product values ;

<PRIVATE

: (>graph) ( graph model seen -- graph )
    2dup at [ 2drop ] [
        [ dupd set-at ] 2keep -rot
        dup proxy-deps
            [ over proxy? [ 3drop ] [ rot add-tracked-vertex ] if ]
            [ nip rot [ (>graph) ] curry swapd reduce ] 3bi
    ] if ;

: >graph ( graph model -- graph )
    [ H{ } clone (>graph) H{ } clone f 2array ] keep pick set-at ;

: deep-connections ( model graph -- connections )
    2dup value [ unified-product? not ] filter [ drop 1array ]
    [ swap [ deep-connections ] curry map concat nip ] if-empty ;

:: creator ( m hs graph -- model )
    m dup graph deep-connections
    hs [ unified-product? not ] filter
    <proxy> graph over >graph
    over dup associate f 2array m rot set-at ;

: combine ( m hs -- combined )
    dup [ [ not ] [ proxy? ] bi or ] find drop
    [ nip sift dup length {
        { 0 [ drop f ] }
        { 1 [ first ] }
        [ drop merge ]
    } case ] [ drop ] if ;

:: walk ( m graph -- model' )
    m graph seen?
    [ f ] [
        m graph value dup length 1 > [
            m swap graph creator
            [ dependents>> [ graph walk drop ] each ] 
            [ dup base>> graph walk 1array combine ] bi
        ] [ drop
            m graph seen
            m dup proxy-deps [ graph walk ] map combine
        ] if
    ] if ;

PRIVATE>

: new-unified ( models class -- model )
    dupd dupd new-product [
        H{ } clone swap >graph
        [ walk ] curry map sift
    ] keep swap >>dependencies swap >>values ;

: <unified-product> ( models -- product )
    unified-product new-unified ;

: unified-value ( model quot -- seq )
    [ values>> ] dip map ; inline

: set-unified-value ( seq model quot -- )
    [ values>> ] dip 2each ; inline

M: unified-product model-changed
    nip
    dup [ value>> ] unified-value >>value
    notify-connections ;

M: unified-product model-activated dup model-changed ;

M: unified-product update-model
    dup value>> swap [ set-model ] set-unified-value ;

M: unified-product range-value
    [ range-value ] unified-value ;

M: unified-product range-page-value
    [ range-page-value ] unified-value ;

M: unified-product range-min-value
    [ range-min-value ] unified-value ;

M: unified-product range-max-value
    [ range-max-value ] unified-value ;

M: unified-product range-max-value*
    [ range-max-value* ] unified-value ;

M: unified-product set-range-value
    [ clamp-value ] keep
    [ set-range-value ] set-unified-value ;

M: unified-product set-range-page-value
    [ set-range-page-value ] set-unified-value ;

M: unified-product set-range-min-value
    [ set-range-min-value ] set-unified-value ;

M: unified-product set-range-max-value
    [ set-range-max-value ] set-unified-value ;