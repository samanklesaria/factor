! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USE: modules.using
USING*: remote-sequences.client localhost::remote-sequences tools.test kernel math ;
FROM: sequences => set-nth first ;
IN: remote-sequences.tests.client

[ "test" ] [ "mutate-test" <remote-seq> [ "test" 0  rot set-nth ] keep first ] unit-test

[ { 1 2 3 } ] [ { 0 1 2 } "map-test" (remote-seq) [ 1 + ] remote-map cached ] unit-test

