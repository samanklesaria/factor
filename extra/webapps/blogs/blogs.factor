! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar db db.tuples db.types
furnace.actions furnace.auth furnace.boilerplate
furnace.redirection furnace.syndication html.forms
http.server.dispatchers kernel persistency present
sequences sorting urls validators
math.intervals.generalized math math.order make math.parser
logging ;
IN: webapps.blogs

LOG: LOG-USERNAME NOTICE

TUPLE: blogs < dispatcher ;
SYMBOL: can-administer-blogs?
can-administer-blogs? define-capability
SYMBOL: can-post?
can-post? define-capability

: view-post-url ( id -- url )
    present "$blogs/post/" prepend >url ;
: view-comment-url ( parent id -- url )
    [ view-post-url ] dip >>anchor ;
: posts-by-url ( author -- url )
    "$blogs/index" >url swap "author" set-query-param ;
: posts-on-url ( month-offset -- url )
    "$blogs/index" >url swap "month" set-query-param ;

STORED-TUPLE: entity { author { VARCHAR 256 } } { date TIMESTAMP } { content TEXT } ;
GENERIC: entity-url ( entity -- url )
M: entity feed-entry-url entity-url ;
M: entity feed-entry-date date>> ;

STORED-TUPLE: post < entity { title { VARCHAR 256 } } { comments IGNORED } ;
M: post feed-entry-title
    [ author>> ] [ title>> ] bi ": " glue ;
M: post entity-url id>> view-post-url ;
: <post> ( id -- post ) \ post new swap >>id ;

STORED-TUPLE: comment < entity { parent INTEGER } ;
M: comment feed-entry-title author>> "Comment by " prepend ;
M: comment entity-url [ parent>> ] [ id>> ] bi view-comment-url ;
: <comment> ( parent id -- post ) comment new swap >>id swap >>parent ;

: post ( id -- post )
    [ <post> select-tuple ] [ f <comment> select-tuples ] bi
    >>comments ;

: validate-author ( -- )
    { { "author" [ v-username ] } } validate-params ;

: validate-index ( -- ) {
      { "month" [ "0" v-default v-number ] }
      { "author" [ [ v-username ] v-optional ] }
    } validate-params ;

: format-title ( month -- title )
    "month" value
    [ drop "Recent Posts" ] [
        drop [
            "Posts from " %
            [ month>> month-name % ", " % ]
            [ year>> number>string % ] bi
        ] "" make
    ] if-zero
    "author" value [ " by " glue ] when* ;

TUPLE: nav month title ; C: <nav> nav

: list-posts ( -- posts )
    validate-index
    "month" value
    [ 1 + "Prev" <nav> ]
    [ 1 - 0 max "Next" <nav> ] bi
    2array "months" set-value
    f <post> "author" value >>author
    "month" value months now swap time-
    [ format-title "title" set-value ] [ 1 months time- ] [ [a,b] >>date ] tri
    select-tuples [ dup id>> f <comment> count-tuples >>comments ] map
    [ date>> ] inv-sort-with ;

: <list-posts-action> ( -- action )
    <page-action>
        [ list-posts "posts" set-value ] >>init
        { blogs "list-posts" } >>template ;

: <my-posts-action> ( -- action )
    <action> [ username posts-by-url <redirect> ] >>display
        <protected> "view your posts" >>description ;

: <list-posts-feed-action> ( -- action )
    <feed-action>
        [ list-posts "posts" set-value ] >>init
        [ "title" value ] >>title
        [ "posts" value ] >>entries
        [ "author" value posts-by-url ] >>url ;

: <post-feed-action> ( -- action )
    <feed-action>
        "id" >>rest
        [ validate-integer-id "id" value post "post" set-value ] >>init
        [ "post" value feed-entry-title ] >>title
        [ "post" value entity-url ] >>url
        [ "post" value comments>> ] >>entries ;

: <view-post-action> ( -- action )
    <page-action>
        "id" >>rest [
            validate-integer-id
            "id" value post from-object
            "id" value
            "new-comment" [
                "parent" set-value
            ] nest-form
        ] >>init
        { blogs "view-post" } >>template ;

: validate-post ( -- ) {
        { "title" [ v-one-line ] }
        { "content" [ v-required ] }
    } validate-params ;

: <new-post-action> ( -- action )
    <page-action> [
            validate-post
            username "author" set-value
        ] >>validate [
            f <post>
                dup { "title" "content" } to-object
                username >>author
                now >>date
            [ insert-tuple ] [ entity-url <redirect> ] bi
        ] >>submit
        { blogs "new-post" } >>template
     <protected> "make a new blog post" >>description ;

: authorize-author ( author -- )
    username =
    { can-administer-blogs? } have-capabilities? or
    [ "edit a blog post" f login-required ] unless ;

: do-post-action ( -- )
    validate-integer-id
    "id" value <post> select-tuple from-object ;

: <edit-post-action> ( -- action )
    <page-action>
        "id" >>rest
        [ do-post-action ] >>init
        [ do-post-action validate-post ] >>validate
        [ "author" value authorize-author ] >>authorize [
            "id" value <post>
            dup { "title" "author" "date" "content" } to-object
            [ update-tuple ] [ entity-url <redirect> ] bi
        ] >>submit
        { blogs "edit-post" } >>template
    <protected> "edit a blog post" >>description ;

: delete-post ( id -- )
    [ <post> delete-tuples ] [ f <comment> delete-tuples ] bi ;

: <delete-post-action> ( -- action )
    <action>
        [ do-post-action ] >>validate
        [ "author" value authorize-author ] >>authorize [
            [ "id" value delete-post ] with-transaction
            "author" value posts-by-url <redirect>
        ] >>submit
     <protected>
        "delete a blog post" >>description ;

: <delete-author-action> ( -- action )
    <action>
        [ validate-author ] >>validate
        [ "author" value authorize-author ] >>authorize [
            [
                f <post> "author" value >>author select-tuples [ id>> delete-post ] each
                f f <comment> "author" value >>author delete-tuples
            ] with-transaction
            "author" value posts-by-url <redirect>
        ] >>submit
     <protected> "delete a blog post" >>description ;

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
            "parent" value <post> select-tuple
            author>> authorize-author
        ] >>authorize [
            f "id" value <comment> delete-tuples
            "parent" value view-post-url <redirect>
        ] >>submit
        <protected> "delete a comment" >>description ;

: <blogs> ( -- dispatcher )
    blogs new-dispatcher
        URL" $blogs/index" <redirect-responder> "" add-responder
        <list-posts-action> "index" add-responder
        <list-posts-feed-action> "posts.atom" add-responder
        <my-posts-action> "mine" add-responder
        <view-post-action> "post" add-responder
        <post-feed-action> "post.atom" add-responder
        <new-post-action> "new-post" add-responder
        <edit-post-action> "edit-post" add-responder
        <delete-post-action> "delete-post" add-responder
        <new-comment-action> "new-comment" add-responder
        <delete-comment-action> "delete-comment" add-responder
    <boilerplate>
        { blogs "blogs-common" } >>template ;
