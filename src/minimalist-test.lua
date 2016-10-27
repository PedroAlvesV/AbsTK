local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

local window = Gtk.Window {
   title = 'AbsTk Minimalist Test',
   default_width = 400,
   default_height = 300,
   on_destroy = Gtk.main_quit
}

function addLabel(vbox, label)
  vbox:pack_start(Gtk.Label { label = label }, true, true, 0)
end

local vbox = Gtk.VBox()
addLabel(vbox, "Parameter 1:\t\t1234")
addLabel(vbox, "Parameter 2:\t\tABCD")
addLabel(vbox, "Parameter 3:\t\tWXYZ")
window:add(vbox)

window:show_all()
Gtk.main()
