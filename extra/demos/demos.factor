
USING: kernel fry sequences
       vocabs.loader tools.vocabs.browser
       ui ui.gadgets ui.gadgets.buttons ui.gadgets.packs ui.gadgets.scrollers
       ui.tools.listener
       accessors ;

IN: demos

: demo-vocabs ( -- seq ) "demos" tagged [ second ] map concat [ name>> ] map ;

: <run-vocab-button> ( vocab-name -- button )
  dup '[ drop [ , run ] call-listener ] <bevel-button> ;

: <demo-runner> ( -- gadget )
  <pile> 1 >>fill demo-vocabs [ <run-vocab-button> add-gadget ] each ;

: demos ( -- ) <demo-runner> <scroller> "Demos" open-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: demos