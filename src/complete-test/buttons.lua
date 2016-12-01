local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Buttons Module")

local bt_callback = function()
  print("Clicado.")
end

scr:add_label('label1', 'Simple Buttons')
scr:add_button('bt1', 'Button1', nil, nil, bt_callback)
scr:add_button('bt2', 'Button2', nil, nil, bt_callback)

scr:add_label('label2', 'ButtonBox')
scr:create_button_box('bbox', {'A', 'B', 'C', 'D'}, 'SPREAD', nil, nil, bt_callback)

scr:add_label('label3', 'ComboBox (Simple)')
scr:create_combobox('cbox1', {'Label1', 'Label2', 'Label3'}, 'SIMPLE', nil, nil, bt_callback)

local t = {                                          
  { name = "Parent1", "Leaf1", "Leaf2", "Leaf3"}, 
  { name = "Parent2", "Leaf4", "Leaf5", "Leaf6"},
  { name = "Parent3", "Leaf7", "Leaf8", "Leaf9"},
}
scr:add_label('label4', 'ComboBox (Tree)')
scr:create_combobox('cbox2', t, 'TREE', nil, nil, bt_callback)

scr:run()