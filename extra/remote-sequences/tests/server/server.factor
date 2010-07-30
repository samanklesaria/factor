! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io.servers.connection io.sockets.secure kernel
modules.rpc-server vocabs.loader io ;
IN: remote-sequences.tests.server

: respond ( -- )
    "remote-sequences" reload
    <rpc-server>
        <secure-config>
            "vocab:modules/using/tests/key-cert.pem" >>key-file
        >>secure-config "\n^\n" write flush start-server ;

MAIN: respond
