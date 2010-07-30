! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.intersection
classes.mixin classes.parser classes.predicate
classes.singleton classes.tuple classes.union continuations
definitions fry generalizations generic generic.parser inverse
io io.encodings.binary io.sockets io.sockets.secure
io.streams.null kernel locals modules.lib namespaces parser
sequences serialize vocabs vocabs.parser words words.alias
words.symbol sequences.generalizations ;
FROM: modules.lib => with-current-vocab ;
IN: modules.rpc

: send-with-check ( message -- reply/* )
    serialize flush [ deserialize ] with-null-writer
    dup remote-err? [ rethrow ] when ;

: with-secure-client ( remote encoding quot -- )
    <secure-config> "vocab:modules/using/cacert.pem" >>ca-file [
        with-client
    ] with-secure-context ; inline

GENERIC: define-remote ( str effect addrspec vocabspec class -- )

:: remote-body ( str effect addrspec vocabspec -- quot str effect )
    effect [ in>> length ] [ out>> length ] bi
    '[ _ narray vocabspec str rpc-request boa addrspec 9012 <inet> <secure> binary
    [ "doer" serialize send-with-check ] with-secure-client _ firstn ] str effect ;

M: f define-remote drop remote-body [ create-in swap ] dip define-declared ;

M: object define-remote
    [ remote-body drop parse-word bootstrap-word ] dip swap create-method-in swap define ;

M:: GEN define-remote ( str effect addrspec vocabspec class -- )
    str create-in dup reset-word class combination>> effect define-generic ;

: getter-loop ( result -- definitions )
    dup vocab-check? [ vocab>> vocab >boolean serialize flush deserialize getter-loop ] when ;

:: define-remote-predicate ( name vocab pred -- predicate-class )
    vocab [
        name create-class-in dup object
        pred (( a -- ? )) "addrspec" get "vocabspec" get remote-body 2drop
        define-predicate-class
    ] with-current-vocab ;

: >FROM< ( from -- word ) [ name>> ] [ vocab>> ] bi lookup ;

: unpack ( a -- ) dup {
        { [ TCLASS boa ] [ [ create-class dup ] [ >FROM< ] [ define-tuple-class ] tri* ] }
        { [ UCLASS boa ] [ [ create-class dup ] dip [ >FROM< ] map define-union-class ] }
        { [ ICLASS boa ] [ [ create-class dup ] dip [ >FROM< ] map define-intersection-class ] }
        { [ MCLASS boa ] [ create-class dup define-mixin-class ] }
        { [ PCLASS boa ] [ define-remote-predicate ] }
        { [ SCLASS boa ] [ create-class dup define-singleton-class ] }
        { [ SYM boa ] [ create-there dup reset-generic define-symbol word ] }
        { [ FROM boa ] [ lookup ] }
     } switch [ vocab>> ] [ name>> ] bi* 1array add-words-from ;

:: remote-vocab ( addrspec vocabspec -- vocab )
   vocabspec dup vocab
   [ nip forget addrspec vocabspec remote-vocab ] [
     dup set-current-vocab
     vocabspec addrspec 9012 <inet> <secure> binary
     [ "getter" serialize send-with-check getter-loop ] with-secure-client [ [ {
        { [ DEF boa ] [ addrspec vocabspec rot define-remote ] }
        { [ MINST boa ] [ [ >FROM< ] bi@ add-mixin-instance ] }
        { [ ] [ addrspec "addrspec" set vocabspec "vocabspec" set unpack ] }
     } switch ] each ] with-null-writer
   ] if* ;

: remote-load ( addr vocabspec -- voabspec ) [ swap
    9012 <inet> <secure> binary
    [ "loader" serialize serialize flush deserialize ] with-secure-client ] keep
    [ dictionary get-global set-at ] keep ;
