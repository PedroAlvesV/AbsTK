local abstk = require 'abstk'

abstk.set_mode(...)

local scr = abstk.new_screen("AbsTK Complete Test - Buttons Module")
scr:create_button_box(4, {'A', 'B', 'C', 'D'}) -- https://developer.gnome.org/gtk3/stable/
scr:create_button_box(3, {'X', 'Y', 'Z'})
scr:run()
