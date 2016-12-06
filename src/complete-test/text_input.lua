local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Text Input Module")

local t_input_callback = function()
  print("Input.")
end

local t_box_callback = function()
  print("Box Input.")
end

scr:add_text_input('input1', 'Username', nil, nil, nil, t_input_callback)
scr:add_text_input('input2', 'Password', true, nil, nil, t_input_callback)
scr:add_text_input('input3', nil, nil, nil, nil, t_input_callback)

scr:add_label('label', 'TextBox')
scr:add_textbox('box', nil, nil, t_box_callback)

scr:run()