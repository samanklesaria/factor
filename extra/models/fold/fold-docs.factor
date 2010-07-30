USING: help.markup help.syntax models sequences ;
IN: models.fold
HELP: fold
{ $values { "oldval" "starting value" } { "quot" "applied to update and previous values" } { "model" model } { "model" model } }
{ $description "Similar to " { $link reduce } " but works on models, applying a quotation to the previous and new values at each update" } ;