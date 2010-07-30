USING: accessors arrays byte-arrays calendar classes
classes.tuple classes.tuple.parser combinators db db.queries
db.tuples db.types kernel math nmake parser sequences strings
strings.parser unicode.case urls words sets assocs
persistency.classes modules.rpc-server ;
IN: persistency service

TUPLE: persistent id ;
SINGLETON: IGNORED

: linked-db ( class -- database ) "database" word-prop ;

<PRIVATE

: sql>factor ( -- hash ) H{ 
    { NULL POSTPONE: f }
    { BOOLEAN DB t }
    { VARCHAR DB string }
    { TEXT DB string }
    { INTEGER DB number }
    { BIG-INTEGER DB number }
    { SIGNED-BIG-INTEGER DB number }
    { UNSIGNED-BIG-INTEGER DB number }
    { DOUBLE DB number }
    { REAL DB number }
    { DATE DB timestamp }
    { DATETIME DB timestamp }
    { TIME DB timestamp }
    { TIMESTAMP DB timestamp }
    { BLOB DB byte-array }
    { FACTOR-BLOB object }
    { +db-assigned-id+ DB number }
    { +random-id+ DB number }
    { +user-assigned-id+ DB number }
    { URL DB url }
    { IGNORED object } } ;

: add-types ( table -- table' ) [ {
        { [ dup second IGNORED? ] [ drop f ] }
        { [ dup array? ] [ [ first dup >upper ] [ second ] bi 3array ] }
        [ dup >upper FACTOR-BLOB 3array ]
    } cond ] V{ } map-as [ ] filter! ;

: remove-types ( table -- table' ) [
    dup array? [
        dup second dup array? [ first ] when
        sql>factor at
        [ swap 1 swap remove-nth 1 swap insert-nth ] when*
    ] when ] map ;

: query>tuple ( tuple/query -- tuple ) dup query? [ tuple>> ] when ;

: w/db ( query quot -- ) [ dup query>tuple class linked-db ] dip with-db ; inline

: (stored-tuple) ( class superclass slots -- class table columns )
    [ remove-types define-tuple-class ]
    [ nip [ dup name>> >upper ] [ add-types ] bi* ] 3bi ;

PRIVATE>

SYNTAX: STORED-TUPLE: parse-tuple-definition
    over persistent subclass-of?
    [ (stored-tuple) define-persistent ] [ [ drop persistent ] dip
    (stored-tuple) { "id" "ID" +db-assigned-id+ } over adjoin define-persistent
    ] if ;

: define-db ( database class -- ) swap [ [ ensure-table ] with-db ] [ "database" set-word-prop ] 2bi ;

: get-tuples ( query -- tuples ) [ select-tuples ] w/db ;

: get-tuple ( query -- tuple ) [ select-tuple ] w/db ;

: store-tuple ( tuple -- ) [ insert-tuple ] w/db ;

: modify-tuple ( tuple -- ) [ update-tuple ] w/db ;

: remove-tuples ( tuple -- ) [ delete-tuples ] w/db ;

: ensure-tuple ( tuple -- ) dup id>> [ modify-tuple ] [ store-tuple ] if ;
    
TUPLE: pattern value ; C: <pattern> pattern
SYNTAX: %" parse-string <pattern> suffix! ;
M: pattern where value>> over column-name>> 0% " LIKE " 0% bind# ;