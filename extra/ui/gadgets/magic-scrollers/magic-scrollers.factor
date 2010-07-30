! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math models sequences
ui.gadgets ui.gadgets.scrollers ui.gadgets.sliders ;
IN: ui.gadgets.magic-scrollers

TUPLE: magic-slider < slider ;

: <magic-slider> ( range orientation -- slider )
    magic-slider new-slider t >>clipped? ;

M: magic-slider pref-dim*
    dup control-value [ second ] [ fourth ] bi <
    [ call-next-method ]
    [ drop { 0 0 } ] if ;

M: magic-slider model-changed nip [ pref-dim* ] keep (>>pref-dim) ;

TUPLE: magic-scroller < scroller ;
: <magic-scroller> ( gadget -- scroller ) magic-scroller new-scroller { 0 0 } >>gap ;

M: magic-scroller (build-children) <magic-slider> ;

! don't change the model if an axis on a different side changed
! find out what else causes a model-change for scrollers