USING: modules.rpc-server kernel sequences io present ;
IN: modules.using.tests.server.service service

: tester ( a -- ha ) "hello " prepend ;

GENERIC: tester2 ( a -- b )

TUPLE: foo ;

M: foo tester2 drop "specialized" ;
M: object tester2 drop "basic" ;

M: foo nth drop present "th element" append ;
