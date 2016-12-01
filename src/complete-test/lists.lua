local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Lists Module")

local chk_callback = function()
  print("Checkbutton.")
end

local rd_callback = function()
  print("Radiobutton.")
end

scr:add_label('label1', 'CheckBoxes (default construction)')
scr:create_checklist('chklist1', {'a', 'b', 'c'}, nil, nil, chk_callback)

scr:add_label('label2', 'CheckBoxes (constructed by passing values)')
local checklist_values = {
  {'z', false},
  {'x', true},
  {'c', true},
}
scr:create_checklist('chklist2', checklist_values, nil, nil, chk_callback)

scr:add_label('label3', 'RadioButtons (default construction)')
scr:create_radiolist('rdlist', {'x', 'y', 'z'}, nil, nil, rd_callback)

scr:add_label('label4', 'RadioButtons (constructed by passing values)')
local radiolist_values = {
  {'q', false},
  {'w', true},
  {'e', false},
}
scr:create_radiolist('rdlist2', radiolist_values, nil, nil, rd_callback)

scr:add_label('label5', 'CheckList (if greater than 3 and less than 10, turns into grid)')
scr:create_checklist('chklist3', {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o'}, nil, nil, chk_callback)

scr:add_label('label6', 'CheckList (if larger than 9, turns into scrolled list)')
scr:create_checklist('chklist4', {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'}, nil, nil, chk_callback)

scr:run()