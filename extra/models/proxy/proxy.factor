! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel models sequences locals models.blocker
vectors ;
FROM: models.product => product? new-product ;
IN: models.proxy

TUPLE: proxy < model base dependents ;

M: proxy model-changed 2dup base>> = [
    [   [
            dependents>>
            [ model-changed ] with each
        ] with-locked-model
    ] [ t swap set-model ] bi
] [ nip t swap set-model ] if ;

:: <proxy> ( base dependencies dependents -- proxy )
    dependents [
        [ base swap remove-dependency ]
        [ base <blocker> swap add-dependency ] bi
    ] each
    dependencies base suffix proxy new-product
    dependents >>dependents base >>base ;

: proxy-deps ( model -- dependencies )
    dependencies>> [ [ blocker? ] [ product? ] bi or not ] filter ;