USING: kernel sequences functors fry macros generalizations models.product
models.product.discrete ;
IN: models.combinators.templates
FUNCTOR: fmaps ( W -- )
W        IS ${W}
w-n      DEFINES ${W}-n
w-2      DEFINES 2${W}
w-3      DEFINES 3${W}
w-4      DEFINES 4${W}
w-n*      DEFINES ${W}-n*
w-2*      DEFINES 2${W}*
w-3*      DEFINES 3${W}*
w-4*      DEFINES 4${W}*
WHERE
MACRO: w-n ( int -- quot ) dup '[ [ _ narray <discrete-product> ] dip [ _ firstn ] prepend W ] ;
: w-2 ( a b quot -- mapped ) 2 w-n ; inline
: w-3 ( a b c quot -- mapped ) 3 w-n ; inline
: w-4 ( a b c d quot -- mapped ) 4 w-n ; inline
MACRO: w-n* ( int -- quot ) dup '[ [ _ narray <product> ] dip [ _ firstn ] prepend W ] ;
: w-2* ( a b quot -- mapped ) 2 w-n* ; inline
: w-3* ( a b c quot -- mapped ) 3 w-n* ; inline
: w-4* ( a b c d quot -- mapped ) 4 w-n* ; inline
;FUNCTOR