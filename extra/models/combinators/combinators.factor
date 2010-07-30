USING: accessors arrays fry generalizations kernel macros
models.product models models.merge models.product.unified.discrete
monads sequences stack-checker models.blocker models.product.discrete
math locals sequences.generalizations ;
FROM: syntax => >> ;
IN: models.combinators

TUPLE: updater-model < model values updates ;
M: updater-model model-changed
    nip [ values>> value>> ] keep set-model ;
   
: updates ( values updates -- model )
   over <blocker> over 2array updater-model new-product
   swap >>updates swap >>values ;

TUPLE: mapped-model < merge-model quot ;
: new-mapped-model ( model quot class -- mapped-model ) [ swap 1array ] dip
   new-product swap >>quot ;
: <mapped> ( model quot -- model ) mapped-model new-mapped-model ;

M: mapped-model model-changed
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;

SYMBOL: switch
TUPLE: switch-model < model original switcher on ;
M: switch-model model-changed 2dup switcher>> =
   [ [ value>> ] dip over switch = [ nip [ original>> ] keep f >>on model-changed ] [ t >>on set-model ] if ]
   [ dup on>> [ 2drop ] [ [ value>> ] dip over [ set-model ] [ 2drop ] if ] if ] if ;
: switch-models ( model1 model2 -- model' ) swap [ 2array switch-model new-product ] 2keep
   [ [ value>> >>value ] [ >>original ] bi ] [ >>switcher ] bi* ;
M: switch-model model-activated [ original>> ] keep model-changed ;

TUPLE: side-effect-model < mapped-model ;
M: side-effect-model model-changed [ value>> ] dip [ quot>> call( old -- ) ] 2keep set-model ;
: <side-effect-model> ( model quot -- model' ) side-effect-model new-mapped-model ;

TUPLE: quot-model < mapped-model ;
M: quot-model model-changed nip [ quot>> call( -- b ) ] keep set-model ;

TUPLE: action-value < merge-model old ;
: <action-value> ( parent value -- model )
    [ <blocker> ] [ action-value new-model ] bi*
    [ add-dependency ] keep ;

TUPLE: action < merge-model quot ;
M: action model-changed
    [ [ value>> ] [ quot>> ] bi* call( a -- b ) ] keep value>> [
        dup old>> [ remove-connection ] [ drop ] if*
    ] keep over >>old
    swap [ connections>> push ] keep activate-model ;

: <action> ( model quot -- action-model )
    [ 1array action new-product ] dip >>quot dup f <action-value> >>value value>> ;

: with-self ( ..a quot: ( ..a model -- ..b model ) -- ..b model ) f <basic> [ swap call ] keep
    [ swap prefix ] change-dependencies ; inline

MACRO: smart ( quot -- quot' )
    [ infer in>> length dup ] keep
    '[ _ narray <discrete-product> [ _ firstn @ ] ] ;

MACRO: smart* ( quot -- quot' )
    [ infer in>> length dup ] keep
    '[ _ narray <discrete-unified> [ _ firstn @ ] ] ;

MACRO: smart-with ( quot product-quot -- quot' )
    [ [ infer in>> length dup ] keep ] dip -rot
    '[ _ narray <discrete-product> @ [ _ firstn @ ] ] ;

MACRO: smart-with* ( quot product-quot -- quot' )
    [ [ infer in>> length dup ] keep ] dip -rot
    '[ _ narray <discrete-unified> @ [ _ firstn @ ] ] ;

! if the quot doesn't have a static stack effect
! or needs to be created on the fly
MACRO: in ( int -- quot ) dup
    '[ [ _ narray <discrete-product> ] dip [ _ firstn ] prepend ] ;
! ie "2 in fmap", rather than "smart fmap"

<PRIVATE
: (modulize) ( quot -- a b )
    dup infer in>> length [ '[ _ nrot ] swap compose ] keep 1 - ;
: modelize ( quot -- quot' )
    (modulize) '[ [ _ _ ncurry ] dip swap bind ] ;
: modelize* ( quot -- quot' )
    (modulize) '[ dup [ _ _ ncurry ] dip swap bind ] ;
PRIVATE>
    
MACRO: if-model ( quot1 quot2 -- quot ) [ if ] 2curry modelize ;
MACRO: if*-model ( quot1 quot2 -- quot ) '[ _ [ drop @ ] if ] modelize* ;

MACRO: unless-model ( quot -- quot ) [ unless ] curry modelize ;
MACRO: unless*-model ( quot -- quot ) '[ [ drop _ ] unless ] modelize* ;
MACRO: when-model ( quot -- quot ) [ when ] curry modelize ;
MACRO: when*-model ( quot -- quot ) [ when* ] curry modelize* ;
