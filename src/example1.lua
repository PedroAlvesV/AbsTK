local abstk = require 'abstk'
local scr = abstk.new_screen("My First AbsTK UI")
scr:add_image('logo', 'images/abstk_logo.png')
scr:add_label('hellow', "Hello, World!")
scr:add_label('msg1', "This is a minimal example to demonstrate AbsTK.")
scr:add_label('msg2', [[The Screen is the main object of the toolkit. It can run as  standalone or added to a Wizard. Its routine consists on creating it (line 2), populating it (lines 3 to 7) and running it(line 8).]])
scr:run()