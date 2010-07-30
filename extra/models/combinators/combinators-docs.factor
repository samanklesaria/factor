USING: help.markup help.syntax models models.arrow sequences monads ;
IN: models.combinators

HELP: switch-models
{ $values { "model1" model } { "model2" model } { "model'" model } }
{ $description "Creates a model that starts with the behavior of model2 and switches to the behavior of model1 on its update" } ;

HELP: <mapped>
{ $values { "model" model } { "quot" "applied to model's value on updates" } { "model" model } }
{ $description "An expanded version of " { $link <arrow> } ". Use " { $link fmap } " instead." } ;

HELP: when-model
{ $values { "model" model } { "quot" "called on the model if the quot yields true" } { "cond" "a quotation called on the model's value, yielding a boolean value"  } }
{ $description "Calls quot when model updates if its value meets the condition set in cond" } ;

HELP: with-self
{ $values { "quot" "quotation that recieves its own return value" } { "model" model } }
{ $description "Fixed points for models: the quot reacts to the same model to gives" } ;