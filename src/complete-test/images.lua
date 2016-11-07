local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Images Module")

scr:add_image('imgs/lua.png', 100, 100)
scr:add_image('imgs/batman.png', 256, 192)

scr:run()