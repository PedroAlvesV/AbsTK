local abstk = require 'abstk'

abstk.set_mode(...)

-- Create wizard
local wizard = abstk.new_wizard("AbsTK Complete Test", 400, 300)

-- Create screens
local scr1 = abstk.new_screen("Labels Module")
local scr2 = abstk.new_screen("Buttons Module")
local scr3 = abstk.new_screen("Images Module")
local scr4 = abstk.new_screen("Lists Module")
local scr5 = abstk.new_screen("Text Input Module")

-- Generic callbacks
local bt_callback = function(id, label)
  print(label.." clicado.")
  scr2:show_message_box('msgbox', label, 'OK')
end
local cbb_callback = function(id, value)
  print(id, value)
end
local chk_callback = function(id, value, index)
  print(scr4:get_value(id, index))
end
local rd_callback = function(id, value)
  print(scr4:get_value(id))
end
local list_callback = function(id, value, index)
  print(scr4:get_value(id, index))
end
local txt_callback = function(id, value)
  print(id, value)
end

-- Fill the first screen
scr1:add_label('label1', 'Parameter 1:\t\t1234')
scr1:add_label('label2', 'Parameter 2:\t\tABCD')
scr1:add_label('label3', 'Parameter 3:\t\tWXYZ')

-- Fill the second screen
scr2:add_label('label1', 'Simple Buttons')
scr2:add_button('bt1', 'Button1', "tooltip", bt_callback)
scr2:add_button('bt2', 'Button2', nil, bt_callback)
scr2:add_label('label2', 'ButtonBox')
scr2:create_button_box('bbox', {'A', 'B', 'C', 'D'}, nil, bt_callback)
scr2:add_label('label3', 'ComboBox')
scr2:create_combobox('cbox', {'Label1', 'Label2', 'Label3'}, nil, cbb_callback)

-- Fill the third screen
scr3:add_image('lua_img', 'imgs/lua.png')
scr3:add_image('batman_img', 'imgs/batman.png', {512, 384})

-- Fill the fourth screen
scr4:add_label('label1', 'CheckBoxes (default construction)')
scr4:create_checklist('chklist1', {'a', 'b', 'c'}, nil, nil, chk_callback)
scr4:add_label('label2', 'CheckBoxes (constructed by passing values by default_value)')
scr4:create_checklist('chklist2', {'7', '8', '9'}, {true, false, true}, nil, chk_callback)
scr4:add_label('label3', 'CheckBoxes (constructed by passing values in the elements table)')
local checklist_values = {
  {'z', false},
  {'x', true},
  {'c', true},
}
scr4:create_checklist('chklist3', checklist_values, nil, nil, chk_callback)
scr4:add_label('label4', 'RadioButtons (default construction)')
scr4:create_radiolist('rdlist1', {'x', 'y', 'z'}, nil, nil, rd_callback)
scr4:add_label('label5', 'RadioButtons (constructed by passing index by default_value)')
scr4:create_radiolist('rdlist2', {'a', 's', 'd'}, 3, nil, rd_callback)
scr4:add_label('label6', 'RadioButtons (constructed by passing booleans in the elements table)')
local radiolist_values = {
  {'q', false},
  {'w', true},
  {'e', false},
}
scr4:create_radiolist('rdlist3', radiolist_values, nil, nil, rd_callback)
scr4:add_label('label7', 'CheckList (if greater than 3, turns into grid)')
scr4:create_checklist('chklist4', {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o'}, nil, nil, chk_callback)
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
scr4:add_label('label8', 'List (constructed by passing booleans in the elements table)')
scr4:create_list('chklist5', list , nil, list_callback)
scr4:add_label('label9', 'List (constructed by passing just the labels)')
scr4:create_list('chklist6', {"Item10", "Item11", "Item12"} , nil, list_callback)

-- Fill the fifth screen
scr5:add_text_input('input1', 'Username', nil, nil, txt_callback)
scr5:add_password('input2', 'Password', nil, nil, txt_callback)
scr5:add_text_input('input3', nil, nil, nil, txt_callback)
scr5:add_label('label', 'TextBox')
scr5:add_textbox('box', nil, nil, txt_callback)

-- Add all screens to wizard
wizard:add_page('screen1', scr1, 'INTRO')
wizard:add_page('screen2', scr2)
wizard:add_page('screen3', scr3)
wizard:add_page('screen4', scr4)
wizard:add_page('screen5', scr5, 'CONFIRM')

-- Run wizard
wizard:run()