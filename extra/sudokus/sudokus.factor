! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays grouping kernel lists lists.lazy locals
math math.parser math.ranges math.order models models.combinators
models.merge models.product monads monads.list random sequences
sets sudokus.lib ui ui.gadgets.alerts ui.gadgets.editors
ui.gadgets.labels ui.gadgets.layout ui.gadgets.model-buttons
vectors io ;
FROM: syntax => >> ;
FROM: literals => $ ;
IN: sudokus

! For Debugging:
! : print-puzzle ( puzzle -- )
!     27 group [
!         9 group [ 3 group [ [ pprint " " write ] each "  " write ] each nl ] each
!     nl ] each nl flush ;

: wrapped-index ( obj seq start -- index )
    3dup swap index-from
    [ [ 3drop ] dip ] [ head-slice index ] if* ;

:: solutions ( puzzle start -- solutions )
    f puzzle start wrapped-index
    [ :> pos
      1 9 [a,b] pos $ nears nth [ puzzle nth ] map diff >list
      [ puzzle pos [ cut-slice rest-slice rot prefix append ] keep 1 + solutions ] bind
    ] [ puzzle list-monad return ] if* ;

: solution ( puzzle start -- solution )
    dupd solutions dup +nil+ = [ drop "Unsolvable" alert* ] [ nip car ] if ;

: hint ( puzzle -- puzzle' )
    f over indices
    [ "No empty spaces" alert* ]
    [ random [ swap 0 solution nth ] 2keep swap >vector [ set-nth ] keep ]
    if-empty ;

: create ( difficulty -- puzzle ) 81 [ f ] replicate 8 random 9 * 6 random + solution
    [ [ 81 random f swap rot set-nth ] curry times ] keep ;

: do-sudoku ( -- ) [ [ [
            81 [ "" ] replicate >>value [
               [ <model> ] map 9 group [ 3 group ] map 3 group
               [ [ [ <spacer> [ [ <model-field> t >>clipped? ->% 2 [ string>number ] fmap ]
                    map <spacer> ] map concat ] <hbox> , ] map concat <spacer> ] map concat <product>
            ] bind [
                "Difficulty:" <label> ,
                [ [ number>string ] fmap "1" >>value <model-field> ->
                [ string>number 1 or 8 min ] fmap
                "Generate" <model-border-button> -> updates ] with-self
                [ 3 + 11 * create ] fmap <spacer>
                "Hint" <model-border-button> -> "Solve" <model-border-button> ->
            ] <hbox> , [ rot ] dip swap [ swap updates ] curry bi@
            [ [ hint ] fmap ] [ [ 0 solution ] fmap ] bi*
            3array merge [ [ [ number>string ] [ "" ] if* ] map ] fmap
        ] with-self , ] <vbox> { 280 220 } >>pref-dim
    "Sudoku Sleuth" open-window ] with-ui ;

MAIN: do-sudoku
