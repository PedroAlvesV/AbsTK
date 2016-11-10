local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Lists Module")

scr:add_label('CheckButtons')
scr:create_checklist({'a', 'b', 'c'})

scr:add_label('RadioButtons')
scr:create_radiolist({'x', 'y', 'z'})

scr:add_label('Grid')
scr:create_list({'q', 'w', 'e', 'r', 't', 'y'})

scr:add_label('CheckList (if larger than 3, turns into grid)')
scr:create_checklist({'1', '2', '3', '4'})

scr:run()