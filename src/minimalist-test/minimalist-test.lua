local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen('screen', "AbsTK Minimalist Test")
scr:add_label('label1', 'Parameter 1:\t\t1234')
scr:add_label('label2', 'Parameter 2:\t\tABCD')
scr:add_label('label3', 'Parameter 3:\t\tWXYZ')
scr:run()