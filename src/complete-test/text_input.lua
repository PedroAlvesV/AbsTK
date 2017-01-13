local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Text Input Module")

local txt_callback = function(id, value)
   print(id, value)
end

scr:add_text_input('input1', 'Username', nil, nil, txt_callback)
scr:add_password('input2', 'Password', nil, nil, txt_callback)
scr:add_text_input('input3', nil, nil, nil, txt_callback)

scr:add_label('label', 'TextBox')
scr:add_textbox('box', nil, nil, txt_callback)

scr:run()