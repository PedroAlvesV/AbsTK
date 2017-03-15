local abstk = require 'abstk'

abstk.set_mode(...)

-- Create wizard
local wizard = abstk.new_wizard("AbsTK Complete Test", 800, 600)

-- Create screens
local scr1 = abstk.new_screen("Labels Module")
local scr2 = abstk.new_screen("Buttons Module")
local scr3 = abstk.new_screen("Images Module")
local scr4 = abstk.new_screen("Lists Module")
local scr5 = abstk.new_screen("Text Input Module")

-- Test callbacks
local bt_callback = function(id, label)
   print(label.." clicado.")
end
local subbt_callback = function(id, index, label)
   print(label.." clicado.")
end
local default_callback = function(id, value)
   print(id, value)
end
local chk_callback = function(id, index, value)
   print(scr4:get_value(id, index))
end
local slct_callback = function(id, value)
   print(scr4:get_value(id))
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
scr2:create_button_box('bbox', {'A', 'B', 'C', 'D'}, nil, {subbt_callback, subbt_callback, subbt_callback, subbt_callback})
scr2:create_combobox('cbox', "ComboBox", {'Label1', 'Label2', 'Label3'}, nil, nil, default_callback)

-- Fill the third screen
scr3:add_image('lua_img', 'images/lua.png')
scr3:add_image('batman_img', 'images/batman.png', {512, 384})

-- Fill the fourth screen
scr4:add_checkbox('chkbox', "Test CheckBox", nil, nil, chk_callback)
scr4:create_checklist('chklist1', "CheckList (short, default construction)", {'a', 'b', 'c'}, nil, nil, chk_callback)
scr4:create_checklist('chklist2', "CheckList (short, constructed by passing values by default_value)", {'7', '8', '9'}, {true, false, true}, nil, chk_callback)
local checklist_values = {
   {'z', false},
   {'x', true},
   {'c', true},
}
scr4:create_checklist('chklist3', "CheckList (short, constructed by passing values in the elements table)", checklist_values, nil, nil, chk_callback)
local long_checklist = {
   { "Item1", false },
   { "Item2", true },
   { "Item3", true },
   { "Item4", false },
   { "Item5", false },
   { "Item6", false },
   { "Item7", true },
   { "Item8", false },
   { "Item9", false },
}
scr4:create_checklist('chklist4', "CheckList (long, constructed by passing booleans in the elements table)", long_checklist , nil, nil, chk_callback)
scr4:create_selector('selector1', "Selector (short, default construction)", {'x', 'y', 'z'}, nil, nil, slct_callback)
scr4:create_selector('selector2', "Selector (short, constructed by passing index by default_value)", {'a', 's', 'd'}, 3, nil, slct_callback)
local short_selector_table = {
   {'q', false},
   {'w', true},
   {'e', false},
}
scr4:create_selector('selector3', "Selector (short, constructed by passing booleans in the elements table)", short_selector_table, nil, nil, slct_callback)
scr4:create_selector('selector4', "Selector (long, default construction)", {'v1', 'v2', 'v3', 'v4', 'v5', 'v6'}, nil, nil, slct_callback)

-- Fill the fifth screen
scr5:add_text_input('input1', 'Username', nil, nil, default_callback)
scr5:add_password('input2', 'Password', nil, nil, default_callback)
scr5:add_text_input('input3', nil, nil, nil, default_callback)
local txt = ""
local n = 100
for i=1, n do
   txt = txt..i
   if i ~= n then
      txt = txt.."\n"
   end
end
scr5:add_textbox('tbox', "TextBox", txt)

-- Add all screens to wizard
wizard:add_page('screen1', scr1)
wizard:add_page('screen2', scr2)
wizard:add_page('screen3', scr3)
wizard:add_page('screen4', scr4)
wizard:add_page('screen5', scr5)

-- Run wizard and collect data
local data = wizard:run()
os.execute("clear")
print(data)