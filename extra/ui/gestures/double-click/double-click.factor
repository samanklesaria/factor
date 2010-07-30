! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces ui.gestures ;
IN: ui.gestures.double-click

SINGLETON: double-click

M: double-click equal?
    drop button-up?
    hand-click# get 2 = and ;