! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel parser vocabs.parser words ui ;
IN: enter
! main words are usually only used for entry, doing initialization, etc
! it makes sense, then to define it all at once, rather than factoring it out into a seperate word
! and then declaring it main
: make-entry ( quot -- ) gensym
    [ swap (( -- )) define-declared ]
    [ current-vocab (>>main) ] bi ;

: wrap-ui ( quot -- quot' ) [ with-ui ] curry ;

SYNTAX: ENTER: parse-definition make-entry ;

SYNTAX: UI-ENTER: parse-definition wrap-ui make-entry ;