local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Buttons Module")

scr:add_label('Simple Buttons')
scr:add_button('Button1')
scr:add_button('Button2')

scr:add_label('ButtonBox')
scr:create_button_box({'A', 'B', 'C', 'D'}, 'SPREAD')  -- https://developer.gnome.org/gtk3/stable/;             
                                                       -- http://equipe.nce.ufrj.br/adriano/c/apostila/gtk/html/tutorial.html

scr:add_label('ComboBox (Simple)')
scr:create_combobox({'Label1', 'Label2', 'Label3'}, 'SIMPLE')

local t = {                                                      
  { name = "Parent1",
  "Leaf1", "Leaf2", "Leaf3"}, 
  { name = "Parent2",
  "Leaf4", "Leaf5", "Leaf6"},
  { name = "Parent3",
  "Leaf7", "Leaf8", "Leaf9"},
}
scr:add_label('ComboBox (Tree)')
scr:create_combobox(t, 'TREE')

scr:run()