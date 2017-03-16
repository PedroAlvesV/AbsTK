local abstk = require 'abstk'

abstk.set_mode(...)

local wizard = abstk.new_wizard("AbsTK Complete Test - Wizard", 800, 600)

local scr1 = abstk.new_screen("Page 1")
local scr2 = abstk.new_screen("Page 2")

scr1:create_checklist('chklist1', "Testing Check List", {"000", "aaaa", "item", "bbbb"}, {false, true, false, true}, "Tooltip")
scr1:add_textbox('tbox', "TextBox", "lorem\nipsum\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\nlorem\nipsum\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17", "TextBox")

scr2:add_label('label', "It should show an image below me")
scr2:add_image('image', 'images/batman.png', {512, 384})
scr2:add_button('button', "Lorem Ipsum")

wizard:add_page('screen1', scr1)
wizard:add_page('screen2', scr2)

local data = wizard:run()