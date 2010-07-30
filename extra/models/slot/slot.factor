! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry kernel models models.arrow
sequences vocabs locals words present strings quotations
continuations classes.union classes ;
FROM: models => change-model ;
IN: models.slot

: at-accessors ( str -- word ) "accessors" vocab words>> at ;

: slot>getter ( slot -- getter ) ">>" append at-accessors ;

: slot>setter ( slot -- getter ) ">>" prepend at-accessors ;

TUPLE: slot-model < arrow setter ;

: slot ( model slot -- slot-model )
    [ f slot-model new-arrow ]
    [   [ slot>getter '[ _ execute( a -- b ) ] >>quot ]
        [ slot>setter '[ _ execute( obj val -- obj ) ] >>setter ] bi
    ] bi* ;

M: slot-model update-model
    [ value>> ] [ setter>> ] [ model>> ] tri
    [ -rot call( obj val -- obj ) ] change-model ;

M: slot-model model-activated
    dup model>>
    [ swap model-changed ] with-locked-model ;

: (coersion) ( class -- word )
    dup [ string = ] [ object = ] bi or
    [ drop [ ] ] [
    name>> [ "string>" prepend words-named ] [ ">" prepend words-named ] bi append
    dup length 1 =
    [ >quotation ] [ "Can't coerce" throw ] if ] if ;

: coersion ( class -- word )
    dup union-class?
    [ members [ (coersion) ] attempt-all ]
    [ (coersion) ] if ;

:: slot* ( model slot class -- slot-model )
    model f slot-model new-arrow
    class "slots" word-prop [ name>> slot = ] find nip class>> coersion
    slot slot>setter '[ @ _ execute( obj val -- obj ) ] >>setter
    slot slot>getter '[ _ execute( a -- b ) present ] >>quot ;