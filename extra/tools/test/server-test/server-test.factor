! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.units definitions fries io io.encodings.utf8
io.launcher kernel tools.test vocabs vocabs.loader math combinators threads
io.pathnames io.directories ;
IN: tools.test.server-test

: find-it ( -- )
    readln {
        { f [ 1000 sleep find-it ] }
        { "^" [ ] }
        [ drop find-it ]
    } case ;
    
: test-server ( v1 v2 -- )
    "" resource-path [ [
        i" ./factor -run=_" utf8 <process-reader*> swap
        [ find-it ] with-input-stream
    ] [
        [ reload ] [ test ]
        [ [ vocab forget ] with-compilation-unit ] tri
        kill-process
    ] bi* ] with-directory ;