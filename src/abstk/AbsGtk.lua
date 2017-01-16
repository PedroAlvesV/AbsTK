-------------------------------------------------
-- AbsGtk (GUI) to AbsTK-Lua
-- 
-- @classmod AbsGtk
-- @author Pedro Alves
-- @license MIT
-- @see abstk
-------------------------------------------------

-- TODO remove grid
-- TODO remove topbar in lists

local AbsGtk = {}

local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

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
   }
   local mt = {
      __index = Wizard,
   }
   setmetatable(self, mt)
   return self
end

function Screen:add_label(id, label)
   local label_widget = Gtk.Label { label = label }
   label_widget:set_halign('START')
   local item = {
      id = id,
      type = 'LABEL',
      widget = label_widget,
   }
   table.insert(self.widgets, item)
end

function Screen:add_button(id, label, tooltip, callback)
   local button = Gtk.Button {
      id = 'button',
      label = label,
   }
   button:set_tooltip_text(tooltip)
   if callback then
      button.on_clicked = function(self)
         callback(id, label)
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

function Screen:create_button_box(id, labels, tooltip, callback)
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
         button:set_tooltip_text(tooltip)
         if callback then
            button.on_clicked = function(self)
               callback(id, label, i)
            end
         end
         bbox:add(button)
      end
      return bbox
   end
   local item = {
      id = id,
      type = 'BUTTON_BOX',
      widget = Gtk.Box {
         orientation = 'VERTICAL',
         border_width = 10,
         create_bbox('HORIZONTAL', 20, 'START'),
      }
   }
   table.insert(self.widgets, item)
end

function Screen:create_combobox(id, labels, default_value, tooltip, callback)
   local combobox = Gtk.ComboBoxText { id = 'combobox' }
   for i, label in ipairs(labels) do
      combobox:append(i, label)
   end
   combobox:set_active((default_value or 1)-1)
   if callback then
      combobox.on_changed = function(self)
         callback(id, labels[combobox:get_active()+1])
      end
   end
   local box = Gtk.Box {
      id = 'box',
      orientation = 'VERTICAL',
      border_width = 10,
      combobox,
   }
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

function Screen:add_image(id, path, dimensions, tooltip)
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
   img:set_tooltip_text(tooltip)
   local item = {
      id = id,
      type = 'IMAGE',
      path = path,
      widget = Gtk.Box { img },
   }
   table.insert(self.widgets, item)
end

function Screen:add_text_input(id, label, visibility, default_value, tooltip, callback)
   local entry = Gtk.Entry {
      id = 'entry',
      hexpand = true,
   }
   entry:set_tooltip_text(tooltip)
   if callback then
      entry.on_changed = function(self)
         callback(id, entry:get_text())
      end
   end
   entry:set_text(default_value or "")
   entry:set_visibility(visibility)
   local widget
   if not label then
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
         Gtk.Label { label = label },
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

function Screen:add_textbox(id, default_value, tooltip, callback)
   local textview = Gtk.TextView { id = 'textview' }
   local buffer = Gtk.TextBuffer.new()
   buffer:set_text(default_value or "", -1)
   textview:set_tooltip_text(tooltip)
   textview:set_buffer(buffer)
   if callback then
      buffer.on_changed = function(self)
         callback(id, buffer:get_text(buffer:get_start_iter(), buffer:get_end_iter()))
      end
   end
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
   local function make_buttons(make_button)
      local buttons = {}
      if type(list[1]) == "table" then
         for i, entry in ipairs(list) do
            local label, value = entry[1], entry[2]
            table.insert(buttons, make_button(i, label, value))
         end
      else
         for i, label in ipairs(list) do
            local value = false
            if type(default_value) == "table" then
               value = default_value[i] or false
            end
            table.insert(buttons, make_button(i, label, value))
         end
      end
      for i, button in ipairs(buttons) do
         if callback then
            button.on_toggled = function(self)
               callback(id, button:get_active(), i)
            end
         end
      end
   end
   local function create_grid(id, list, default_value, tooltip, callback)
      local grid = Gtk.Grid.new{ id = 'grid' }
      local x, y = 1, 1
      local function make_button(i, label, value)
         local checkbutton = Gtk.CheckButton { id = i, label = label }
         checkbutton:set_active(value)
         grid:attach(checkbutton, x, y, 1, 1)
         y = y + 1
         if y == 4 then
            y = 1
            x = x + 1
         end
         return checkbutton
      end
      make_buttons(make_button)
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
      item.widget:set_tooltip_text(tooltip)
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
      local function make_button(id, label, value)
         local checkbutton = Gtk.CheckButton { id = id, label = label }
         checkbutton:set_active(value)
         item.widget:add(checkbutton)
         return checkbutton
      end
      make_buttons(make_button)
      item.widget:set_tooltip_text(tooltip)
      table.insert(self.widgets, item)
   else
      create_grid(id, list, default_value, tooltip, callback)
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
   local firstradio
   local function make_button(i, label, value)
      local radiobutton
      if i == 1 then
         radiobutton = Gtk.RadioButton.new_with_label(nil, label)
         firstradio = radiobutton
      else
         radiobutton = Gtk.RadioButton.new_with_label(Gtk.RadioButton.get_group(firstradio), label)
      end
      radiobutton:set_active(value)
      item.widget:add(radiobutton)
      return radiobutton
   end
   local function make_buttons()
      local buttons = {}
      if type(list[1]) == "table" then
         for i, entry in ipairs(list) do
            local label, value = entry[1], entry[2]
            table.insert(buttons, make_button(i, label, value))
         end
      else
         for i, field in ipairs(list) do
            table.insert(buttons, make_button(i, field, (i == default_value) ))
         end
      end
      for i, button in ipairs(buttons) do
         if callback then
            button.on_toggled = function(self)
               if button:get_active() then
                  callback(id, button:get_label(), i)
               end
            end
         end
      end
   end
   item.widget:set_tooltip_text(tooltip)
   make_buttons()
   table.insert(self.widgets, item)
end

function Screen:create_list(id, list, tooltip, callback)
   local function string_to_pair(list)
      local t = {}
      for _, label in ipairs(list) do
         table.insert(t, {label, false})
      end
      return t
   end
   if type(list[1]) == "string" then
      list = string_to_pair(list)
   end
   local columns = { LABEL = 1, CHECKBUTTON = 2 }
   local store = Gtk.ListStore.new {
      [columns.LABEL] = lgi.GObject.Type.STRING,
      [columns.CHECKBUTTON] = lgi.GObject.Type.BOOLEAN,
   }
   for i, item in ipairs(list) do
      store:append(item)
   end
   local scrolled_window = Gtk.ScrolledWindow {
      id = 'scrolled_window',
      shadow_type = 'ETCHED_IN',
      hscrollbar_policy = 'NEVER',
      hexpand = true,
      Gtk.TreeView {
         id = 'view',
         model = store,
         Gtk.TreeViewColumn {
            id = 'column1',
            fixed_width = 40,
            {
               Gtk.CellRendererToggle { id = 'checkbutton' },
               { active = columns.CHECKBUTTON },
            },
         },
         Gtk.TreeViewColumn {
            id = 'column2',
            sort_column_id = columns.LABEL - 1,
            {
               Gtk.CellRendererText { id = 'label' },
               { text = columns.LABEL },
            },
         },
      },
   }
   function scrolled_window.child.checkbutton:on_toggled(path_str)
      local path = Gtk.TreePath.new_from_string(path_str)
      store[path][columns.CHECKBUTTON] = not store[path][columns.CHECKBUTTON]
      if callback then
         callback(id, store[path][1], path_str+1)
      end
   end
   local item = {
      id = id,
      type = 'LIST',
      widget = Gtk.Frame { scrolled_window }
   }
   item.widget:set_tooltip_text(tooltip)
   table.insert(self.widgets, item)
end

function Screen:show_message_box(id, message, buttons)
   local buttons_number
   if buttons == 'OK' then
      buttons_number = 1
   elseif buttons == 'CLOSE' then
      buttons_number = 2
   elseif buttons == 'CANCEL' then
      buttons_number = 3
   elseif buttons == 'YES_NO' then
      buttons_number = 4
   elseif buttons == 'OK_CANCEL' then
      buttons_number = 5
   else
      buttons_number = 0
   end
   local message_dialog = Gtk.MessageDialog {
      id = id,
      transient_for = self.window,
      modal = true,
      destroy_with_parent = true,
      message_type = 0,
      buttons = buttons_number,
      text = message,
   }
   message_dialog:run()
end

function Screen:set_enabled(id, bool, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'BUTTON_BOX' then
            local button = item.widget.child.bbox.child[index]
            button:set_sensitive(bool)
         else
            local widget = item.widget
            widget:set_sensitive(bool)
         end
      end
   end
end

function Screen:set_value(id, value, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' then
            local label_widget = item.widget
            label_widget:set_text(value)
         elseif item.type == 'BUTTON' then
            local button = item.widget.child.button
            button:set_label(value)
         elseif item.type == 'BUTTON_BOX' then
            local button = item.widget.child.bbox.child[index]
            button:set_label(value)
         elseif item.type == 'COMBOBOX' then
            local combobox = item.widget.child.box.child.combobox
            for i, label in ipairs(item.labels) do
               if label == value then
                  combobox:set_active(i-1)
                  return
               end
            end
         elseif item.type == 'IMAGE' then
            local image = item.widget.child.image
            item.path = value
            image:set_from_file(value)
         elseif item.type == 'TEXT_INPUT' then
            local entry = item.widget.child.entry
            entry:set_text(value)
         elseif item.type == 'TEXTBOX' then
            local buffer = Gtk.TextBuffer {}
            local textview = item.widget.child.scrolled_window.child.textview
            buffer:set_text(value, -1)
            textview:set_buffer(buffer)
         elseif item.type == 'GRID' then
            local grid = item.widget.child.box.child[1]
            local i, j = index%3, math.ceil(index/3)
            if index%3 == 0 then
               i = 3
            end
            local button = Gtk.Grid.get_child_at(grid, i, j)
            button:set_active(value)
         elseif item.type == 'CHECKLIST' or item.type == 'RADIOLIST' then
            local button = item.widget.child[index]
            button:set_active(value)
         elseif item.type == 'LIST' then
            index = index - 1
            local store = item.widget.child.scrolled_window.child.view.model
            local path = Gtk.TreePath.new_from_string(index)
            store[path][1] = value
         end
      end
   end
end

function Screen:get_value(id, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' then
            local label_widget = item.widget
            return label_widget:get_text()
         elseif item.type == 'BUTTON' then
            local button = item.widget.child.button
            return button:get_label()
         elseif item.type == 'BUTTON_BOX' then
            local button = item.widget.child.bbox.child[index]
            return button:get_label()
         elseif item.type == 'COMBOBOX' then
            local combobox = item.widget.child.box.child.combobox
            return item.labels[combobox:get_active()+1]
         elseif item.type == 'IMAGE' then
            return item.path
         elseif item.type == 'TEXT_INPUT' then
            local entry = item.widget.child.entry
            return entry:get_text()
         elseif item.type == 'TEXTBOX' then
            local buffer = Gtk.TextView.get_buffer(item.widget.child.scrolled_window.child.textview)
            local start_iter = Gtk.TextBuffer.get_start_iter(buffer)
            local end_iter = Gtk.TextBuffer.get_end_iter(buffer)
            return buffer:get_text(start_iter, end_iter)
         elseif item.type == 'GRID' then
            local grid = item.widget.child.box.child[1]
            local i, j = index%3, math.ceil(index/3)
            if index%3 == 0 then
               i = 3
            end
            local button = Gtk.Grid.get_child_at(grid, j, i)
            return button:get_label(), button:get_active()
         elseif item.type == 'CHECKLIST' then
            local checkbutton = item.widget.child[index]
            return checkbutton:get_label(), checkbutton:get_active()
         elseif item.type == 'RADIOLIST' then
            for _, button in ipairs(item.widget.child) do
               if button:get_active() then
                  return button:get_label()
               end
            end
         elseif item.type == 'LIST' then
            index = index - 1
            local store = item.widget.child.scrolled_window.child.view.model
            local path = Gtk.TreePath.new_from_string(math.floor(index))
            return store[path][2], store[path][1]
         end
      end
   end
end

function Screen:run()
   self.window = Gtk.Window {
      title = self.title,
      default_width = self.w,
      default_height = self.h,
      on_destroy = Gtk.main_quit
   }
   local vbox = Gtk.VBox()
   for _, item in ipairs(self.widgets) do
      vbox:pack_start(item.widget, false, false, 0)
   end
   self.window:add(vbox)
   self.window:show_all()
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
   Gtk.Assistant.append_page(self.assistant, page.content)
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