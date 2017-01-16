local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Minimalist Test")
scr:add_label('label1', 'Parameter 1:\t\t1234')
scr:add_label('label2', 'Parameter 2:\t\tABCD')
scr:add_label('label3', 'Parameter 3:\t\tWXYZ')
scr:add_button('button1', 'Button 1')
scr:add_button('button2', 'Button 2')
scr:add_button('button3', 'Button 3')
scr:create_button_box('bbox', {'ABC', 'DEF', 'LOREM IPSUM', 'D'})
scr:run()