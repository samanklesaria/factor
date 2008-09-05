IN: xmode.marker
USING: kernel namespaces xmode.rules xmode.tokens
xmode.marker.state xmode.marker.context xmode.utilities
xmode.catalog sequences math assocs combinators combinators.lib
strings regexp splitting parser-combinators ascii unicode.case
combinators.short-circuit accessors ;

! Based on org.gjt.sp.jedit.syntax.TokenMarker

: current-keyword ( -- string )
    last-offset get position get line get subseq ;

: keyword-number? ( keyword -- ? )
    {
        [ current-rule-set highlight-digits?>> ]
        [ dup [ digit? ] contains? ]
        [
            dup [ digit? ] all? [
                current-rule-set digit-re>>
                dup [ dupd matches? ] [ drop f ] if
            ] unless*
        ]
    } 0&& nip ;

: mark-number ( keyword -- id )
    keyword-number? DIGIT and ;

: mark-keyword ( keyword -- id )
    current-rule-set keywords>> at ;

: add-remaining-token ( -- )
    current-rule-set default>> prev-token, ;

: mark-token ( -- )
    current-keyword
    dup mark-number [ ] [ mark-keyword ] ?if
    [ prev-token, ] when* ;

: current-char ( -- char )
    position get line get nth ;

GENERIC: match-position ( rule -- n )

M: mark-previous-rule match-position drop last-offset get ;

M: rule match-position drop position get ;

: can-match-here? ( matcher rule -- ? )
    match-position {
        [ over ]
        [ over at-line-start?>>     over zero?                implies ]
        [ over at-whitespace-end?>> over whitespace-end get = implies ]
        [ over at-word-start?>>     over last-offset get =    implies ]
    } 0&& 2nip ;

: rest-of-line ( -- str )
    line get position get tail-slice ;

GENERIC: text-matches? ( string text -- match-count/f )

M: f text-matches?
    2drop f ;

M: string-matcher text-matches?
    [
        [ string>> ] [ ignore-case?>> ] bi string-head?
    ] keep string>> length and ;

M: regexp text-matches?
    >r >string r> match-head ;

: rule-start-matches? ( rule -- match-count/f )
    dup start>> tuck swap can-match-here? [
        rest-of-line swap text>> text-matches?
    ] [
        drop f
    ] if ;

: rule-end-matches? ( rule -- match-count/f )
    dup mark-following-rule? [
        dup start>> swap can-match-here? 0 and
    ] [
        dup end>> tuck swap can-match-here? [
            rest-of-line
            swap text>> context get end>> or
            text-matches?
        ] [
            drop f
        ] if
    ] if ;

DEFER: get-rules

: get-always-rules ( vector/f ruleset -- vector/f )
    f swap rules>> at ?push-all ;

: get-char-rules ( vector/f char ruleset -- vector/f )
    >r ch>upper r> rules>> at ?push-all ;

: get-rules ( char ruleset -- seq )
    f -rot [ get-char-rules ] keep get-always-rules ;

GENERIC: handle-rule-start ( match-count rule -- )

GENERIC: handle-rule-end ( match-count rule -- )

: find-escape-rule ( -- rule )
    context get dup
    in-rule-set>> escape-rule>> [ ] [
        parent>> in-rule-set>>
        dup [ escape-rule>> ] when
    ] ?if ;

: check-escape-rule ( rule -- ? )
    no-escape?>> [ f ] [
        find-escape-rule dup [
            dup rule-start-matches? dup [
                swap handle-rule-start
                delegate-end-escaped? [ not ] change
                t
            ] [
                2drop f
            ] if
        ] when
    ] if ;

: check-every-rule ( -- ? )
    current-char current-rule-set get-rules
    [ rule-start-matches? ] map-find
    dup [ handle-rule-start t ] [ 2drop f ] if ;

: ?end-rule ( -- )
    current-rule [
        dup rule-end-matches?
        dup [ swap handle-rule-end ] [ 2drop ] if
    ] when* ;

: rule-match-token* ( rule -- id )
    dup match-token>> {
        { f [ dup body-token>> ] }
        { t [ current-rule-set default>> ] }
        [ ]
    } case nip ;

M: escape-rule handle-rule-start
    drop
    ?end-rule
    process-escape? get [
        escaped? [ not ] change
        position [ + ] change
    ] [ 2drop ] if ;

M: seq-rule handle-rule-start
    ?end-rule
    mark-token
    add-remaining-token
    tuck body-token>> next-token,
    delegate>> [ push-context ] when* ;

UNION: abstract-span-rule span-rule eol-span-rule ;

M: abstract-span-rule handle-rule-start
    ?end-rule
    mark-token
    add-remaining-token
    tuck rule-match-token* next-token,
    ! ... end subst ...
    dup context get (>>in-rule)
    delegate>> push-context ;

M: span-rule handle-rule-end
    2drop ;

M: mark-following-rule handle-rule-start
    ?end-rule
    mark-token add-remaining-token
    tuck rule-match-token* next-token,
    f context get (>>end)
    context get (>>in-rule) ;

M: mark-following-rule handle-rule-end
    nip rule-match-token* prev-token,
    f context get (>>in-rule) ;

M: mark-previous-rule handle-rule-start
    ?end-rule
    mark-token
    dup body-token>> prev-token,
    rule-match-token* next-token, ;

: do-escaped ( -- )
    escaped? get [
        escaped? off
        ! ...
    ] when ;

: check-end-delegate ( -- ? )
    context get parent>> [
        in-rule>> [
            dup rule-end-matches? dup [
                [
                    swap handle-rule-end
                    ?end-rule
                    mark-token
                    add-remaining-token
                ] keep context get parent>> in-rule>>
                rule-match-token* next-token,
                pop-context
                seen-whitespace-end? on t
            ] [ drop check-escape-rule ] if
        ] [ f ] if*
    ] [ f ] if* ;

: handle-no-word-break ( -- )
    context get parent>> [
        in-rule>> [
            dup no-word-break?>> [
                rule-match-token* prev-token,
                pop-context
            ] [ drop ] if
        ] when*
    ] when* ;

: check-rule ( -- )
    ?end-rule
    handle-no-word-break
    mark-token
    add-remaining-token ;

: (check-word-break) ( -- )
    check-rule
    
    1 current-rule-set default>> next-token, ;

: rule-set-empty? ( ruleset -- ? )
    [ rules>> ] [ keywords>> ] bi
    [ assoc-empty? ] bi@ and ;

: check-word-break ( -- ? )
    current-char dup blank? [
        drop

        seen-whitespace-end? get [
            position get 1+ whitespace-end set
        ] unless

        (check-word-break)

    ] [
        ! Micro-optimization with incorrect semantics; we keep
        ! it here because jEdit mode files depend on it now...
        current-rule-set rule-set-empty? [
            drop
        ] [
            dup alpha? [
                drop
            ] [
                current-rule-set rule-set-no-word-sep* member? [
                    (check-word-break)
                ] unless
            ] if
        ] if

        seen-whitespace-end? on
    ] if
    escaped? off
    delegate-end-escaped? off t ;


: mark-token-loop ( -- )
    position get line get length < [
        {
            [ check-end-delegate ]
            [ check-every-rule ]
            [ check-word-break ]
        } 0|| drop

        position inc
        mark-token-loop
    ] when ;

: mark-remaining ( -- )
    line get length position set
    check-rule ;

: unwind-no-line-break ( -- )
    context get parent>> [
        in-rule>> [
            no-line-break?>> [
                pop-context
                unwind-no-line-break
            ] when
        ] when*
    ] when* ;

: tokenize-line ( line-context line rules -- line-context' seq )
    [
        "MAIN" swap at -rot
        init-token-marker
        mark-token-loop
        mark-remaining
        unwind-no-line-break
        context get
    ] { } make ;