local AbsGtk = {}

local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

function AbsGtk.new(title, w, h)
  local self = {
    window = Gtk.Window {
      title = title,
      default_width = w,
      default_height = h,
      on_destroy = Gtk.main_quit
    },
    vbox = Gtk.VBox()
  }
  local mt = {
    __index = AbsGtk,
  }
  setmetatable(self, mt)
  return self
end

function AbsGtk:add_label(label)
  self.vbox:pack_start(Gtk.Label { label = label }, true, true, 0)
end

function AbsGtk:run()
  self.window:add(self.vbox)
  self.window:show_all()
  Gtk.main()
end

return AbsGtk