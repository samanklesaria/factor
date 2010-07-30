! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel lexer sequences ui.gadgets.buttons
ui.images vocabs.parser ;
IN: ui.gadgets.image-buttons

: image-prep ( -- image ) scan current-vocab name>>
    "vocab:" "/icons/" surround ".tiff" surround
    <image-name> dup cached-image drop ;
PRIVATE>

SYNTAX: IMG-BUTTON: image-prep [ swap <button> ] curry over push-all ;