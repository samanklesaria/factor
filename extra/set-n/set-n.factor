USING: accessors assocs effects.parser fry generalizations
kernel locals math namespaces namespaces.private parser
sequences sequences.generalizations words ;
IN: set-n

: get* ( var n -- val ) namestack* dup length rot - head-slice assoc-stack ;

: set* ( val var n -- ) 1 + namestack* [ length swap - ] keep nth set-at ;

:: (lift-var) ( value var stack -- )
    stack unclip-slice :> ( rest fst )
    value fst at* nip
    [ value var rest (lift-var) ]
    [ value var fst set-at ] if ;

: lift-var ( var -- ) [ get ] keep namestack* (lift-var) ;

! dynamic lambda
SYNTAX: :| (:) dup in>> dup length
    [ swap rot '[ _ narray _ swap zip _ bind ] ] 2curry dip define-declared ;
