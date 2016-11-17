local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Text Input Module")

scr:add_text_input('input1', 'Username')
scr:add_text_input('input2', 'Password', true)
scr:add_text_input('input3')

scr:add_label('label', 'TextBox')
scr:add_textbox('box')

scr:run()