local abstk = require 'abstk'

abstk.set_mode(...)

local wizard = abstk.new_wizard("AbsTK Complete Test - Wizard", 400, 300)

local scr1 = abstk.new_screen("Page 1")
local scr2 = abstk.new_screen("Page 2")

scr1:add_label('label', "Test Label")
scr1:add_button('button', "Lorem Ipsum")

scr2:add_label('label', "It should show an image below me")
scr2:add_image('image', 'imgs/batman.png', {512, 384})

wizard:add_page('screen1', scr1, 'INTRO')
wizard:add_page('screen2', scr2, 'CONFIRM')

wizard:run()