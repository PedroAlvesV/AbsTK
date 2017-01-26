local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Minimalist Test")

local test_callback = function(id, value)
--   scr:set_enabled('bbox', false, 2)
end

scr:add_label('label1', 'Parameter 1:\t\t1234')
scr:add_label('label2', 'Parameter 2:\t\tABCD')
scr:add_label('label3', 'Parameter 3:\t\tWXYZ')
scr:add_button('button', "Test Button", "Button", test_callback)
--scr:create_button_box('bbox', {"ABC", "DEF", "LOREM IPSUM", "G"}, {"Button1", "Button2", "Button3", "Button4"})
--scr:add_text_input('tinput', "Text Input:", "placeholder", "Entry")
--scr:add_password('tpassword', "Password Input:", "place", "Password Entry")
--scr:add_checkbox('chkbox', "Test CheckBox", true, "CheckBox")
--scr:create_checklist('chklist', "Checklist:", {"a", "b", "c"}, nil, "Checkboxes group")
scr:add_textbox('tbox')
scr:run()