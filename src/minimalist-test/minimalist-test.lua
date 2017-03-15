local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Minimalist Test")

local test_callback = function(id, value, arg1, arg2)
--   scr:set_enabled(id, false)
   value = tostring(value)
   arg1 = tostring(arg1)
   arg2 = tostring(arg2)
   scr:set_value('button', id.."|"..value.."|"..arg1.."|"..arg2)
end

scr:add_label('label1', 'Parameter 1:\t\t1234')
scr:add_label('label2', 'Parameter 2:\t\tABCD')
scr:add_label('label3', 'Parameter 3:\t\tWXYZ')
scr:add_button('button', "Test Button", "Button", test_callback)
scr:create_button_box('bbox', {"ABC", "DEF", "LOREM IPSUM", "G"}, {"Button1", "Button2", "Button3", "Button4"}, {test_callback, test_callback, test_callback, test_callback})
scr:add_text_input('tinput', "Text Input:", "placeholder", "Entry", test_callback)
scr:add_password('tpassword', "Password Input:", "place", "Password Entry", test_callback)
scr:add_checkbox('chkbox', "Test CheckBox", true, "CheckBox", test_callback)
local l1 = {'a', 'b', 'c'}
local l2 = {'d', 'e', 'f', 'p'}
local l3 = {
   {'g', false},
   {'h', true},
   {'i', false},
}
local l4 = {'x', 'y', 'z', '1', '2', '3'}
scr:create_checklist('chklist1', "Check1", l1,  nil, "Checkboxes group", test_callback)
scr:create_checklist('chklist2', "Check2", l2, {true, true, false}, "Checkboxes group", test_callback)
scr:create_checklist('chklist3', "Check3", l3, nil, "Checkboxes group", test_callback)
scr:create_checklist('chklist4', "Check4", l4, 3, "Checkboxes group", test_callback)
scr:create_selector('sl1', "Selector1", l1, nil, "Selector", test_callback)
scr:create_selector('sl2', "Selector2", l2, {false, true, false, false}, "Selector", test_callback)
scr:create_selector('sl3', "Selector3", l3, nil, "Selector", test_callback)
scr:create_selector('sl4', "Selector4", l4, 3, "Selector", test_callback)
scr:add_textbox('tbox', "TextBox", "lorem\nipsum\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\nlorem\nipsum\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17", "TextBox")
local data = scr:run()
os.execute("clear")
print(data)