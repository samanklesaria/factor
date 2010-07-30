! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db db.tuples furnace.alloy
furnace.auth.features.deactivate-user
furnace.auth.features.edit-profile
furnace.auth.features.registration furnace.auth.login
furnace.boilerplate http.server kernel ;
IN: furnace.pages

SYMBOL: pages

: <login-config> ( responder -- responder' )
    "realm" <login-realm>
    allow-registration
    allow-edit-profile
    allow-deactivation ;

: <main-alloy> ( responder tables db -- alloy )
    [ [ ensure-tables ] with-db
    <login-config> <boilerplate> { pages "page" } >>template
    ] keep <alloy> ;