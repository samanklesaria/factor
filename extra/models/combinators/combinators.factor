USING: accessors arrays kernel models models.multi monads
sequences ;
FROM: syntax => >> ;
IN: models.combinators

TUPLE: updater-model < multi-model values updates ;
M: updater-model model-changed [ tuck updates>> =
   [ [ values>> value>> ] keep set-model ]
   [ drop ] if ] keep f swap (>>value) ;
: updates ( values updates -- model ) [ 2array updater-model <multi-model> ] 2keep
   [ >>values ] [ >>updates ] bi* ;

TUPLE: mapped-model < multi-model model quot ;
: new-mapped-model ( model quot class -- mapped-model ) [ over 1array ] dip
   <multi-model> swap >>quot swap >>model ;
: <mapped> ( model quot -- model ) mapped-model new-mapped-model ;
M: mapped-model model-changed
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;

SYMBOL: switch
TUPLE: switch-model < model original switcher on ;
M: switch-model model-changed 2dup switcher>> =
   [ [ value>> ] dip over switch = [ nip [ original>> ] keep f >>on model-changed ] [ t >>on set-model ] if ]
   [ dup on>> [ 2drop ] [ [ value>> ] dip over [ set-model ] [ 2drop ] if ] if ] if ;
: switch-models ( model1 model2 -- model' ) swap [ 2array switch-model <multi-model> ] 2keep
   [ [ value>> >>value ] [ >>original ] bi ] [ >>switcher ] bi* ;
M: switch-model model-activated [ original>> ] keep model-changed ;

TUPLE: side-effect-model < mapped-model ;
M: side-effect-model model-changed [ value>> ] dip [ quot>> call( old -- ) ] 2keep set-model ;

TUPLE: quot-model < mapped-model ;
M: quot-model model-changed nip [ quot>> call( -- b ) ] keep set-model ;

TUPLE: action-value < multi-model parent ;
: <action-value> ( parent value -- model ) action-value new-model swap >>parent ;
M: action-value model-activated dup parent>> dup activate-model model-changed ; ! a fake dependency of sorts
M: action-value model-changed over value>> [ call-next-method ] [ 2drop ] if ;

! Will always be discrete
TUPLE: action < multi-model quot ;
M: action model-changed over value>>
    [
        [ [ value>> ] [ quot>> ] bi* call( a -- b ) ] keep value>>
        [ swap add-connection ] 2keep model-changed
    ] [ 2drop ] if ;

: <action> ( model quot -- action-model ) [ 1array action <multi-model> ] dip >>quot dup f <action-value> >>value value>> ;

! for side effects
TUPLE: (when-model) < multi-model quot cond ;
: when-model ( model quot cond -- model ) rot 1array (when-model) <multi-model> swap >>cond swap >>quot ;
M: (when-model) model-changed [ quot>> ] 2keep
    [ value>> ] [ cond>> ] bi* call( a -- ? ) [ call( model -- ) ] [ 2drop ] if ;

! only used in construction
: with-self ( quot: ( model -- model ) -- model ) f <basic> [ swap call ] keep
    [ add-dependency ] keep ; inline

M: model >>= [ swap <action> ] curry ;
M: model fmap <mapped> ;
M: model $> side-effect-model new-mapped-model ;
M: model <$ quot-model new-mapped-model ;

USE: models.combinators.templates
<< { "$>" "<$" "fmap" } [ fmaps ] each >>
! alternative to smart arrows if quot is unknown