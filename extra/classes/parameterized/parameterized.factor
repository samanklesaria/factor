! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.parser classes.union fry kernel lexer
parser sequences vocabs.parser words ;
IN: classes.parameterized

SYNTAX: UNION*:
    CREATE-WORD dup name>> "-" append
    "&" parse-tokens length swap
    parse-definition '[
        _ [ scan-word ] replicate
        dup [ name>> ] map concat _ prepend dup
        current-vocab lookup
        [ 2nip ] [ create-class-in [ swap _ append define-union-class ] keep ] if* suffix!
    ] define-syntax ;