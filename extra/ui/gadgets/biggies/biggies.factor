USING: accessors combinators kernel locals math math.rectangles
math.vectors models namespaces sequences ui.gadgets
ui.gadgets.frames ui.gadgets.glass ui.gadgets.layout
ui.gadgets.layout-protocol ui.gadgets.worlds ui.gestures ;
FROM: ui.gadgets.layout-protocol => unparent ;
IN: ui.gadgets.biggies

TUPLE: biggie < frame placeholder big? ;

: <biggie> ( gadget -- biggie ) 1 1 biggie new-frame
    swap { 0 0 } add-gadget*
    { 0 0 } >>filled-cell f <model> >>model ;

: fill-screen ( biggie -- dim )
    [ find-world dim>> ] [ screen-loc ] bi v-
    { 150 210 } [ over > [ .99 * ] [ .85 * ] if ] 2map ;

: make-placeholder ( biggie -- )
    gadget new
        [ >>placeholder ]
        [ over layout-info <layout> swap add-before ] bi ;

:: big-gadget ( biggie -- )
    biggie fill-screen :> fill
    biggie dim>> fill v< first2 or [
        biggie {
           [ make-placeholder ]
           [ dup set-control-value ]
           [ placeholder>> ]
           [ t >>big? unparent ]
           [ fill >>pref-dim <zero-rect> show-glass ]
           [ request-focus ]
        } cleave
    ] when ;

: small-gadget ( biggie -- )
    [ [ dup focus>> dup [ nip dup ] when ] loop parents [ lose-focus swap handle-gesture drop ] each ]
    [ hide-glass ] bi ;

: handle-button-up ( gadget -- )
    dup big?>> [ drop ] [ big-gadget ] if ;

M: biggie hide-glass-hook
    [ f >>big? drop ]
    [ [ placeholder>> ] keep over layout-info <layout> over add-before unparent ]
    [ f >>placeholder drop ] tri ;

biggie H{
    { T{ child-gesture f T{ button-up } } [ hand-click# get 1 = [ handle-button-up ] [ drop ] if ] }
    { mouse-leave [ dup big?>> [ small-gadget ] [ drop ] if ] }
} set-gestures