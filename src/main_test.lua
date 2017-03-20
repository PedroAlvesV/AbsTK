local abstk = require 'abstk'
local mm = require 'mm'
abstk.set_mode(...)

local cb = function(exit, data, screen)
   if exit == "QUIT" then
      local r = screen:show_message_box("really?!?!?", 'YES_NO')
      if r == "NO" then
         return false
      end
   elseif exit == "DONE" then
      local r = screen:show_message_box("really done?!?!?", 'YES_NO')
      if r == "NO" then
         return false
      end
   end
   return true
end

local wizard = abstk.new_wizard("AbsTK Main Test", nil, nil, cb)

local scr1 = abstk.new_screen("First Screen")
local scr2 = abstk.new_screen("Second Screen")

local default_callback = function(id, value, arg1, arg2)
   value = tostring(value)
   arg1 = tostring(arg1)
   arg2 = tostring(arg2)
end

local test_callback = function(id, value)
   print(scr2:get_value('tbox'))
   scr2:set_value('tbox', "dksokds")
end

scr1:add_label('label1', 'Parameter 1:\t\t1234')
scr1:add_label('label2', 'Parameter 2:\t\tABCD')
scr1:add_label('label3', 'Parameter 3:\t\tWXYZ')
scr1:add_button('button', "Test Button", "Button", default_callback)
scr1:create_button_box('bbox', {"ABC", "DEF", "LOREM IPSUM", "G"}, {"Button1", "Button2", "Button3", "Button4"}, {default_callback, default_callback, default_callback, default_callback})
scr1:add_text_input('tinput', "Text Input:", "placeholder", "Entry", default_callback)
scr1:add_password('tpassword', "Password Input:", "place", "Password Entry", default_callback)
scr1:add_checkbox('chkbox', "Test CheckBox", true, "CheckBox", default_callback)
local l1 = {'a', 'b', 'c'}
local l2 = {'d', 'e', 'f', 'p'}
local l3 = {
   {'g', false},
   {'h', true},
   {'i', false},
}
local l4 = {'x', 'y', 'z', '1', '2', '3'}
scr2:create_checklist('chklist1', "Check1", l1,  nil, "Checkboxes group", default_callback)
scr2:create_checklist('chklist2', "Check2", l2, {true, true, false}, "Checkboxes group", default_callback)
scr2:create_checklist('chklist3', "Check3", l3, nil, "Checkboxes group", default_callback)
scr2:create_checklist('chklist4', "Check4", l4, 3, "Checkboxes group", default_callback)
scr2:create_selector('sl1', "Selector1", l1, nil, "Selector", default_callback)
scr2:create_selector('sl2', "Selector2", l2, {false, true, false, false}, "Selector", default_callback)
scr2:create_selector('sl3', "Selector3", l3, nil, "Selector", default_callback)
scr2:create_selector('sl4', "Selector4", l4, 3, "Selector", test_callback)
scr2:add_textbox('tbox', "TextBox", "1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17", "TextBox")

wizard:add_page('pg1', scr1)
wizard:add_page('pg2', scr2)

local data = wizard:run()
os.execute("clear")
mm(data)