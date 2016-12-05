local AbsGtk = {}

local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

-- criar callbacks para combobox
-- inicializar com default_value
-- show_message_box()

local Screen = {}
local Wizard = {}

function AbsGtk.new_screen(title, w, h)
  local self = {
    title = title,
    width = w,
    height = h,
    widgets = {},
  }
  local mt = {
    __index = Screen,
  }
  setmetatable(self, mt)
  return self
end

function AbsGtk.new_wizard(title, w, h)
  local self = {
    assistant = Gtk.Assistant {
      title = title,
      default_width = w,
      default_height = h,
      on_destroy = Gtk.main_quit,
      on_cancel = Gtk.main_quit,
      on_close = Gtk.main_quit
    },
    pages = {},
    widgets = {},
  }
  local mt = {
    __index = Wizard,
  }
  setmetatable(self, mt)
  return self
end

function Screen:add_label(id, label, tooltip, callback)
  local item = {
    id = id,
    type = 'LABEL',
    widget = Gtk.Label { label = label }
  }
  table.insert(self.widgets, item)
end

function Screen:add_button(id, label, default_value, tooltip, callback)
  local button = Gtk.Button {
    id = 'button',
    label = label,
  }
  Gtk.Widget.set_tooltip_text(button, tooltip)
  if callback then
    button.on_clicked = function(self)
      callback()
    end
  end
  local item = {
    id = id,
    type = 'BUTTON',
    widget = Gtk.Box {
      orientation = 'HORIZONTAL',
      border_width = 10,
      button,
    }
  }
  table.insert(self.widgets, item)
end

function Screen:create_button_box(id, labels, layout, default_value, tooltip, callback)
  local function create_bbox(orientation, spacing, layout)
    local bbox = Gtk.ButtonBox {
      id = 'bbox',
      orientation = orientation,
      border_width = 5,
      layout_style = layout,
      spacing = spacing,
    }
    for i, label in ipairs(labels) do
      local button = Gtk.Button { id = i, label = label }
      Gtk.Widget.set_tooltip_text(button, tooltip)
      if callback then
        button.on_clicked = function(self)
          callback()
        end
      end
      bbox:add(button)
    end
    return bbox
  end
  if layout == nil then
    layout = 'SPREAD'
  end
  local item = {
    id = id,
    type = 'BUTTON_BOX',
    widget = Gtk.Box {
      orientation = 'VERTICAL',
      border_width = 10,
      create_bbox('HORIZONTAL', 20, layout),
    }
  }
  table.insert(self.widgets, item)
end

function Screen:create_combobox(id, labels, default_value, tooltip, callback)
  local box = Gtk.Box {
    id = 'box',
    orientation = 'VERTICAL',
    border_width = 10,
    Gtk.ComboBoxText {
      id = 'combobox',
      entry_text_column = 0,
      id_column = 1,
    },
  }
  for _, label in ipairs(labels) do
    box.child.combobox:append_text(label)
  end
  local item = {
    id = id,
    type = 'COMBOBOX',
    labels = labels,
    widget = Gtk.Box {
      orientation = 'VERTICAL',
      spacing = 10,
      box,
    }
  }
  table.insert(self.widgets, item)
end

function Screen:add_image(id, path, dimensions, tooltip, callback)
  local img
  if not dimensions then
    img = Gtk.Image.new_from_file(path)
  else
    local pbuf_src = lgi.GdkPixbuf.Pixbuf.new_from_file(path)
    local pbuf_dest = lgi.GdkPixbuf.Pixbuf()
    pbuf_dest = lgi.GdkPixbuf.Pixbuf.scale_simple(pbuf_src, dimensions[1], dimensions[2], 1)
    img = Gtk.Image.new_from_pixbuf(pbuf_dest)
  end
  img.id = 'image'
  Gtk.Widget.set_tooltip_text(img, tooltip)
  local item = {
    id = id,
    type = 'IMAGE',
    path = path,
    widget = Gtk.Box { img },
  }
  table.insert(self.widgets, item)
end

function Screen:add_text_input(id, title, is_password, default_value, tooltip, callback)
  local entry = Gtk.Entry {
    id = 'entry',
    hexpand = true,
  }
  Gtk.Widget.set_tooltip_text(entry, tooltip)
  if callback then
    entry.on_changed = function(self)
      callback()
    end
  end
  Gtk.Entry.set_text(entry, default_value or "")
  if is_password then
    Gtk.Entry.set_visibility(entry, false)
  end
  local widget
  if not title then
    widget = Gtk.Box {
      orientation = 'VERTICAL',
      border_width = 5,
      entry,
    }
  else
    widget = Gtk.Box {
      orientation = 'HORIZONTAL',
      border_width = 5,
      spacing = 10,
      Gtk.Label { label = title },
      entry,
    }
  end
  local item = {
    id = id,
    type = 'TEXT_INPUT',
    widget = widget
  }
  table.insert(self.widgets, item)
end

function Screen:add_textbox(id, width, height, default_value, tooltip, callback)
  local textview = Gtk.TextView { id = 'textview' }
  local buffer = Gtk.TextBuffer.new()
  Gtk.Widget.set_tooltip_text(textview, tooltip)
  if callback then
    buffer.on_changed = function(self)
      callback()
    end
  end
  Gtk.TextView.set_buffer(textview, buffer)
  local item = {
    id = id,
    type = 'TEXTBOX',
    widget = Gtk.Box { 
      orientation = 'VERTICAL',
      border_width = 10,
      Gtk.ScrolledWindow {
        id = 'scrolled_window',
        textview,
      },
    }
  }
  table.insert(self.widgets, item)
end

function Screen:create_checklist(id, list, default_value, tooltip, callback)
  function create_grid(id, list, default_value, tooltip, callback)
    local grid = Gtk.Grid.new{ id = 'grid' }
    local x, y = 1, 1
    if type(list[1]) == "table" then
      for i, entry in ipairs(list) do
        local label, value = entry[1], entry[2]
        local checkbutton = Gtk.CheckButton { id = i, label = label }
        if callback then
          checkbutton.on_button_release_event = function(self)
            callback()
          end
        end
        Gtk.CheckButton.set_active(checkbutton, value)
        Gtk.Grid.attach(grid, checkbutton, x, y, 1, 1)
        y = y + 1
        if y == 4 then
          y = 1
          x = x + 1
        end
      end
    else
      for i, label in ipairs(list) do
        local checkbutton = Gtk.CheckButton { id = i, label = label }
        if callback then
          checkbutton.on_button_release_event = function(self)
            callback()
          end
        end
        Gtk.CheckButton.set_active(checkbutton, false)
        Gtk.Grid.attach(grid, checkbutton, x, y, 1, 1)
        y = y + 1
        if y == 4 then
          y = 1
          x = x + 1
        end
      end
    end
    local item = {
      id = id,
      type = 'GRID',
      widget = Gtk.Frame {
        Gtk.Box {
          id = 'box',
          border_width = 10,
          grid,
        }
      }
    }
    Gtk.Widget.set_tooltip_text(item.widget, tooltip)
    table.insert(self.widgets, item)
  end
  if #list < 4 then
    local item = {
      id = id,
      type = 'CHECKLIST',
      widget = Gtk.Box {
        orientation = 'VERTICAL',
        border_width = 10,
      }
    }
    Gtk.Widget.set_tooltip_text(item.widget, tooltip)
    if type(list[1]) == "table" then
      for i, entry in ipairs(list) do
        local label, value = entry[1], entry[2]
        local checkbutton = Gtk.CheckButton { id = i, label = label }
        if callback then
          checkbutton.on_button_release_event = function(self)
            callback()
          end
        end
        Gtk.CheckButton.set_active(checkbutton, value)
        item.widget:add(checkbutton)
      end
    else
      for i, label in ipairs(list) do
        local checkbutton = Gtk.CheckButton { id = i, label = label }
        if callback then
          checkbutton.on_button_release_event = function(self)
            callback()
          end
        end
        Gtk.CheckButton.set_active(checkbutton, false)
        item.widget:add(checkbutton)
      end
    end
    table.insert(self.widgets, item)
  elseif #list < 10 then
    create_grid(id, list, default_value, tooltip, callback)
  else
    self:create_list(id, list, default_value, tooltip, callback)
  end
end

function Screen:create_radiolist(id, list, default_value, tooltip, callback)
  local item = {
    id = id,
    type = 'RADIOLIST',
    widget = Gtk.Box {
      orientation = 'VERTICAL',
      border_width = 10,
    }
  }
  Gtk.Widget.set_tooltip_text(item.widget, tooltip)
  local radiosrc
  if type(list[1]) == "table" then
    local veri = true
    for _, entry in ipairs(list) do
      local label, value = entry[1], entry[2]
      local radiobutton
      if veri then
        radiobutton = Gtk.RadioButton.new_with_label(nil, label)
        veri = false
      else
        radiobutton = Gtk.RadioButton.new_with_label(Gtk.RadioButton.get_group(radiosrc), label)
      end
      if callback then
        radiobutton.on_button_release_event = function(self)
          callback()
        end
      end
      Gtk.RadioButton.set_active(radiobutton, value)
      item.widget:add(radiobutton)
      radiosrc = radiobutton
    end
  else
    for i, field in ipairs(list) do
      local radiobutton
      if i == 1 then
        radiobutton = Gtk.RadioButton.new_with_label(nil, field)
      else
        radiobutton = Gtk.RadioButton.new_with_label(Gtk.RadioButton.get_group(radiosrc), field)
      end
      if callback then
        radiobutton.on_button_release_event = function(self)
          callback()
        end
      end
      item.widget:add(radiobutton)
      radiosrc = radiobutton
    end
  end
  table.insert(self.widgets, item)
end

function Screen:create_list(id, list, default_value, tooltip, callback)
  local scrolled_window = Gtk.ScrolledWindow.new()
  local box = Gtk.Box {
    id = 'box',
    orientation = 'VERTICAL',
    border_width = 10,
  }
  for i, label in ipairs(list) do
    local checkbutton = Gtk.CheckButton { id = i, label = label }
    if callback then
      checkbutton.on_button_release_event = function(self)
        callback()
      end
    end
    box:add(checkbutton)
  end
  Gtk.ScrolledWindow.add_with_viewport(scrolled_window, box)
  Gtk.ScrolledWindow.set_min_content_height(scrolled_window, 90)
  local item = {
    id = id,
    type = 'LIST',
    widget = Gtk.Frame { scrolled_window }
  }
  Gtk.Widget.set_tooltip_text(item.widget, tooltip)
  table.insert(self.widgets, item)
end

function Screen:set_enabled(id, bool, ...)
  for _, item in ipairs(self.widgets) do
    local i = ...
    if item.id == id then
      if item.type == 'BUTTON_BOX' then
        Gtk.Widget.set_sensitive(item.widget.child.bbox.child[i], bool)
      else
        Gtk.Widget.set_sensitive(item.widget, bool)
      end
    end
  end
end

function Screen:set_value(id, value, ...)
  for _, item in ipairs(self.widgets) do
    local i, j = ...
    if item.id == id then
      if item.type == 'LABEL' then
        Gtk.Label.set_text(item.widget, value)
      elseif item.type == 'BUTTON' then
        Gtk.Button.set_label(item.widget.child.button, value)
      elseif item.type == 'BUTTON_BOX' then
        Gtk.Button.set_label(item.widget.child.bbox.child[i])
      elseif item.type == 'COMBOBOX' then
        item.labels[i] = value
        item.widget.child.combobox:remove(i-1)
        item.widget.child.combobox:insert_text(i-1, item.labels[i])
      elseif item.type == 'IMAGE' then
        item.path = value
        Gtk.Image.set_from_file(item.widget.child.image, value)
      elseif item.type == 'TEXT_INPUT' then
        Gtk.Entry.set_text(item.widget.child.entry, value)
      elseif item.type == 'TEXTBOX' then
        local buffer = Gtk.TextBuffer {}
        Gtk.TextBuffer.set_text(buffer, value, -1)
        Gtk.TextView.set_buffer(item.widget.child.scrolled_window.child.textview, buffer)
      elseif item.type == 'GRID' then
        local grid = item.widget.child.box.child[1]
        local button = Gtk.Grid.get_child_at(grid, i, j)
        Gtk.ToggleButton.set_active(button, value)
      elseif item.type == 'CHECKLIST' or item.type == 'RADIOLIST' then
        Gtk.ToggleButton.set_active(item.widget.child[i], value)
      elseif item.type == 'LIST' then
        Gtk.ToggleButton.set_active(item.widget.child.box.child[i], value)
      end
    end
  end
end

function Screen:get_value(id, ...)
  for _, item in ipairs(self.widgets) do
    local i, j = ...
    if item.id == id then
      if item.type == 'LABEL' then
        return Gtk.Label.get_text(item.widget)
      elseif item.type == 'BUTTON' then
        return Gtk.Button.get_label(item.widget.child.button)
      elseif item.type == 'BUTTON_BOX' then
        return Gtk.Button.get_label(item.widget.child.bbox.child[i])
      elseif item.type == 'COMBOBOX' then
        return item.labels[i]
      elseif item.type == 'IMAGE' then
        return item.path
      elseif item.type == 'TEXT_INPUT' then
        return Gtk.Entry.get_text(item.widget.child.entry)
      elseif item.type == 'TEXTBOX' then
        local buffer = Gtk.TextView.get_buffer(item.widget.child.scrolled_window.child.textview)
        local start_iter = Gtk.TextBuffer.get_start_iter(buffer)
        local end_iter = Gtk.TextBuffer.get_end_iter(buffer)
        return Gtk.TextBuffer.get_text(buffer, start_iter, end_iter)
      elseif item.type == 'GRID' then
        local grid = item.widget.child.box.child[1]
        local button = Gtk.Grid.get_child_at(grid, i, j)
        return Gtk.ToggleButton.get_active(button)
      elseif item.type == 'CHECKLIST' or item.type == 'RADIOLIST' then
        return Gtk.ToggleButton.get_active(item.widget.child[i])
      elseif item.type == 'LIST' then
        return Gtk.ToggleButton.get_active(item.widget.child.box.child[i])
      end
    end
  end
end

function Screen:run()
  local window = Gtk.Window {
    title = self.title,
    default_width = self.w,
    default_height = self.h,
    on_destroy = Gtk.main_quit
  }
  local vbox = Gtk.VBox()
  for _, item in ipairs(self.widgets) do
    vbox:pack_start(item.widget, false, false, 0)
  end
  window:add(vbox)
  window:show_all()
  Gtk.main()
end

function Wizard:add_page(id, screen, page_type)
  local vbox = Gtk.VBox()
  for _, item in ipairs(screen.widgets) do
    vbox:pack_start(item.widget, false, false, 0)
  end
  local page = {
    id = id,
    title = screen.title,
    complete = true,
    content = vbox,
  }
  table.insert(self.pages, page)
  Gtk.Assistant.insert_page(self.assistant, page.content, -1)
  Gtk.Assistant.set_page_title(self.assistant, page.content, screen.title)
  Gtk.Assistant.set_page_complete(self.assistant, page.content, true)
  if page_type == 'INTRO' or page_type == 'CONTENT' or page_type == 'CONFIRM'
  or page_type == 'SUMMARY' or page_type == 'PROGRESS' then
    Gtk.Assistant.set_page_type(self.assistant, page.content, page_type)
  end
end

function Wizard:run()
  self.assistant:show_all()
  Gtk.main()
end

return AbsGtk