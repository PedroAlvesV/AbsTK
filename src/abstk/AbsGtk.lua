local AbsGtk = {}

local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

-- indexar widgets por id
-- criar wizard

function AbsGtk.new(title, w, h)
  local self = {
    window = Gtk.Window {
      title = title,
      default_width = w,
      default_height = h,
      on_destroy = Gtk.main_quit
    },
    vbox = Gtk.VBox(),
    widgets = {},
  }
  local mt = {
    __index = AbsGtk,
  }
  setmetatable(self, mt)
  return self
end

function AbsGtk:add_label(id, label, default_value, tooltip, callback)
  local widget = Gtk.Label { id = id, label = label }
  table.insert(self.widgets, widget)
end

function AbsGtk:add_button(id, label, default_value, tooltip, callback)
  local button = Gtk.Button { id = id, label = label }
  local widget = Gtk.Box {
    orientation = 'HORIZONTAL',
    border_width = 10,
    button,
  }
  table.insert(self.widgets, widget)
end

function AbsGtk:create_button_box(id, labels, layout, default_value, tooltip, callback)
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
  if layout == nil then
    layout = 'SPREAD'
  end
  local widget = Gtk.Box {
    id = id,
    orientation = 'VERTICAL',
    border_width = 10,
    create_bbox('HORIZONTAL', 20, layout),
  }
  table.insert(self.widgets, widget)
end

function AbsGtk:create_combobox(id, labels, sort, default_value, tooltip, callback) -- sort can be "SIMPLE" or "TREE"
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
  local widget = Gtk.Box {
    id = id,
    orientation = 'VERTICAL',
    spacing = 10,
    box,
  }
  table.insert(self.widgets, widget)
end

function AbsGtk:add_image(id, path, dimensions, default_value, tooltip, callback)
  local img
  if not dimensions then
    img = Gtk.Image.new_from_file(path)
  else
    local pbuf_src = lgi.GdkPixbuf.Pixbuf.new_from_file(path)
    local pbuf_dest = lgi.GdkPixbuf.Pixbuf()
    pbuf_dest = lgi.GdkPixbuf.Pixbuf.scale_simple(pbuf_src, dimensions[1], dimensions[2], 1)
    img = Gtk.Image.new_from_pixbuf(pbuf_dest)
  end
  local widget = Gtk.Box { id = id, img }
  table.insert(self.widgets, widget)
end

function AbsGtk:add_text_input(id, title, is_password, default_value, tooltip, callback)
  local entry = Gtk.Entry {hexpand = true}
  if is_password then
    Gtk.Entry.set_visibility(entry, false)
  end
  local widget
  if not title then
    widget = Gtk.Box {
      id = id,
      orientation = 'VERTICAL',
      border_width = 5,
      entry,
    }
  else
    widget = Gtk.Box {
      id = id,
      orientation = 'HORIZONTAL',
      border_width = 5,
      spacing = 10,
      Gtk.Label { label = title },
      entry,
    }
  end
  table.insert(self.widgets, widget)
end

function AbsGtk:add_textbox(id, width, height, default_value, tooltip, callback)
  local widget = Gtk.Box {
    orientation = 'VERTICAL',
    border_width = 10,
    Gtk.ScrolledWindow { Gtk.TextView {} },
  }
  table.insert(self.widgets, widget)
end

function AbsGtk:create_checklist(id, labels, default_value, tooltip, callback)
  if #labels < 4 then
    local widget = Gtk.Box {
      id = id,
      orientation = 'VERTICAL',
      border_width = 10,
    }
    for _, label in ipairs(labels) do
      local checkbutton = Gtk.CheckButton { label = label }
      Gtk.CheckButton.set_active(checkbutton, false)
      widget:add(checkbutton)
    end
    table.insert(self.widgets, widget)
  else
    self:create_list(id, labels, default_value, tooltip, callback)
  end
end

function AbsGtk:create_radiolist(id, labels, default_value, tooltip, callback)
  local widget = Gtk.Box {
    id = id,
    orientation = 'VERTICAL',
    border_width = 10,
  }
  local radiosrc
  for _, label in ipairs(labels) do
    local radiobutton
    if _ == 1 then
      radiobutton = Gtk.RadioButton.new_with_label(nil, label)
    else
      radiobutton = Gtk.RadioButton.new_with_label(Gtk.RadioButton.get_group(radiosrc), label)
    end
    Gtk.RadioButton.set_active(radiobutton, false)
    widget:add(radiobutton)
    radiosrc = radiobutton
  end
  table.insert(self.widgets, widget)
end

function AbsGtk:create_list(id, labels, default_value, tooltip, callback)
  local grid = Gtk.Grid.new()
  local x, y = 1, 1
  for _, label in ipairs(labels) do
    local checkbutton = Gtk.CheckButton { label = label }
    Gtk.CheckButton.set_active(checkbutton, false)
    Gtk.Grid.attach(grid, checkbutton, x, y, 1, 1)
    y = y + 1
    if y == 4 then
      y = 1
      x = x + 1
    end
  end
  local widget = Gtk.Frame { Gtk.Box { id = id, border_width = 10, grid } }
  table.insert(self.widgets, widget)
end

function AbsGtk:run()
  for _, widget in ipairs(self.widgets) do
    self.vbox:pack_start(widget, false, false, 0)
  end 
  self.window:add(self.vbox)
  self.window:show_all()
  Gtk.main()
end

return AbsGtk