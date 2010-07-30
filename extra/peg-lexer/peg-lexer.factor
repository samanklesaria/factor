! Copyright (C) 2008 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators delegate delegate.protocols
kernel lexer locals math multiline namespaces parser peg
peg.ebnf.private peg.private sequences words splitting ;
IN: peg-lexer

TUPLE: lex-hash hash ;
CONSULT: assoc-protocol lex-hash hash>> ;
: <lex-hash> ( a -- lex-hash ) lex-hash boa ;

:: prepare-pos ( v i -- col line line-text line-length )
    i v head-slice :> n
    n "\n" split :> splits
    v CHAR: \n n last-index -1 or 1 + -
    splits length
    dup 1 - splits nth
    dup length ;
      
: store-pos ( v a -- )
    input swap at prepare-pos
    lexer get {
        [ line-length<< ]
        [ line-text<< ]
        [ line<< ] [ column<< ]
    } cleave ;

M: lex-hash set-at
    swap {
        { pos [ store-pos ] }
        [ swap hash>> set-at ]
    } case ;

:: at-pos ( t l c -- p ) t l head-slice [ length ] map sum l + c + ;

M: lex-hash at*
    swap {
      { pos [ drop lexer get [ text>> ] [ line>> 1 - ] [ column>> ] tri at-pos t ] }
      [ swap hash>> at* ]
    } case ;

: with-global-lexer ( quot -- result )
   [
       f lrstack set
       V{ } clone error-stack set H{ } clone \ heads set
       lexer get text>> "\n" join input set
       H{ } clone \ packrat set
   ] f make-assoc <lex-hash>
   swap bind ; inline

: parse* ( parser -- ast )
    compile
    [ execute( -- ast ) [ error-stack get first throw ] unless* ] with-global-lexer
    ast>> ; inline

: create-bnf ( name parser -- )
    reset-tokenizer [ lexer get skip-blank parse* dup ignore? [ drop ] [ suffix! ] if ] curry
    define-syntax word make-inline ;
    
SYNTAX: ON-BNF:
    CREATE-WORD reset-tokenizer ";ON-BNF" parse-multiline-string parse-ebnf
    main swap at create-bnf ;
