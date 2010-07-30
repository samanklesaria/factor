! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.short-circuit fry kernel math
math.functions sequences vectors ;
IN: sudokus.lib

: near ( a pos -- ? )
    [ [ 1 + 9 / ceiling ] bi@ ]
    [ [ 9 mod 1 + ] bi@ ] 2bi
    { [ [ = ] 2bi@ or ] [ swapd [ [ 3 / ceiling ] bi@ 2array ] 2bi@ = ] } 4 n|| ;

: nears ( -- assoc ) 81 iota dup 81 <vector>
    [ '[ over [ near ] curry filter swap _ set-nth ] curry each ] keep ;