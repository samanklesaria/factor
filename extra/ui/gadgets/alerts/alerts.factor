USING: accessors fonts generalizations kernel locals macros
models.combinators monads sequences ui ui.gadgets
ui.gadgets.buttons ui.gadgets.editors ui.gadgets.labels
ui.gadgets.layout ui.gadgets.model-buttons ui.gadgets.packs
wrap.strings models.filter ui.gadgets.corners models
sequences.generalizations ;
IN: ui.gadgets.alerts

:: alert ( string quot -- gadget ) <pile> { 10 10 } >>gap 1 >>align
   string 22 wrap-lines <label> T{ font { name "sans-serif" } { size 18 } } >>font { 200 100 } >>pref-dim add-gadget 
   "okay" [ quot [ close-window ] bi ] <border-button> add-gadget ;

: alert* ( str -- ) [ drop ] alert "" open-window ;

: alert-model ( str -- model ) [ t swap set-control-value ] alert
    [ children>> last f <model> >>model model>> ]
    [ "" open-window ] bi ;

:: (ask-user) ( string field -- model )
   [    string <label> T{ font { name "sans-serif" } { size 14 } } >>font dup , :> lbl
        field ->% 1 :> fldm
        "okay" <model-border-button> :> btn
         btn -> [ [ drop lbl close-window ] $> , ]
                [ fldm swap updates ] bi
   ] <vbox> { 161 86 } >>pref-dim "" open-window ;

: ask-user ( string -- model ) <model-field*> (ask-user) ;

MACRO: ask-buttons ( buttons -- quot ) dup length [
      [ swap
         [ 22 wrap-lines <label> T{ font { name "sans-serif" } { size 18 } } >>font ,% @center
         [ [ <model-border-button> [ [ dup close-window ] prepend ] change-quot -> ] map ] <hbox> ,% @bottom
         ] <frame> "" open-window
      ] dip firstn
   ] 2curry ;
