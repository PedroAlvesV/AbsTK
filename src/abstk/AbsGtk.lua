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

function AbsGtk:create_button_box(number_buttons, names)
  local function create_bbox(orientation, title, spacing, layout)
    return Gtk.Frame {
      label = title,
      Gtk.ButtonBox {
        orientation = orientation,
        border_width = 5,
        layout_style = layout,
        spacing = spacing,
        Gtk.Button { use_stock = true, label = Gtk.STOCK_OK },
        Gtk.Button { use_stock = true, label = Gtk.STOCK_CANCEL },
        Gtk.Button { use_stock = true, label = Gtk.STOCK_HELP }
      }
    }
  end
  self.vbox:pack_start(Gtk.Box {
    orientation = 'VERTICAL',
    border_width = 10,
    create_bbox('HORIZONTAL', "Spread", 40, 'SPREAD'),
  }, true, true, 0)
end

function AbsGtk:run()
  self.window:add(self.vbox)
  self.window:show_all()
  Gtk.main()
end

return AbsGtk