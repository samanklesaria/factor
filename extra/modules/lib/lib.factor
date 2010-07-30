! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.intersection
classes.mixin classes.parser classes.predicate
classes.singleton classes.union combinators
combinators.short-circuit effects generic io kernel namespaces
parser sequences serialize sets vocabs.loader vocabs.parser
words words.symbol vectors ;
QUALIFIED: vocabs
FROM: classes => members ;
IN: modules.lib

SYMBOL: acc
: with-acc ( quot -- hash ) H{ } clone acc rot [ acc get ] compose with-variable ; inline
: acc+ ( object -- ) acc get conjoin ;
 
TUPLE: GEN combination ;
TUPLE: DEF name effect class ;
TUPLE: FROM name vocab ;
: <FROM> ( word -- FROM ) [ name>> ] [ vocabulary>> ] bi FROM boa ;
TUPLE: dynamic name vocab ;
TUPLE: TCLASS < dynamic superclass slots ;
TUPLE: UCLASS < dynamic members ;
TUPLE: ICLASS < dynamic members ;
TUPLE: MCLASS < dynamic ;
TUPLE: PCLASS < dynamic pred ;
TUPLE: SCLASS < dynamic ;
TUPLE: SYM < dynamic ;
TUPLE: vocab-check vocab ;
TUPLE: MINST member mixin ;
TUPLE: inst-dec member mixin ;

TUPLE: rpc-request args vocabspec wordname ;
TUPLE: remote-err a ;

SYMBOLS: methods instances slots ;
methods [ H{ } clone ] initialize
instances [ H{ } clone ] initialize
slots [ H{ } clone ] initialize

: store-method ( word name -- )
    current-vocab name>> methods get-global
    [ [ V{ } clone ] unless* [ set-at ] keep ] change-at ;

: store-instance ( MINST -- )
    current-vocab name>> instances get-global
    [ ?push ] change-at ;

: vocab-words ( vocab-spec -- words ) [ vocabs:vocab
    vocabs:vocab-words >alist [ second predicate? not ] filter ] keep methods get-global at append ;

: create-class ( str vocab -- word ) create dup save-class-location
    dup create-predicate-word dup set-word save-location ;

: create-there ( str vocab -- word ) create dup set-word dup save-location ;

: package-method ( method -- )
    "method-generic" word-prop
    dup vocabulary>>
    "cur-voc" get = [ drop ] [ <FROM> acc+ ] if ;

GENERIC: <dynamic> ( word -- dynamic )

GENERIC: pack ( name object -- defspec )

: packed ( object -- defspec ) dup acc get at
    [ dup [ name>> ] keep pack acc+ ] unless <FROM> ;

M: word pack
    [ stack-effect ]
    [ dup generic? [ "combination" word-prop GEN boa ]
    [ dup "method-class" word-prop dup [ swap package-method ] [ nip ] if ] if ] bi DEF boa ;

M: class pack nip
    dup vocabulary>> dup "cur-voc" get =
    [ drop <dynamic> ] [
        { [ find-vocab-root [ "resource:core" = ] [ "resource:basis" = ] bi or ]
        [ vocab-check boa serialize flush deserialize ] } 1||
        [ <FROM> ] [ <dynamic> ] if
    ] if ;

: pack-inst-dec ( inst-dec -- MINST )
    [ member>> ] [ mixin>> ] bi [ packed ] bi@ MINST boa ;

M: class <dynamic>
    { [ name>> ] [ vocabulary>> ] [ superclass packed ] [ slots get-global at ] } cleave TCLASS boa ;
M: union-class <dynamic> [ name>> ] [ vocabulary>> ] [ members [ packed ] map ] tri UCLASS boa ;
M: intersection-class <dynamic>
    [ name>> ] [ vocabulary>> ] [ participants>> [ packed ] map ] tri ICLASS boa ;
M: mixin-class <dynamic> [ name>> ] [ vocabulary>> ] bi MCLASS boa ;
M: symbol <dynamic> [ name>> ] [ vocabulary>> ] bi SYM boa ;
M: predicate-class <dynamic> [ name>> ] [ vocabulary>> ] [ predicate-word name>> ] tri PCLASS boa ;
M: singleton-class <dynamic> [ name>> ] [ vocabulary>> ] bi SCLASS boa ;

: with-current-vocab ( vocab quot --  )
    current-vocab [
        swap set-current-vocab call
    ] dip set-current-vocab ; inline