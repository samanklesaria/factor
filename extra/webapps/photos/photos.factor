! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar db db.tuples db.types fries
furnace.actions furnace.auth furnace.boilerplate
furnace.redirection grouping html.forms http.server
http.server.dispatchers io.directories io.launcher io.pathnames
kernel make math math.intervals.generalized math.order
math.parser namespaces persistency present sequences sorting
urls validators io.backend http.server.static ;
IN: webapps.photos

TUPLE: photos < dispatcher path n ;
M: photos call-responder* [ photos set ] [ call-next-method ] bi ;
SYMBOL: can-administer?
can-administer? define-capability
SYMBOL: can-upload?
can-upload? define-capability

: thumbnailize ( path -- path' )
    dup [ parent-directory ] [ [ file-stem "-thumb." append ] keep file-extension append ] bi append-path
    [ i" convert -resize 120x120 _ _" try-process ] keep ;
: next-image-path ( -- path )
    photos get [ path>> ] [ n>> number>string ".jpg" append ]
    [ [ 1 + ] change-n drop ] tri append-path normalize-path ; 
: prep-image ( mime-file -- pathname thumbnail )
    next-image-path [ [ temporary-path>> ] dip move-file ] keep dup thumbnailize ;

: view-pic-url ( id -- url )
    present "$photos/pic/" prepend >url ;
: view-comment-url ( parent id -- url )
    [ view-pic-url ] dip >>anchor ;
: pics-by-url ( author -- url ) 
    "$photos/index" >url swap "author" set-query-param ;
: pics-on-url ( month-offset -- url )
    "$photos/index" >url swap "month" set-query-param ;
: image-url ( path -- url )
    file-name "images/" prepend ;

GENERIC: entity-url ( entity -- url )
STORED-TUPLE: entity { author { VARCHAR 256 } } { date TIMESTAMP } ;
STORED-TUPLE: pic < entity { title { VARCHAR 256 } } { img { VARCHAR 15 } } { thumbnail { VARCHAR 15 } } { comments IGNORED } ;
M: pic entity-url id>> view-pic-url ;
: <pic> ( id -- pic ) \ pic new swap >>id ;
STORED-TUPLE: comment < entity { parent INTEGER } { content TEXT } ;
M: comment entity-url [ parent>> ] [ id>> ] bi view-comment-url ;
: <comment> ( parent id -- pic ) comment new swap >>id swap >>parent ;

: pic ( id -- pic )
    [ <pic> select-tuple ] [ f <comment> select-tuples ] bi >>comments ;

: validate-author ( -- ) { { "author" [ v-username ] } } validate-params ;

: validate-index ( -- ) {
      { "month" [ "0" v-default v-number ] }
      { "author" [ [ v-username ] v-optional ] }
    } validate-params ;

: format-title ( month -- title )
    "month" value
    [ drop "Recent Pictures" ] [
        drop [
            "Pictures from " %
            [ month>> month-name % ", " % ]
            [ year>> number>string % ] bi
        ] "" make
    ] if-zero
    "author" value [ " by " glue ] when* ;

TUPLE: nav month title ; C: <nav> nav

: list-pics ( -- rows )
    validate-index
    "month" value
    [ 1 + "Prev" <nav> ]
    [ 1 - 0 max "Next" <nav> ] bi
    2array "months" set-value
    f <pic> "author" value >>author
    "month" value months now swap time-
    [ format-title "title" set-value ] [ 1 months time- ] [ [a,b] >>date ] tri
    select-tuples [ dup id>> f <comment> count-tuples >>comments ] map
    [ date>> ] inv-sort-with 8 group ;

: <list-pics-action> ( -- action )
    <page-action>
        [ list-pics "rows" set-value ] >>init
        { photos "main" } >>template ;

: <my-pics-action> ( -- action )
    <action> [ username pics-by-url <redirect> ] >>display
        <protected> "view your pictures" >>description ;

: <view-pic-action> ( -- action )
    <page-action>
        "id" >>rest [
            validate-integer-id
            "id" value pic from-object
            "id" value
            "new-comment" [
                "parent" set-value
            ] nest-form
        ] >>init
        { photos "view-pic" } >>template ;

: validate-pic ( -- ) {
        { "title" [ v-one-line ] }
!        { "localimg" [ v-required ] } 
    } validate-params ;

: <new-pic-action> ( -- action )
    <page-action> [
            validate-pic
            username "author" set-value
            "localimg" param prep-image [ image-url ] bi@
            [ "img" set-value ] [ "thumbnail" set-value ] bi*
        ] >>validate [
            f <pic>
                dup { "title" "img" "thumbnail" } to-object
                username >>author
                now >>date
            [ insert-tuple ] [ entity-url <redirect> ] bi
        ] >>submit
        { photos "upload" } >>template
     <protected> "upload a picture" >>description ;

: authorize-author ( author -- )
    username =
    { can-administer? } have-capabilities? or
    [ "make a comment" f login-required ] unless ;

: do-pic-action ( -- )
    validate-integer-id
    "id" value <pic> select-tuple from-object ;

: delete-pic ( id -- )
    [ <pic> delete-tuples ] [ f <comment> delete-tuples ] bi ;

: <delete-pic-action> ( -- action )
    <action>
        [ do-pic-action ] >>validate
        [ "author" value authorize-author ] >>authorize [
            [ "id" value delete-pic ] with-transaction
            "author" value pics-by-url <redirect>
        ] >>submit
     <protected>
        "delete a picture" >>description ;

: <delete-author-action> ( -- action )
    <action>
        [ validate-author ] >>validate
        [ "author" value authorize-author ] >>authorize [
            [
                f <pic> "author" value >>author select-tuples [ id>> delete-pic ] each
                f f <comment> "author" value >>author delete-tuples
            ] with-transaction
            "author" value pics-by-url <redirect>
        ] >>submit
     <protected> "delete a picture" >>description ;

: validate-comment ( -- ) {
        { "parent" [ v-integer ] }
        { "content" [ v-required ] }
    } validate-params ;

: <new-comment-action> ( -- action )
    <action> [
            validate-comment
            username "author" set-value
        ] >>validate [
            "parent" value f <comment>
                "content" value >>content
                username >>author
                now >>date
            [ insert-tuple ] [ entity-url <redirect> ] bi
        ] >>submit
     <protected> "make a comment" >>description ;

: <delete-comment-action> ( -- action )
    <action> [
            validate-integer-id
            { { "parent" [ v-integer ] } } validate-params
        ] >>validate [
            "parent" value <pic> select-tuple
            author>> authorize-author
        ] >>authorize [
            f "id" value <comment> delete-tuples
            "parent" value view-pic-url <redirect>
        ] >>submit
        <protected> "delete a comment" >>description ;

: <photos> ( pathname -- dispatcher )
    photos new-dispatcher
        swap [ make-directories ] [ >>path ] bi 0 >>n
        URL" /index" <redirect-responder> "" add-responder
        <list-pics-action> "index" add-responder
        <my-pics-action> "mine" add-responder
        <view-pic-action> "pic" add-responder
        <new-pic-action> "upload" add-responder
        <delete-pic-action> "delete-pic" add-responder
        <new-comment-action> "new-comment" add-responder
        <delete-comment-action> "delete-comment" add-responder
        "resource:images/" <static> "images" add-responder
    <boilerplate> { photos "common" } >>template ;