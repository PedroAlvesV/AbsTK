local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Lists Module")

scr:add_label('label1', 'CheckBoxes')
scr:create_checklist('chklist1', {'a', 'b', 'c'})

scr:add_label('label2', 'RadioButtons')
scr:create_radiolist('rdlist', {'x', 'y', 'z'})

scr:add_label('label3', 'Grid')
scr:create_list('list', {'q', 'w', 'e', 'r', 't', 'y'})

scr:add_label('label4', 'CheckList (if larger than 3, turns into grid)')
scr:create_checklist('chklist2', {'1', '2', '3', '4'})

scr:run()