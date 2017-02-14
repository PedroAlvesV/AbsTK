local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Minimalist Test")

local test_callback = function(id, value)
--   print(scr:get_value('tbox'))
end

scr:add_label('label1', 'Parameter 1:\t\t1234')
scr:add_label('label2', 'Parameter 2:\t\tABCD')
scr:add_label('label3', 'Parameter 3:\t\tWXYZ')
scr:add_button('button', "Test Button", "Button", test_callback)
--scr:create_button_box('bbox', {"ABC", "DEF", "LOREM IPSUM", "G"}, {"Button1", "Button2", "Button3", "Button4"})
scr:add_text_input('tinput', "Text Input:", "placeholder", "Entry")
scr:add_password('tpassword', "Password Input:", "place", "Password Entry")
scr:add_checkbox('chkbox', "Test CheckBox", true, "CheckBox")
local l1 = {'a', 'b', 'c'}
local l2 = {'d', 'e', 'f', '1', '2', '3', '4', '5', '6'}
local l3 = {
   {'g', false},
   {'h', true},
   {'i', false},
}
local l4 = {'x', 'y', 'z'}
--scr:create_checklist('chklist1', "Check1", l1,  nil, "Checkboxes group")
--scr:create_checklist('chklist2', "Check2", l2, {true, true, false}, "Checkboxes group")
--scr:create_checklist('chklist3', "Check3", l3, nil, "Checkboxes group")
--scr:create_checklist('chklist4', "Check4", l4, 3, "Checkboxes group")
--scr:create_selector('sl1', "Selector1", l1, nil, nil, test_callback)
--scr:create_selector('sl2', "Selector2", l2, 3, nil, test_callback)
--scr:create_selector('sl3', "Selector3", l3)
local txt = ""
local n = 100
for i=1, n do
   txt = txt..i
   if i ~= n then
      txt = txt.."\n"
   end
end
scr:add_textbox('tbox', "TextBox", txt, "TextBox")
scr:run()