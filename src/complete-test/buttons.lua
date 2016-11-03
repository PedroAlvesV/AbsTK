local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Buttons Module")
scr:create_button_box({'A', 'B', 'C', 'D'})  -- https://developer.gnome.org/gtk3/stable/; http://equipe.nce.ufrj.br/adriano/c/apostila/gtk/html/tutorial.html
local t = {
  { name = "Parent1",
  "Leaf1", "Leaf2", "Leaf3"}, 
  { name = "Parent2",
  "Leaf4", "Leaf5", "Leaf6"},
  { name = "Parent3",
  "Leaf7", "Leaf8", "Leaf9"},
}
scr:create_combobox({'Label1', 'Label2', 'Label3'}, 'SIMPLE')
scr:create_combobox(t, 'TREE')
scr:run()