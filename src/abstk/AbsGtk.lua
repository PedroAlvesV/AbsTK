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

function AbsGtk:add_button(label)
  self.vbox:pack_start(Gtk.Box {
    orientation = 'HORIZONTAL',
    border_width = 10,
    Gtk.Button { label = label },
  }, false, false, 0)
end

function AbsGtk:create_button_box(labels, layout)
  local function create_bbox(orientation, spacing, layout)
    local bbox = Gtk.ButtonBox {
      id = 'bbox',
      orientation = orientation,
      border_width = 5,
      layout_style = layout,
      spacing = spacing,
    }
    for _, label in ipairs(labels) do
      local button = Gtk.Button { label = label }
      bbox:add(button)
    end
    return bbox
  end
  self.vbox:pack_start(Gtk.Box {
    orientation = 'VERTICAL',
    border_width = 10,
    create_bbox('HORIZONTAL', 20, layout),
  }, false, false, 0)
end

function AbsGtk:create_combobox(labels, sort) -- sort can be "SIMPLE" or "TREE"
  local box
  if sort == 'TREE' then
    local function create_store()
      local store = Gtk.TreeStore.new { lgi.GObject.Type.STRING }
      for _, group in ipairs(labels) do
        local gi = store:append(nil, { [1] = group.name })
        for _, leaf in ipairs(group) do
          store:append(gi, { [1] = leaf })
        end
      end
      return store
    end
    box = Gtk.Box {
      orientation = 'VERTICAL',
      border_width = 10,
      Gtk.ComboBox {
        id = 'tree',
        model = create_store(),
        cells = {
          {
            Gtk.CellRendererText(),
            { text = 1 },
            align = 'start',
          }
        }
      },
    }
    else
      box = Gtk.Box {
        orientation = 'VERTICAL',
        border_width = 10,
        Gtk.ComboBoxText {
          id = 'simple',
          entry_text_column = 0,
          id_column = 1,
        },
      }
      for i=1, #labels, 1 do
        box.child.simple:append_text(labels[i])
      end
    end
  self.vbox:pack_start(Gtk.Box {
    orientation = 'VERTICAL',
    spacing = 10,
    box,
  }, false, false, 0)
end

function AbsGtk:add_image(path, width, height) -- must find a way to scale the image
  --local pbuf_src = lgi.GdkPixbuf.Pixbuf.new_from_file(path)
  --local pbuf_dest = lgi.GdkPixbuf.Pixbuf()
  --pbuf_dest = lgi.GdkPixbuf.Pixbuf.scale_simple(pbuf_src, width, height, 'INTERP_HYPER')
  --local img = Gtk.Image.new_from_pixbuf(pbuf_dest)
  local img = Gtk.Image.new_from_file(path)
  self.vbox:pack_start(img, false, false, 0)
end

function AbsGtk:add_text_input(title, is_password)
  local entry = Gtk.Entry()
  if is_password then
    Gtk.Entry.set_visibility(entry, false)
    Gtk.Entry.set_invisible_char(entry, 8)
  end
  local frame = Gtk.Frame {
    label = title,
    Gtk.Box {
      orientation = 'VERTICAL',
      border_width = 10,
      entry,
    },
  }
  self.vbox:pack_start(Gtk.Box {
    orientation = 'VERTICAL',
  --Gtk.Box {
  --  orientation = 'HORIZONTAL',
  --  spacing = 8,
  --  border_width = 10,
  --  Gtk.Label { label = title },
  --  Gtk.Entry {},
  --},
    frame,
  }, false, false, 0)
end

function AbsGtk:add_textbox(title, width, height)
  self.vbox:pack_start(Gtk.Frame {
    label = title,
    Gtk.Box {
      orientation = 'VERTICAL',
      border_width = 10,
      Gtk.ScrolledWindow {
        Gtk.TextView { expand = true }
      },
    },
  }, false, false, 0)
end

function AbsGtk:create_checklist(labels)
  local checklist = Gtk.Box {
    orientation = 'VERTICAL',
    border_width = 10,
  }
  for _, label in ipairs(labels) do
    local checkbutton = Gtk.CheckButton { label = label }
    Gtk.ToggleButton.set_active(checkbutton, false)
    checklist:add(checkbutton)
  end
  self.vbox:pack_start(checklist, true, true, 0)
end

function AbsGtk:create_radiolist(labels) -- must set radiobuttons as unactive by default
  local radiolist = Gtk.Box {
    orientation = 'VERTICAL',
    border_width = 10,
  }
  for _, label in ipairs(labels) do
    local radiobutton = Gtk.RadioButton { label = label }
    Gtk.ToggleButton.set_active(radiobutton, false)
    radiolist:add(radiobutton)
  end
  self.vbox:pack_start(radiolist, true, true, 0)
end

function AbsGtk:run()
  self.window:add(self.vbox)
  self.window:show_all()
  Gtk.main()
end

return AbsGtk