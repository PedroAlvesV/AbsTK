local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Buttons Module")

local bt_callback = function(id, value)
   print(scr:get_value(id))
end

scr:add_label('label1', 'Simple Buttons')
scr:add_button('bt1', 'Button1', "tooltip", bt_callback)
scr:add_button('bt2', 'Button2', nil, bt_callback)

scr:add_label('label2', 'ButtonBox')
scr:create_button_box('bbox', {'A', 'B', 'C', 'D'}, nil, nil, bt_callback)

scr:add_label('label3', 'ComboBox')
scr:create_combobox('cbox', {'Label1', 'Label2', 'Label3'}, nil, nil, bt_callback)

scr:run()