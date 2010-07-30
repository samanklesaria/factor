USING: accessors io.sockets.secure io.servers.connection io
modules.rpc-server vocabs.loader ;
IN: modules.using.tests.server

: main ( -- )
    "modules.using.tests.server.service" reload
    <rpc-server>
        <secure-config>
            "vocab:modules/using/tests/key-cert.pem" >>key-file
        >>secure-config "\n^\n" write flush start-server ;

MAIN: main