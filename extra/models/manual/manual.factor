! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel models namespaces ;
IN: models.manual

! for manually updating models where the updater is unimportant

H{ } clone "updaters" set-global

: updaters ( -- assoc ) "updaters" get-global ;

: manual-updater ( model key -- ) updaters set-at ;

: manual-update ( key -- )
    updaters at dup model-changed ;