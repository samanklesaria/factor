USING: arrays vectors combinators effects kernel math sequences splitting
strings.parser parser fry generalizations ;
IN: fries

: str-fry ( str on -- quot ) split
    [ unclip-last [ [ [ append ] [ prepend ] bi* ] reduce-r ] 2curry ]
    [ length 1 - ] bi '[ _ _ ncurry call( -- a ) ] ;
: gen-fry ( str on -- quot ) split
    [ unclip-last [ [ [ 1array ] [ append ] [ prepend ] tri* ] reduce-r ] 2curry ]
    [ length 1 - ] bi '[ _ _ ncurry call( -- a ) ] ;

SYNTAX: i" parse-string rest "_" str-fry append! ;
SYNTAX: i{ \ } parse-until >array { _ } gen-fry append! ;
SYNTAX: iV{ \ } parse-until >vector V{ _ } gen-fry append! ;
