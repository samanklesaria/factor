USING: accessors kernel models models.slot namespaces
tools.test ;
FROM: models => change-model ;
IN: models.slot.tests
TUPLE: foo ba ;
"tester" foo boa <model> dup "initial-tuple" set
"ba" slot dup activate-model "slot-tuple" set

[ "tester" ] [ "slot-tuple" get value>> ] unit-test
[ "newtest" ] [ "initial-tuple" get [ "newtest" >>ba ] change-model "slot-tuple" get value>> ] unit-test
[ "finaltest" ] [ "finaltest" "slot-tuple" get set-model "initial-tuple" get value>> ba>> ] unit-test