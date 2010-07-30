! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators continuations hashtables io
io.encodings.binary io.servers.connection kernel modules.lib
namespaces sequences serialize sets vocabs vocabs.parser
io.streams.null ;
FROM: modules.lib => vocab-words instances ;
IN: modules.rpc-server

<PRIVATE
SYMBOL: serving-vocabs serving-vocabs [ V{ } clone ] initialize

: getter ( -- a ) deserialize [ dup serving-vocabs get-global index
        [   dup "cur-voc" [ [
                vocab-words [ first2 pack acc+ ] each
                "cur-voc" get instances get-global at [ pack-inst-dec acc+ ] each
            ] with-acc values [ FROM? ] partition append ] with-variable
        ] [ \ no-vocab boa remote-err boa ] if ] [ nip remote-err boa ] recover ;

: doer ( -- a ) deserialize [ dup vocabspec>> serving-vocabs get-global index
        [ [ args>> ] [ wordname>> ] [ vocabspec>> vocab-words ] tri at [ execute ] curry with-datastack ]
        [ vocabspec>> \ no-vocab boa ] if ] [ nip remote-err boa ] recover ;

PRIVATE>

SYNTAX: service current-vocab name>> serving-vocabs get-global adjoin
    "modules.syntax" { "M:" "INSTANCE:" "TUPLE:" } add-words-from ;

! meant to be configured after calling
: <rpc-server> ( -- server )
    binary <threaded-server>
    "rpcs" >>name 9012 >>secure
    [ [ deserialize {
      { "getter" [ getter ] }
      {  "doer" [ doer ] }
      { "loader" [ deserialize vocab ] } 
    } case ] with-null-writer serialize flush ] >>handler ;
