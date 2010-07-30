! Copyright (C) 2010 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.mixin classes.tuple
classes.tuple.parser compiler.units kernel modules.lib
namespaces parser words ;
QUALIFIED: syntax
IN: modules.syntax

SYNTAX: INSTANCE:
    location [
        scan-word scan-word 2dup
        [ add-mixin-instance ] [ inst-dec boa store-instance ] 2bi
        <mixin-instance>
    ] dip remember-definition ;

SYNTAX: M: POSTPONE: syntax:M:
    word dup "method-generic" word-prop name>> store-method ;

SYNTAX: TUPLE:
    parse-tuple-definition [ define-tuple-class ] 3keep nip swap slots get set-at ;