local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Images Module")

scr:add_image('imgs/lua.png')
scr:add_image('imgs/batman.png', {512, 384})

scr:run()