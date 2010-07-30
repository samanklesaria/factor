! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors models kernel ;
IN: models.arrow

TUPLE: arrow < model model quot ;

: new-arrow ( model quot class -- arrow )
    f swap new-model
    swap >>quot
    over >>model
    [ add-dependency ] keep ;

: <arrow> ( model quot -- arrow ) arrow new-arrow ;

M: arrow model-changed
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;

M: arrow model-activated [ model>> ] keep model-changed ;
