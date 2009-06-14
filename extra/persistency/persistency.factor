USING: accessors arrays byte-arrays calendar classes classes.tuple
classes.tuple.parser combinators db db.tuples db.types kernel
math prettyprint sequences strings unicode.case urls words
tools.continuations ;
IN: persistency

TUPLE: persistent id ;

: add-types ( table -- table' ) [ dup array? [ first ] when dup >upper FACTOR-BLOB 3array ] map
    { "id" "ID" +db-assigned-id+ } prefix ;

SYNTAX: STORED-TUPLE: parse-tuple-definition [ drop persistent ] dip [ define-tuple-class ]
   [ nip [ dup unparse >upper ] [ add-types ] bi* define-persistent ] 3bi ;

: define-db ( database class -- ) swap [ [ ensure-table ] with-db ] [ "database" set-word-prop ] 2bi ;

: query>tuple ( tuple/query -- tuple ) dup query? [ tuple>> ] when ;
: w/db ( query quot -- ) [ dup query>tuple class "database" word-prop ] dip with-db ; inline
: get-tuples ( query -- tuples ) [ select-tuples ] w/db ;
: get-tuple ( query -- tuple ) [ select-tuple ] w/db ;
: store-tuple ( tuple -- ) [ insert-tuple ] w/db ;
: modify-tuple ( tuple -- ) [ update-tuple ] w/db ;
: remove-tuples ( tuple -- ) [ delete-tuples ] w/db ;