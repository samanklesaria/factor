USING: accessors arrays assocs fry kernel lexer make math
math.parser models models.arrow models.combinators models.fold
models.merge models.product models.product.discrete monads
namespaces parser sequences strings.parser vectors locals
ui.gadgets.tracks ui.gadgets.tabbed words ui.gadgets.packs
ui.gadgets.layout-protocol combinators.short-circuit vocabs.parser ;
QUALIFIED: make
QUALIFIED-WITH: ui.gadgets.books book
QUALIFIED-WITH: ui.gadgets.frames fr
FROM: ui.gadgets => <gadget> gadget gadget? horizontal vertical ;
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
    templates get swap rot '[ [ _ templates set _ , @ ] with-interface ] ] when* ;

PRIVATE>

: , ( item -- ) make:, ;

: handle-spec ( str -- a ) {
        [ string>number ]
        [ search [ execute( -- a ) ] [ f ] if* ]
        [ "Couldn't parse info spec" throw ]
    } 1|| ;

SYNTAX: ,% scan handle-spec [ <layout> , ] curry append! ;
SYNTAX: ->% scan handle-spec '[ [ _ <layout> , ] [ output-model ] bi ] append! ;
SYNTAX: ," parse-string [ <layout> , ] curry append! ;
SYNTAX: ->" parse-string '[ [ _ <layout> , ] [ output-model ] bi ] append! ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

<PRIVATE

: add-layout ( track layout -- track ) [ gadget>> ] [ size>> ] bi add-gadget* ;
: layouts ( gadgets -- layouts ) [ [ gadget? ] [ layout? ] bi or ] filter
   [ dup layout? [ f <layout> ] unless ] map ;
: make-layout ( quot: ( ..a -- ..b ) -- ..b models layouts ) [ layouts ]
   [ V{ } make [ [ model? ] filter ] ] dip bi ; inline
: <container> ( ..a gadgets: ( ..a -- ..b ) parent -- ..b gadget )
    [ make-layout ] dip
    swap [ add-layout ] each
    swap merge >>model ; inline
: <box> ( ..a gadgets: ( ..a -- ..b ) type -- ..b track ) <track> <container> ; inline

ERROR: not-in-template word ;

:: (cycle) ( ind children len -- index' )
    ind 1 + dup len 1 - > [ drop 0 ] when
    dup children nth placeholder?
    [ children len (cycle) ] when ; ! ind must not be a number here...

PRIVATE>

: <hidden> ( ..a gadgets: ( ..a -- ..b ) -- ..b hidden )
    <gadget> <container> f >>visible? ; inline
: <ignore> ( gadget -- ignored ) 1vector <gadget> swap >>children ;

: <hbox> ( ..a gadgets: ( ..a -- ..b ) -- ..b track ) horizontal <box> ; inline
: <hbox*> ( ..a gadgets: ( ..a -- ..b ) -- ..b track ) <shelf> <container> ; inline
: <vbox> ( ..a gadgets: ( ..a -- ..b ) -- ..b track ) vertical <box> ; inline
: <vbox*> ( ..a gadgets: ( ..a -- ..b ) -- ..b pack ) <pile> <container> ; inline

: <book*> ( ..a gadgets: ( ..a -- ..b ) -- ..b book ) f book:<empty-book> <container> ; inline
: <book> ( ..a quot: ( ..a -- ..b model ) -- ..b book ) <book*> swap 0 >>value >>model ; inline

: cycle ( quot -- book )
    <book*> dup
    [ model>> ] [ children>> [ output-model ] map sift swap suffix merge ]
    [ children>> dup length '[ drop _ _ (cycle) ] ] tri
    0 swap fold >>model ; inline

: <frame> ( ..a gadgets: ( ..a -- ..b ) -- ..b frame ) 3 3 fr:<frame> { 1 1 } >>filled-cell <container> ; inline

: <tabbed> ( ..a gadgets: ( ..a -- ..b ) -- ..b tabbed ) make-layout
    <tabbed-gadget> [ [ gadget>> ] [ size>> ] bi add-tab ] reduce
    swap merge >>model ; inline

SYNTAX: $ CREATE-WORD dup
    [ [ dup templates get at [ nip , ] [ not-in-template ] if* ] curry (( -- )) define-declared "$" expect ]
    [ [ <placeholder> [ swap templates get set-at ] keep , ] curry ] bi append! ;

: insertion-point ( placeholder -- number parent ) dup parent>> [ children>> index ] keep ;

GENERIC# add-before 1 ( item location -- )
M: gadget add-before insertion-point -rot add-gadget-at drop ;
M: layout add-before insertion-point rot [ gadget>> ] [ size>> ] bi [ rot ] dip add-gadget-at* drop ;
M: model add-before parent>> model>> swap add-dependency* ;

<PRIVATE
: insert-item ( item location -- ) [ dup get [ drop ] [ remove-members ] if ] [ on ] [ ] tri
    [ add-member ] 2keep add-before ;

: insert-items ( makelist -- ) t swap [ dup placeholder? [ nip ] [ over insert-item ] if ] each drop ;
PRIVATE>

: with-interface ( ..a quot: ( ..a -- ..b gadget ) -- ..b gadget ) [ { } make ] curry H{ } clone templates rot with-variable [ insert-items ] with-scope ; inline

M: model >>= [ swap insertion-quot <action> ] curry ;
M: model fmap insertion-quot <mapped> ;
M: model $> insertion-quot side-effect-model new-mapped-model ;
M: model <$ insertion-quot quot-model new-mapped-model ;
