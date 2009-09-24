! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models models.multi sequences ;
IN: models.fold

TUPLE: fold-model < model quot base values ;
M: fold-model model-changed 2dup base>> =
    [ [ [ value>> ] [ [ values>> ] [ quot>> ] bi ] bi* swapd reduce* ] keep set-model ]
    [ [ [ value>> ] [ values>> ] bi* push ]
      [ [ [ value>> ] [ [ value>> ] [ quot>> ] bi ] bi* call( val oldval -- newval ) ] keep set-model ] 2bi
    ] if ;
: new-fold-model ( deps -- model ) fold-model <multi-model> V{ } clone >>values ;
: fold ( model oldval quot -- model ) rot 1array new-fold-model swap >>quot
   swap >>value ;
: fold* ( model oldmodel quot -- model ) over [ [ 2array new-fold-model ] dip >>quot ]
    dip [ >>base ] [ value>> >>value ] bi ;