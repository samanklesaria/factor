USING: help.markup help.syntax ui.gadgets vocabs ;
IN: ui.gadgets.layout-protocol

ARTICLE: { "ui-layout-protocol" words } "Layout Protocol Words"
"Managing the gadget hierarchy:"
{ $subsections
    add-gadget
    add-gadget-at
    unparent
    add-gadgets
    clear-gadget
}
"Managing gadget layout:"
{ $subsections
    add-gadget*
    add-gadget-at*
    layout-info
    remove-info
    clear-info
} ;

HELP: clear-gadget
{ $values { "gadget" gadget } }
{ $description "Removes all children from the gadget. This will relayout the gadget." }
{ $notes "This may result in " { $link ungraft* } " being called on the children, if the gadget is visible on the screen." }
{ $side-effects "gadget" } ;

HELP: add-gadget
{ $values { "parent" gadget } { "child" gadget } }
{ $description "Adds a child gadget to a parent. If the gadget is contained in another gadget, " { $link unparent } " is called on the gadget first. The parent will be relayout." }
{ $notes "Adding a gadget to a parent may result in " { $link graft* } " being called on the children, if the parent is visible on the screen." }
{ $side-effects "parent" } ;

HELP: add-gadget-at
{ $values { "parent" gadget } { "child" gadget } { "index" "a non-negative integer" } }
{ $description "Adds a child gadget to a parent as in " { $link add-gadget } " at the specified index in its parent's display list." }
{ $notes "Adding a gadget to a parent may result in " { $link graft* } " being called on the children, if the parent is visible on the screen." }
{ $side-effects "parent" } ;

HELP: add-gadget*
{ $values { "parent" gadget } { "child" gadget } { "info" "extra info used to determine layout" } }
{ $description "Adds a child gadget to a parent as in " { $link add-gadget } " along with advice on how to lay out the child.  Given info varies for different layouts.  See " { $link "ui-layout-protocol" } }
{ $notes "Adding a gadget to a parent may result in " { $link graft* } " being called on the children, if the parent is visible on the screen." }
{ $side-effects "parent" } ;

HELP: remove-info
{ $values { "gadget" gadget } { "parent" gadget } }
{ $description "Remove layout information concerning the gadget." } ;

HELP: clear-info
{ $values { "parent" gadget } }
{ $description "Remove all layout information kept by the parent." } ;

HELP: (layout-info)
{ $values { "gadget" gadget } { "parent" gadget } { "info" "layout info used by parent" } }
{ $description "Return the layout information associated with the gadget.  Used only for making " { $link "ui-layout-protocol" } " methods. " } ;

HELP: layout-info
{ $values { "gadget" gadget } { "info" "layout info used by parent" } }
{ $description "Return the layout information associated with the gadget." } ;

HELP: add-info
{ $values { "info" "layout info used by parent" } { "parent" gadget } }
{ $description "Adds layout information to the parent." } ;

HELP: add-info-at
{ $values { "info" "layout info used by parent" } { "parent" gadget } { "index" "a non-negative integer" } }
{ $description "Adds layout information to the parent for the child at the specified index." } ;

ARTICLE: "ui-layout-protocol" "Layout Protocol"
"To uniformly add and remove gadgets from layouts, there are a number of generic words all layout gadgets should impliment:"
{ $subsection remove-info }
{ $subsection clear-info }
{ $subsection add-info }
{ $subsection (layout-info) }
{ $subsection add-info-at } ;
ABOUT: "ui-layout-protocol"