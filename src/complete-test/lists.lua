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

scr:add_label('label2', 'CheckBoxes (constructed by passing values by default_value)')
scr:create_checklist('chklist2', {'7', '8', '9'}, {true, false, true}, nil, chk_callback)

scr:add_label('label3', 'CheckBoxes (constructed by passing values in the elements table)')
local checklist_values = {
  {'z', false},
  {'x', true},
  {'c', true},
}
scr:create_checklist('chklist3', checklist_values, nil, nil, chk_callback)

scr:add_label('label4', 'RadioButtons (default construction)')
scr:create_radiolist('rdlist1', {'x', 'y', 'z'}, nil, nil, rd_callback)

scr:add_label('label5', 'RadioButtons (constructed by passing index by default_value)')
scr:create_radiolist('rdlist2', {'a', 's', 'd'}, 3, nil, rd_callback)

scr:add_label('label6', 'RadioButtons (constructed by passing booleans in the elements table)')
local radiolist_values = {
  {'q', false},
  {'w', true},
  {'e', false},
}
scr:create_radiolist('rdlist3', radiolist_values, nil, nil, rd_callback)

scr:add_label('label7', 'CheckList (if greater than 3 and less than 10, turns into grid)')
scr:create_checklist('chklist4', {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o'}, nil, nil, chk_callback)

scr:add_label('label8', 'CheckList (if larger than 9, turns into scrolled list)')
scr:create_checklist('chklist5', {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'}, nil, nil, chk_callback)

scr:run()