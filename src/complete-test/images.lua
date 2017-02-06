local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Images Module")

scr:add_image('lua_img', 'images/lua.png')
scr:add_image('batman_img', 'images/batman.png', {512, 384})

scr:run()