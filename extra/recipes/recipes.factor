USING: accessors arrays colors.constants combinators db.sqlite
db.tuples db.types io.files.temp kernel math models
models.combinators models.fold models.multi monads persistency
sequences ui ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.labels ui.gadgets.layout ui.gadgets.model-buttons
ui.gadgets.model-tables ui.gadgets.scrollers ui.gadgets.tables
ui.pens.solid enter math.order locals ;
FROM: sets => prune ;
IN: recipes

STORED-TUPLE: recipe { title { VARCHAR 100 } } { votes INTEGER } { txt TEXT } { genre { VARCHAR 100 } } ;
"recipes.db" temp-file <sqlite-db> recipe define-db
: <recipe> ( -- recipe ) recipe new "" >>title "" >>genre "" >>txt 0 >>votes ;

: store-changes ( recipe title genre text -- recipe ) [ rot ] dip
    >>txt swap >>genre swap >>title ;

: top-recipes ( tuple offset -- recipes ) <query> rot >>tuple
    "votes" >>order 30 >>limit swap >>offset get-tuples ;

: top-genres ( recipes -- genres ) [ genre>> ] map prune 4 short head-slice ;

: interface ( -- cycle ) [
     [
        [ $ ACTIONS $ ] <hidden> ,
        [ $ TOOLBAR $ <spacer> $ SEARCH $ ] <hbox> COLOR: AliceBlue <solid> >>interior ,
        [ "Genres:" <label> , <spacer> $ ALL $ $ GENRES $ ] <hbox>
            { 5 0 } >>gap COLOR: gray <solid> >>interior ,
        $ RECIPES $
        $ SWITCH $
     ] <vbox> ,
     [
        [ "Title:" <label> , $ TITLE $ "Genre:" <label> , $ GENRE $ ] <hbox> ,
        $ BODY $
        $ BUTTON $
     ] <vbox> ,
  ] cycle { 350 245 } >>pref-dim ;

: position ( -- model ) TOOLBAR
    IMG-MODEL-BUTTON: back [ -30 ] >>value ->
    IMG-MODEL-BUTTON: more [ 30 ] >>value -> 
    2merge 0 [ + 0 max ] fold ;

: got-tuples ( tuples -- tuples' )
    [ top-genres [ <model-button> GENRES -> ] map merge ] bind
        [ button-text T{ recipe } swap >>genre ] fmap
    "all" <model-button> T{ recipe } >>value ALL ->
    <model-field*> SEARCH ->% 1
        [ [ f ] [ "%" dup surround <pattern> ] if-empty T{ recipe } swap >>title ] fmap
    T{ recipe } <model> 4array merge position [ top-recipes ] 2fmap ;

: votes ( -- model ) TOOLBAR
    IMG-MODEL-BUTTON: love [ 1 + ] >>value ->
    IMG-MODEL-BUTTON: hate [ 1 - ] >>value -> 2merge ;

: viewed ( submissions -- tuple-model )
    [let | ok [ "ok" <model-border-button> BUTTON -> dup SWITCH , ] |
        dup [ ok updates got-tuples [ suffix ] fold-switch ] with-self
        <quot-renderer> [ [ title>> ] [ genre>> ] bi 2array ] >>quot
            { "Title" "Genre" } >>column-titles <model-table>
            [ <scroller> RECIPES ,% 1 ] [ actions>> dup SWITCH , ] bi
        2merge {
            [ votes [ change-votes ] 2fmap ]
            [ ok updates ]
            [ [ title>> ] fmap <model-field> TITLE ->% .5 ]
            [ [ genre>> ] fmap <model-field> GENRE ->% .5 ]
            [ [ txt>> ] fmap <multiline-field> BODY ->% 1 ]
        } cleave [ store-changes ] 4fmap 2merge
    ] ;
    
: recipe-browser ( -- ) [
        interface
        TOOLBAR IMG-MODEL-BUTTON: submit -> dup SWITCH ,
            [ <recipe> dup store-tuple ] <$
        viewed [ modify-tuple ] $> ACTIONS ,
    ] with-interface "recipes" open-window ;

UI-ENTER: recipe-browser ;

! cycles should auto-skip placeholders
! the suffixes should be cleared on update