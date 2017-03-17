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

local scr = abstk.new_screen("AbsTK Minimalist Test", nil, nil, cb)

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
scr:add_textbox('tbox', "TextBox", "imagine a long text", "TextBox")
local data = scr:run()
os.execute("clear")
mm(data)