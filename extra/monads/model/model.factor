! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: models.combinators monads models kernel ;
IN: monads.model

M: model >>= [ swap <action> ] curry ;
M: model fmap <mapped> ;
M: model $> <side-effect-model> ;
M: model <$ quot-model new-mapped-model ;