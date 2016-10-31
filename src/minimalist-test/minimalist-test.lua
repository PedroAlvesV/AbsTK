local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Minimalist Test")
scr:add_label('Parameter 1:\t\t1234')
scr:add_label('Parameter 2:\t\tABCD')
scr:add_label('Parameter 3:\t\tWXYZ')
scr:run()