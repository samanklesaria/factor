USING: accessors arrays colors.constants combinators db.sqlite
db.tuples db.types io.files.temp kernel math models
models.combinators models.fold models.merge monads persistency
sequences ui ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.labels ui.gadgets.layout ui.gadgets.model-buttons
ui.gadgets.model-tables ui.gadgets.scrollers ui.gadgets.tables
ui.pens.solid math.order locals models.product.discrete
ui.gadgets.tables.renderers ;
FROM: sets => members ;
IN: recipes

STORED-TUPLE: recipe { title { VARCHAR 100 } } { votes INTEGER } { txt TEXT } { genre { VARCHAR 100 } } ;
"recipes.db" temp-file <sqlite-db> recipe define-db
: <recipe> ( -- recipe ) recipe new "" >>title "" >>genre "" >>txt 0 >>votes ;

: store-changes ( recipe title genre text -- ) [ rot ] dip
    >>txt swap >>genre swap >>title modify-tuple ;

: top-recipes ( tuple offset -- recipes ) <query> rot >>tuple
    "votes" >>order 30 >>limit swap >>offset get-tuples ;

: top-genres ( recipes -- genres ) [ genre>> ] map members 4 short head-slice ;

: interface ( -- gui ) [
     [
        [ $ ACTIONS $ ] <hidden> ,
        [ $ TOOLBAR $ <spacer> $ SEARCH $ ] <hbox> COLOR: AliceBlue <solid> >>interior ,
        [ "Genres:" <label> , <spacer> $ ALL $ $ GENRES $ ] <hbox>
            { 5 0 } >>gap COLOR: gray <solid> >>interior ,
        $ RECIPES $
     ] <vbox> ,
     $ SWITCH $
     [
        [ "Title:" <label> , $ TITLE $ "Genre:" <label> , $ GENRE $ ] <hbox> ,
        $ BODY $
        $ BUTTON $
     ] <vbox> ,
  ] cycle { 350 245 } >>pref-dim ;

: position ( -- model ) TOOLBAR
    IMG-MODEL-BUTTON: back -30 >>value ->
    IMG-MODEL-BUTTON: more 30 >>value -> 
    2merge 0 [ + 0 max ] fold ;

: got-tuples ( tuples -- tuples' )
    [ top-genres [ <model-button> GENRES -> ] map merge ] bind
        [ button-text T{ recipe } swap >>genre ] fmap
    "all" <model-button> T{ recipe } >>value ALL ->
    <model-field*> SEARCH ->% 1
        [ [ f ] [ "%" dup surround <pattern> ] if-empty T{ recipe } swap >>title ] fmap
    3array merge position [ top-recipes ] smart fmap ;

: votes ( -- model ) TOOLBAR
    IMG-MODEL-BUTTON: love [ 1 + ] >>value ->
    IMG-MODEL-BUTTON: hate [ 1 - ] >>value -> 2merge ;

: viewed ( submissions -- tuple-model )
    [let "ok" <model-border-button> BUTTON -> dup SWITCH , :> ok [
            [ T{ recipe } get-tuples ] <$ T{ recipe } get-tuples >>value
            [ got-tuples ] keep switch-models
            <quot-renderer> [ [ title>> ] [ genre>> ] bi 2array ] >>quot
                { "Title" "Genre" } >>column-titles <model-table>
                [ <scroller> RECIPES ,% 1 ] [ actions>> dup SWITCH , ] bi
            2merge {
                [ votes [ change-votes ] 2 in fmap ]
                [ ] [ [ title>> ] fmap <model-field> TITLE ->% .5 ]
                [ [ genre>> ] fmap <model-field> GENRE ->% .5 ]
                [ [ txt>> ] fmap <multiline-field> BODY ->% 1 ]
            } cleave [ store-changes ] [ ok updates ] smart-with $> 2merge
        ] with-self
    ] ;

MAIN-WINDOW: recipe-browser { { title "Recipe Browser" } } [
        interface
        TOOLBAR IMG-MODEL-BUTTON: submit -> dup SWITCH ,
        [ <recipe> dup store-tuple ] <$
        viewed ACTIONS ,
    ] with-interface 1array >>gadgets ;
