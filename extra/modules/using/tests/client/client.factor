USING: modules.using ;
USING*: localhost::modules.using.tests.server.service tools.test kernel sequences ;
IN: modules.using.tests.client
[ "hello world" ] [ "world" tester ] unit-test
[ "specialized" ] [ foo new tester2 ] unit-test
[ "basic" ] [ 1 tester2 ] unit-test
[ "4th element" ] [ 4 foo new nth ] unit-test