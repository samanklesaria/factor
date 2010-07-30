! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors checksums checksums.sha io.binary
io.encodings.string io.encodings.utf8 kernel random sequences ;
IN: auth
SLOT: password
SLOT: salt

: encode-password ( string salt -- bytes )
    [ utf8 encode ] [ 4 >be ] bi* append
    sha-256 checksum-bytes ;

: >>encoded-password ( user string -- user )
    32 random-bits [ encode-password ] keep
    [ >>password ] [ >>salt ] bi* ; inline

: valid-login? ( password user -- ? )
    [ salt>> encode-password ] [ password>> ] bi = ;