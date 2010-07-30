USING: accessors kernel math.rectangles models sequences
ui.gadgets ui.gadgets.glass ui.gadgets.labels ui.gadgets.tables
ui.gestures ui.gadgets.tables.renderers ;
IN: ui.gadgets.comboboxes

TUPLE: combo-table < table spawner ;

M: combo-table handle-gesture [ call-next-method drop ] 2keep swap
   T{ button-up } = [
      [ spawner>> ]
      [ selected-row [ swap set-control-value ] [ 2drop ] if ]
      [ hide-glass ] tri
   ] [ drop ] if t ;

TUPLE: combobox < label-control table ;
combobox H{
   { T{ button-down } [ dup table>> over >>spawner <zero-rect> show-glass ] }
} set-gestures

: <combobox> ( options -- combobox ) [ first [ combobox new-label ] keep <model> >>model ] keep
    <model> list-renderer combo-table new-table >>table ;