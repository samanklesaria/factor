USING: accessors kernel math.rectangles ui.gadgets
ui.gadgets.frames ui.gadgets.glass math sequences
ui.gadgets.layout ui.gestures namespaces
ui.gadgets.worlds math.vectors combinators arrays ;
IN: ui.gadgets.biggies

TUPLE: biggie < frame placeholder big? ;

: <biggie> ( gadget -- biggie ) 1 1 biggie new-frame
    swap { 0 0 } add-gadget*
    { 0 0 } >>filled-cell ;

: fill-screen ( biggie -- dim )
    [ find-world dim>> ] [ screen-loc ] bi v-
    { 150 210 } [ over > [ .99 * ] [ .75 * ] if ] 2map ;

: big-gadget ( biggie -- ) {
       [ placeholder>> ]
       [ fill-screen ]
       [ t >>big? unparent ]
       [ swap >>pref-dim <zero-rect> show-glass ]
       [ request-focus ]
   } cleave ; ! make the rect go up to the top of the screen

: make-placeholder ( biggie -- )
    gadget new
        [ >>placeholder ]
        [ over layout-info <layout> swap add-before ] bi ;

: small-gadget ( biggie -- ) hide-glass ;

: handle-button-up ( gadget -- )
    dup big?>> [ drop ] [ 
       [ make-placeholder ]
       [ big-gadget ] bi
    ] if ;

M: biggie hide-glass-hook
    [ f >>big? drop ]
    [ [ placeholder>> ] keep over layout-info <layout> over add-before unparent ]
    [ f >>placeholder send-lose-focus ] tri ;

biggie H{
    { T{ button-up } [ hand-click# get 1 = [ handle-button-up ] [ drop ] if ] }
    { mouse-leave [ dup big?>> [ small-gadget ] [ drop ] if ] }
} set-gestures