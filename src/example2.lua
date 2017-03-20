local abstk = require 'abstk'
local wizard = abstk.new_wizard("My First AbsTK Wizard")
local scr1 = abstk.new_screen("Page 1")
local scr2 = abstk.new_screen("Page 2")
local scr3 = abstk.new_screen("Page 3")
scr1:add_image('logo', 'images/abstk_logo.png')
scr1:add_label('hellow', "Hello, World!")
scr1:add_label('msg1', "This is a minimal example to demonstrate AbsTK.")
scr2:add_image('logo', 'images/abstk_logo.png')
scr2:add_label('msg2', [[The Wizard is what AbsTK was firstly developed. Instead of running Screens, it insert them into an assistant-like interface.Its routine consists on creating it (line 2), creating screens (lines 3 to 5), populating the screens (lines 6 to 12), adding screens to wizard (lines 13 to 15) and running the wizard (line 16).]])
scr3:add_image('logo', 'images/abstk_logo.png')
scr3:add_label('thanks_label', "Thank you <3")
wizard:add_page('page1', scr1)
wizard:add_page('page2', scr2)
wizard:add_page('page3', scr3)
wizard:run()