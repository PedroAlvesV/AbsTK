local abstk = require 'abstk'

abstk.set_mode(...)

-- Create wizard
local wizard = abstk.new_wizard("AbsTK Complete Test", 400, 300)

-- Generic callbacks
local bt_callback = function()
  print("Clicado.")
end
local chk_callback = function()
  print("Checkbutton.")
end
local rd_callback = function()
  print("Radiobutton.")
end
local t_input_callback = function()
  print("Input.")
end
local t_box_callback = function()
  print("Box Input.")
end

-- Create screens
local scr1 = abstk.new_screen("Labels Module")
local scr2 = abstk.new_screen("Buttons Module")
local scr3 = abstk.new_screen("Images Module")
local scr4 = abstk.new_screen("Lists Module")
local scr5 = abstk.new_screen("Text Input Module")

-- Fill the first screen
scr1:add_label('label1', 'Parameter 1:\t\t1234')
scr1:add_label('label2', 'Parameter 2:\t\tABCD')
scr1:add_label('label3', 'Parameter 3:\t\tWXYZ')

-- Fill the second screen
scr2:add_label('label1', 'Simple Buttons')
scr2:add_button('bt1', 'Button1', nil, nil, bt_callback)
scr2:add_button('bt2', 'Button2', nil, nil, bt_callback)
scr2:add_label('label2', 'ButtonBox')
scr2:create_button_box('bbox', {'A', 'B', 'C', 'D'}, 'SPREAD', nil, nil, bt_callback)
scr2:add_label('label3', 'ComboBox')
scr2:create_combobox('cbox', {'Label1', 'Label2', 'Label3'}, nil, nil, bt_callback)

-- Fill the third screen
scr3:add_image('lua_img', 'imgs/lua.png')
scr3:add_image('batman_img', 'imgs/batman.png', {512, 384})

-- Fill the fourth screen
scr4:add_label('label1', 'CheckBoxes (default construction)')
scr4:create_checklist('chklist1', {'a', 'b', 'c'}, nil, nil, chk_callback)
scr4:add_label('label2', 'CheckBoxes (constructed by passing values)')
local checklist_values = {
  {'z', false},
  {'x', true},
  {'c', true},
}
scr4:create_checklist('chklist2', checklist_values, nil, nil, chk_callback)
scr4:add_label('label3', 'RadioButtons (default construction)')
scr4:create_radiolist('rdlist1', {'x', 'y', 'z'}, nil, nil, rd_callback)
scr4:add_label('label4', 'RadioButtons (constructed by passing values)')
local radiolist_values = {
  {'q', false},
  {'w', true},
  {'e', false},
}
scr4:create_radiolist('rdlist2', radiolist_values, nil, nil, rd_callback)
scr4:add_label('label5', 'CheckList (if greater than 3 and less than 10, turns into grid)')
scr4:create_checklist('chklist3', {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o'}, nil, nil, chk_callback)
scr4:add_label('label6', 'CheckList (if larger than 9, turns into scrolled list)')
scr4:create_checklist('chklist4', {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'}, nil, nil, chk_callback)

-- Fill the fifth screen
scr5:add_text_input('input1', 'Username', nil, nil, nil, t_input_callback)
scr5:add_text_input('input2', 'Password', true, nil, nil, t_input_callback)
scr5:add_text_input('input3', nil, nil, nil, nil, t_input_callback)
scr5:add_label('label', 'TextBox')
scr5:add_textbox('box', nil, nil, nil, nil, t_box_callback)

-- Add all screens to wizard
wizard:add_page('screen1', scr1, 'INTRO')
wizard:add_page('screen2', scr2, 'PROGRESS')
wizard:add_page('screen3', scr3, 'PROGRESS')
wizard:add_page('screen4', scr4, 'PROGRESS')
wizard:add_page('screen5', scr5, 'CONFIRM')

-- Run wizard
wizard:run()