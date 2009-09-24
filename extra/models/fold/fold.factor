! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models models.multi sequences ;
IN: models.fold

: handle-activation ( model -- )
   dup base>> dup value>> [ swap model-changed ] [ 2drop ] if ;

: handle-change ( model observer -- )
    [ swap value>> ] [ value>> ] [ quot>> ] tri
    swapd call( prev val -- newval ) swap set-model ;

TUPLE: fold-model < model quot ;
: fold ( model oldval quot -- model ) rot 1array
    fold-model <multi-model> swap >>quot swap
    >>value ;

M: fold-model model-changed handle-change ;

TUPLE: fold-switch < fold-model base ;

: fold-switch ( model oldmodel quot -- model )
    [ tuck 2array \ fold-switch <multi-model> ] dip
    >>quot swap >>base ;

M: fold-switch model-changed 2dup base>> =
    [ [ value>> ] dip set-model ]
    [ handle-change ] if ;

M: fold-switch model-activated handle-activation ;

TUPLE: fold-model* < model quot base values ;
M: fold-model* model-changed 2dup base>> =
    [ [ [ value>> ] [ [ values>> ] [ quot>> ] bi ] bi* swapd reduce* ] keep set-model ]
    [ [ [ value>> ] [ values>> ] bi* push ]
      [ handle-change ] 2bi
    ] if ;
M: fold-model* model-activated handle-activation ;

: fold* ( model oldmodel quot -- model ) over
    [ [ 2array fold-model* <multi-model> V{ } clone >>values ] dip >>quot ]
    dip [ >>base ] [ value>> >>value ] bi ;