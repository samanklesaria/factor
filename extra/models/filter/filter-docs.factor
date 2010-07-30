USING: help.markup help.syntax models ;
IN: models.filter
HELP: filter-model
{ $values { "model" model } { "quot" "quotation with stack effect ( a -- ? )" } { "filter-model" filter-model } }
{ $description "Creates a model that uses the updates of another model only when they satisfy a given predicate" } ;