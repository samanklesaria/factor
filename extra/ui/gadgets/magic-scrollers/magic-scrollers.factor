! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math models sequences
ui.gadgets ui.gadgets.scrollers ui.gadgets.sliders ;
IN: ui.gadgets.magic-scrollers

TUPLE: magic-slider < slider ;

: <magic-slider> ( range orientation -- slider )
    magic-slider new-slider ;

: get-dim ( orientation dims -- dim )
    swap {
        { horizontal [ first ] }
        { vertical [ second ] }
    } case ;

: squish-gadget ( gadget -- ) { 0 0 } >>pref-dim drop ;

: unsquish-gadget ( gadget -- ) { 100 16 } >>pref-dim drop ;


M: magic-slider model-changed [ call-next-method ] 2keep swap value>>
    [ second ] [ fourth ] bi < [ unsquish-gadget ] [ squish-gadget ] if ;

TUPLE: magic-scroller < scroller ;
: <magic-scroller> ( gadget -- scroller ) magic-scroller new-scroller ;
M: magic-scroller (build-children) <magic-slider> ;