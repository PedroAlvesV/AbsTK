local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Lists Module")

scr:add_label('CheckButtons')
scr:create_checklist({'a', 'b', 'c'})

scr:add_label('RadioButtons')
scr:create_radiolist({'x', 'y', 'z'})

scr:run()