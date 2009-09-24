USING: accessors arrays assocs fry kernel lexer make math
math.parser models models.arrow models.combinators models.fold
models.multi models.product models.product.discrete monads
namespaces parser sequences ui.gadgets
ui.gadgets.tracks words ;
QUALIFIED: make
QUALIFIED-WITH: ui.gadgets.books book
IN: ui.gadgets.layout

DEFER: with-interface

TUPLE: layout gadget size ; C: <layout> layout

<PRIVATE

SYMBOL: templates
TUPLE: placeholder < gadget members ;
: <placeholder> ( -- placeholder ) placeholder new V{ } clone >>members ;

: (remove-members) ( placeholder members -- ) [ [ model? ] filter swap parent>> model>> [ remove-connection ] curry each ]
    [ nip [ gadget? ] filter [ unparent ] each ] 2bi ;

: remove-members ( placeholder -- ) dup members>> [ drop ] [ [ (remove-members) ] keep delete-all ] if-empty ;
: add-member ( obj placeholder -- ) over layout? [ [ gadget>> ] dip ] when members>> push ;

: insertion-quot ( quot -- quot' ) make:building get [ [ placeholder? ] find-last nip [ <placeholder> dup , ] unless*
    templates get spin '[ [ _ templates set _ , @ ] with-interface ] ] when* ;

PRIVATE>

: , ( item -- ) make:, ;

SYNTAX: ,% scan string>number [ <layout> , ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> , ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

<PRIVATE

: add-layout ( track layout -- track ) [ gadget>> ] [ size>> ] bi add-gadget* ;
: layouts ( sized? gadgets -- layouts ) [ [ gadget? ] [ layout? ] bi or ] filter swap
   [ [ dup layout? [ f <layout> ] unless ] map ]
   [ [ dup gadget? [ gadget>> ] unless ] map ] if ;
: make-layout ( building sized? -- models layouts ) [ swap layouts ] curry
   [ V{ } make [ [ model? ] filter ] ] dip bi ; inline
: <box> ( gadgets type -- track )
   [ t make-layout ] dip <track>
   swap [ add-layout ] each
   swap merge >>model ; inline

: make-book ( models gadgets model -- book ) book:<book> nip ;

ERROR: not-in-template word ;

PRIVATE>

: <hidden> ( models -- hidden )
    t make-layout <gadget> swap [ add-layout ] each
    swap <product> >>model f >>visible? ; inline

: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: <book> ( quot: ( -- model ) -- book ) f make-layout rot 0 >>value make-book ; inline
: <book*> ( quot -- book ) f make-layout f make-book ; inline

: cycle ( quot -- book )
    f make-layout [ f make-book ] 2keep append [ output-model [ [ 1 ] <$ ] [ f ] if* ] map sift
    [ '[ + dup _ length 1 - > [ drop 0 ] [ ] if ] ] keep
    merge 0 rot fold >>model ; inline

SYNTAX: $ CREATE-WORD dup
    [ [ dup templates get at [ nip , ] [ not-in-template ] if* ] curry (( -- )) define-declared "$" expect ]
    [ [ <placeholder> [ swap templates get set-at ] keep , ] curry ] bi over push-all ;

: insertion-point ( placeholder -- number parent ) dup parent>> [ children>> index ] keep ;

GENERIC# add-before 1 ( item location -- )
M: gadget add-before insertion-point -rot add-gadget-at drop ;
M: layout add-before insertion-point rot [ gadget>> ] [ size>> ] bi [ rot ] dip add-gadget-at* drop ;
M: model add-before parent>> model>> swap add-to-product ;

<PRIVATE
: insert-item ( item location -- ) [ dup get [ drop ] [ remove-members ] if ] [ on ] [ ] tri
    [ add-member ] 2keep add-before ;

: insert-items ( makelist -- ) t swap [ dup placeholder? [ nip ] [ over insert-item ] if ] each drop ;
PRIVATE>

: with-interface ( quot -- ) [ { } make ] curry H{ } clone templates rot with-variable [ insert-items ] with-scope ; inline

M: model >>= [ swap insertion-quot <action> ] curry ;
M: model fmap insertion-quot <mapped> ;
M: model $> insertion-quot side-effect-model new-mapped-model ;
M: model <$ insertion-quot quot-model new-mapped-model ;