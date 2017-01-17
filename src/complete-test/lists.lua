local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Lists Module")

local chk_callback = function(id, value, index)
   print(scr:get_value(id, index))
end
local rd_callback = function(id, value)
   print(scr:get_value(id))
end
local list_callback = function(id, value, index)
   print(scr:get_value(id, index))
end

scr:create_checklist('chklist1', "CheckBoxes (default construction)", {'a', 'b', 'c'}, nil, nil, chk_callback)

scr:create_checklist('chklist2', "CheckBoxes (constructed by passing values by default_value)", {'7', '8', '9'}, {true, false, true}, nil, chk_callback)
local checklist_values = {
   {'z', false},
   {'x', true},
   {'c', true},
}

scr:create_checklist('chklist3', "CheckBoxes (constructed by passing values in the elements table)", checklist_values, nil, nil, chk_callback)

scr:create_radiolist('rdlist1', "RadioButtons (default construction)", {'x', 'y', 'z'}, nil, nil, rd_callback)

scr:create_radiolist('rdlist2', "RadioButtons (constructed by passing index by default_value)", {'a', 's', 'd'}, 3, nil, rd_callback)

local radiolist_values = {
   {'q', false},
   {'w', true},
   {'e', false},
}
scr:create_radiolist('rdlist3', "RadioButtons (constructed by passing booleans in the elements table)", radiolist_values, nil, nil, rd_callback)

local list = {
   { "Item1", false },
   { "Item2", true },
   { "Item3", false },
   { "Item4", false },
   { "Item5", false },
   { "Item6", false },
   { "Item7", false },
   { "Item8", false },
   { "Item9", false },
}
scr:create_list('chklist5', "List (constructed by passing booleans in the elements table)", list , nil, list_callback)

scr:create_list('chklist6', "List (constructed by passing just the labels)", {"Item10", "Item11", "Item12"} , nil, list_callback)

scr:run()