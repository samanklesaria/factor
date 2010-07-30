! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models models.merge sequences
locals models.product ;
IN: models.fold

<PRIVATE
: handle-activation ( model -- )
   dup base>> dup value>> [ swap model-changed ] [ 2drop ] if ;

: handle-change ( model observer -- )
    [ swap value>> ] [ value>> ] [ quot>> ] tri
    swapd call( prev val -- newval ) swap set-model ;

:: dynamic-reduce ( seq identity quot -- result ) seq
    [ identity ]
    [ unclip-slice identity swap quot call( prev elt -- next ) quot dynamic-reduce ] if-empty ;

PRIVATE>

TUPLE: fold-model < model quot ;
M: fold-model model-changed handle-change ;
M: fold-model model-activated notify-connections ;

TUPLE: fold-switch < fold-model base ;
M: fold-switch model-changed 2dup base>> =
    [ [ value>> ] dip set-model ]
    [ handle-change ] if ;
M: fold-switch model-activated handle-activation ;

TUPLE: fold-model* < model quot base values ;
M: fold-model* model-changed 2dup base>> =
    [ [ [ value>> ] [ [ values>> ] [ quot>> ] bi ] bi* swapd dynamic-reduce ] keep set-model ]
    [ [ [ value>> ] [ values>> ] bi* push ]
      [ handle-change ] 2bi
    ] if ;
M: fold-model* model-activated handle-activation ;

: fold ( model oldval quot -- model ) rot 1array
    fold-model new-product swap >>quot swap
    >>value ;

: fold-switch ( model oldmodel quot -- model )
    over [ 2array \ fold-switch new-product ] 2dip
    [ >>quot ] [ >>base ] bi* ;

: fold* ( model oldmodel quot -- model ) over
    [ [ 2array fold-model* new-product V{ } clone >>values ] dip >>quot ]
    dip [ >>base ] [ value>> >>value ] bi ;