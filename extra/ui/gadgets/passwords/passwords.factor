! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors auth documents generalizations kernel models
models.combinators monads sequences ui.gadgets
ui.gadgets.alerts ui.gadgets.editors arrays ;
IN: ui.gadgets.passwords

TUPLE: password-editor < editor typed ;

TUPLE: password-field < field ;

TUPLE: pass-doc < document document ;

M: pass-doc set-doc-range ( string from to document -- )
    [ document>> set-doc-range ]
    [ [ length [ CHAR: * ] "" replicate-as ] 3dip call-next-method ] 4 nbi ;

: <pass-doc> ( document -- pass-doc )
    { "" } pass-doc new-model V{ } clone >>locs dup clear-undo swap >>document ;

: <password-field> ( -- gadget )
    password-field password-editor new-field
    dup gadget-child <document> [ >>typed ] keep <pass-doc> >>model drop
    f <model> >>model ;
  
M: password-field graft* dup editor>> typed>> add-connection ;
 
M: password-field ungraft* dup editor>> typed>> remove-connection ;
 
M: password-field model-changed
    nip [ editor>> typed>> doc-string ] [ model>> ] bi set-model ;

: (ask-password) ( string -- model ) <password-field> (ask-user) ;
    
: ask-password ( user-model -- bool-model )
    dup [ "Password:" (ask-password) ] bind* swap [ valid-login? ] smart* fmap ;

: create-password ( user -- user' ) dup
    [ "Password:" (ask-password) ] bind* dup
    [ "Confirm Password:" (ask-password) ] bind* dupd
    [ = ] smart* fmap [ [ >>encoded-password ] smart* fmap ]
    [ drop "Passwords Don't Match" alert-model updates create-password ] if-model ;