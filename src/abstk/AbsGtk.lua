-------------------------------------------------
-- AbsGtk (GUI) to AbsTK-Lua
-- 
-- @classmod AbsGtk
-- @author Pedro Alves
-- @license MIT
-- @see abstk
-------------------------------------------------

local AbsGtk = {}

local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local util = require 'abstk.util'

local Screen = {}
local Wizard = {}

function AbsGtk.new_screen(title, w, h)
   local self = {
      title = title,
      window = Gtk.Window {
         title = title,
         default_width = w,
         default_height = h,
         on_destroy = Gtk.main_quit
      },
      widgets = {},
   }
   local mt = {
      __index = Screen,
   }
   setmetatable(self, mt)
   return self
end

function AbsGtk.new_wizard(title, w, h, exit_callback)
   local self = {
      title = title,
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
   local item = {
      id = id,
      type = 'BUTTON',
      widget = Gtk.Box {
         orientation = 'HORIZONTAL',
         button,
      }
   }
   if callback then
      button.on_clicked = function(self)
         callback(id, item.widget.child.button:get_label())
      end
   end
   table.insert(self.widgets, item)
end

function Screen:create_button_box(id, labels, tooltips, callbacks)
   local function create_bbox(orientation, spacing, layout)
      local bbox = Gtk.ButtonBox {
         id = 'bbox',
         orientation = orientation,
         layout_style = layout,
         spacing = spacing,
      }
      for i, label in ipairs(labels) do
         local button = Gtk.Button { id = i, label = label }
         button:set_tooltip_text(tooltips and tooltips[i])
         if callbacks[i] then
            button.on_clicked = function(self)
               callbacks[i](id, i, label)
            end
         end
         bbox:add(button)
      end
      return bbox
   end
   local item = {
      id = id,
      type = 'BUTTON_BOX',
      size = #labels,
      widget = Gtk.Box {
         orientation = 'VERTICAL',
         create_bbox('HORIZONTAL', 20, 'START'),
      }
   }
   table.insert(self.widgets, item)
end

function Screen:create_combobox(id, title, labels, default_value, tooltip, callback)
   local combobox = Gtk.ComboBoxText { id = 'combobox' }
   for i, label in ipairs(labels) do
      combobox:append(i, label)
   end
   combobox:set_active((default_value or 1)-1)
   if callback then
      combobox.on_changed = function(self)
         local index = math.floor(combobox:get_active()+1)
         callback(id, index, labels[index])
      end
   end
   local title_widget = Gtk.Label { label = title }
   title_widget:set_halign('START')
   local box = Gtk.Box {
      id = 'box',
      orientation = 'VERTICAL',
      combobox,
   }
   local item = {
      id = id,
      type = 'COMBOBOX',
      labels = labels,
      widget = Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 10,
         title_widget,
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
   entry:set_text(default_value or "")
   entry:set_visibility(visibility)
   if callback then
      entry.on_changed = function(self)
         callback(id, entry:get_text())
      end
   end
   local widget
   if not label then
      widget = Gtk.Box {
         orientation = 'VERTICAL',
         entry,
      }
   else
      widget = Gtk.Box {
         orientation = 'HORIZONTAL',
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

function Screen:add_textbox(id, title, default_value, tooltip)
   local textview = Gtk.TextView { id = 'textview' }
   local buffer = Gtk.TextBuffer.new()
   buffer:set_text(default_value or "", -1)
   textview:set_tooltip_text(tooltip)
   textview:set_buffer(buffer)
   textview:set_wrap_mode(Gtk.WrapMode.CHAR)
   textview:set_editable(false)
   local item = {
      id = id,
      type = 'TEXTBOX',
      widget = Gtk.Box { 
         orientation = 'VERTICAL',
      }
   }
   if title then
      local title_widget = Gtk.Label { label = title }
      title_widget:set_halign('START')
      item.widget:add(title_widget)
   end
   local scrolled_window = Gtk.ScrolledWindow {id = 'scrolled_window', textview}
   scrolled_window:set_min_content_height(105)
   item.widget:add(scrolled_window)
   table.insert(self.widgets, item)
end

function Screen:add_checkbox(id, label, default_value, tooltip, callback)
   local item = {
      id = id,
      type = 'CHECKBOX',
      widget = Gtk.Box {
         orientation = 'VERTICAL',
      }
   }
   local checkbox = Gtk.CheckButton { id = "checkbox", label = label }
   checkbox:set_active(default_value or false)
   if callback then
      checkbox.on_toggled = function(self)
         callback(id, checkbox:get_active(), label)
      end
   end
   item.widget:add(checkbox)
   item.widget:set_tooltip_text(tooltip)
   table.insert(self.widgets, item)
end

function Screen:create_checklist(id, title, list, default_value, tooltip, callback)
   local function create_short_checklist()
      local title_widget = Gtk.Label { label = title }
      title_widget:set_halign('START')
      local item = {
         id = id,
         type = 'CHECKLIST',
         size = #list,
         widget = Gtk.Box {
            title_widget,
            orientation = 'VERTICAL',
         }
      }
      local function make_item(i, label, value)
         local checkbutton = Gtk.CheckButton { id = i, label = label }
         checkbutton:set_active(value)
         item.widget:add(checkbutton)
         if callback then
            checkbutton.on_toggled = function(self)
               callback(id, i, checkbutton:get_active(), label)
            end
         end
         return checkbutton
      end
      util.make_list_items(make_item, list, default_value)
      return item
   end
   local function create_long_checklist()
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
         hscrollbar_policy = 'NEVER',
         hexpand = true,
         Gtk.TreeView {
            id = 'view',
            model = store,
            Gtk.TreeViewColumn {
               id = 'column1',
               fixed_width = 30,
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
      scrolled_window:set_min_content_height(110)
      scrolled_window.child.view:set_headers_visible(false)
      function scrolled_window.child.checkbutton:on_toggled(path_str)
         local path = Gtk.TreePath.new_from_string(path_str)
         store[path][columns.CHECKBUTTON] = not store[path][columns.CHECKBUTTON]
         if callback then
            callback(id, math.floor(path_str+1), store[path][2], store[path][1])
         end
      end
      local title_widget = Gtk.Label { label = title }
      title_widget:set_halign('START')
      local item = {
         id = id,
         type = 'LIST',
         size = #list,
         widget = Gtk.Box {
            title_widget,
            orientation = 'VERTICAL',
            scrolled_window
         }
      }
      return item
   end
   local item
   if #list < 6 then
      item = create_short_checklist()
   else
      item = create_long_checklist()
   end
   item.widget:set_tooltip_text(tooltip)
   table.insert(self.widgets, item)
end

function Screen:create_selector(id, title, list, default_value, tooltip, callback)
   local function create_short_selector()
      local title_widget = Gtk.Label { label = title }
      title_widget:set_halign('START')
      local item = {
         id = id,
         type = 'RADIOLIST',
         widget = Gtk.Box {
            title_widget,
            orientation = 'VERTICAL',
         }
      }
      local firstradio
      local function make_item(i, label, value)
         local radiobutton
         if i == 1 then
            radiobutton = Gtk.RadioButton.new_with_label(nil, label)
            firstradio = radiobutton
         else
            radiobutton = Gtk.RadioButton.new_with_label(Gtk.RadioButton.get_group(firstradio), label)
         end
         radiobutton:set_active(value)
         if callback then
            radiobutton.on_toggled = function(self)
               if radiobutton:get_active() then
                  callback(id, i, radiobutton:get_label())
               end
            end
         end
         item.widget:add(radiobutton)
         return radiobutton
      end
      util.make_list_items(make_item, list, default_value)
      return item
   end
   local function create_long_selector()
      local selector = Gtk.ListBox {id = 'selector'}
      local function make_item(i, label, value)
         local item = Gtk.Label {id = i, label = label}
         item:set_halign('START')
         if not default_value and value then
            default_value = i
         end
         return item
      end
      local items = util.make_list_items(make_item, list, default_value)
      for _, item in ipairs(items) do
         selector:insert(item, -1)
      end
      if not default_value then
         default_value = 1
      end
      local row = selector:get_row_at_index(default_value-1)
      selector:select_row(row)
      function selector.on_row_selected(_, row)
         local index = math.floor(row:get_index() + 1)
         local row_text = row:get_child():get_label()
         if callback then
            callback(id, index, row_text)
         end
      end
      local scrolled_window = Gtk.ScrolledWindow {
         id = 'scrolled_window',
         hscrollbar_policy = 'NEVER',
         hexpand = true,
         selector,
      }
      scrolled_window:set_min_content_height(95)
      local title_widget = Gtk.Label { label = title }
      title_widget:set_halign('START')
      local item = {
         id = id,
         type = 'SELECTOR',
         widget = Gtk.Box {
            title_widget,
            scrolled_window,
            orientation = 'VERTICAL',
         }
      }
      return item
   end
   local item
   if #list < 6 then
      item = create_short_selector()
   else
      item = create_long_selector()
   end
   item.widget:set_tooltip_text(tooltip)
   table.insert(self.widgets, item)
end

function Screen:show_message_box(message, buttons)
   local buttons_constant
   if buttons == 'OK' or not buttons then
      buttons_constant = Gtk.ButtonsType.OK
   elseif buttons == 'CLOSE' then
      buttons_constant = Gtk.ButtonsType.CLOSE
   elseif buttons == 'YES_NO' then
      buttons_constant = Gtk.ButtonsType.YES_NO
   elseif buttons == 'OK_CANCEL' then
      buttons_constant = Gtk.ButtonsType.OK_CANCEL
   else
      error('Invalid argument "'..buttons..'"')
   end
   local message_dialog = Gtk.MessageDialog {
      id = "", 
      transient_for = self.window,
      modal = true,
      destroy_with_parent = true,
      message_type = 0,
      buttons = buttons_constant,
      text = message,
   }
   local result = message_dialog:run()
   if result == Gtk.ResponseType.OK then
      return "OK"
   elseif result == Gtk.ResponseType.CANCEL or result == Gtk.ResponseType.DELETE_EVENT or result == Gtk.ResponseType.CLOSE then
      return "CANCEL"
   elseif result == Gtk.ResponseType.YES then
      return "YES"
   elseif result == Gtk.ResponseType.NO then
      return "NO"
   end
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
         elseif item.type == 'CHECKBOX' then
            local checkbox = item.widget.child.checkbox
            checkbox:set_active(value)
         elseif item.type == 'CHECKLIST' then
            local button = item.widget.child[index+1]
            button:set_active(value)
         elseif item.type == 'RADIOLIST' then
            local button = item.widget.child[value+1]
            button:set_active(true)
         elseif item.type == 'SELECTOR' then
            local selector = item.widget.child.scrolled_window.child.selector
            local row = selector:get_row_at_index(value-1)
            selector:select_row(row)
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
         elseif item.type == 'CHECKBOX' or item.type == 'CHECKLIST' then
            local check = item.widget.child.checkbox
            if item.type == 'CHECKLIST' then
               check = item.widget:get_children()[index+1]
            end
            return check:get_label(), check:get_active()
         elseif item.type == 'RADIOLIST' then
            for i, child in ipairs(item.widget:get_children()) do
               if i > 1 then
                  if child:get_active() then
                     return child:get_label()
                  end
               end
            end
         elseif item.type == 'SELECTOR' then
            local selector = item.widget.child.scrolled_window.child.selector
            local selected_row = selector:get_selected_row()
            local row_label = selected_row:get_child()
            return row_label:get_label()
         elseif item.type == 'LIST' then
            index = index - 1
            local store = item.widget.child.scrolled_window.child.view.model
            local path = Gtk.TreePath.new_from_string(math.floor(index))
            return store[path][1], store[path][2]
         end
      end
   end
end

local function create_vbox(widgets)
   local vbox = Gtk.VBox{
      border_width = 10,
      spacing = 10,
   }
   for _, item in ipairs(widgets) do
      vbox:pack_start(item.widget, false, false, 0)
   end
   return vbox
end

local function iter_screen_items(screen)
   local data = {}
   for _, item in ipairs(screen.widgets) do
      data[item.id] = {}
      if item.type == 'BUTTON_BOX' or item.type == 'CHECKLIST' or item.type == 'LIST' then
         for j=1, item.size do
            if item.type == 'CHECKLIST' then
               data[item.id][j] = {label = nil, state = nil}
               data[item.id][j].label, data[item.id][j].state = screen:get_value(item.id, j)
            else
               local value = screen:get_value(item.id, j)
               if item.type == 'LIST' then
                  local _, v = screen:get_value(item.id, j)
                  value = v
               end
               data[item.id][j] = value
            end
         end
      else
         local value = screen:get_value(item.id)
         if item.type == 'CHECKBOX' then
            local _, v = screen:get_value(item.id)
            value = v
         end
         data[item.id] = value
      end
   end
   return data
end

function Screen:run()
   local vbox = create_vbox(self.widgets)
   local function create_assist_buttons()
      local bbox = Gtk.ButtonBox {
         id = 'bbox',
         orientation = 'HORIZONTAL',
         layout_style = 'END',
         spacing = 5,
      }
      local cancel = Gtk.Button { id = 'CANCEL', label = "Cancel" }
      local done = Gtk.Button { id = 'DONE', label = "Done" }
      local function fdone()
         self.done = true
         self.data = util.collect_data(self, iter_screen_items)
         self.window:close()
--         print("fdone")
      end
      cancel.on_clicked = fdone
      done.on_clicked = fdone
      bbox:add(cancel)
      bbox:add(done)
      return bbox
   end
   local assist_buttons = create_assist_buttons()
   vbox:pack_end(assist_buttons, false, false, 0)
   self.window:add(vbox)
   self.window:show_all()
   Gtk.main()
   return self.data
end

function Wizard:add_page(id, screen)
   local vbox = create_vbox(screen.widgets)
   local page = {
      id = id,
      screen = screen,
      complete = true,
      content = Gtk.ScrolledWindow{vbox},
   }

   -- work arround bug where scrolled window BG goes black
   -- http://stackoverflow.com/questions/27592603
   -- https://git.gnome.org/browse/california/commit/?id=3442b3
   local bg_color = self.assistant:get_toplevel():get_style_context():get_background_color(Gtk.StateFlags.NORMAL)
   page.content:override_background_color(Gtk.StateFlags.NORMAL, bg_color)

   table.insert(self.pages, page)
   self.assistant:append_page(page.content)
   self.assistant:set_page_title(page.content, screen.title or " ")
   self.assistant:set_page_complete(page.content, true)
   self.assistant:set_page_type(page.content, 'CONTENT')
end

function Wizard:run()
   local function config_nav_buttons()
      local last_page = self.assistant:get_nth_page(-1)
      self.assistant:set_page_type(last_page, 'CONFIRM')
      local function get_footer()
         local label = Gtk.Label{}
         self.assistant:add_action_widget(label)
         local footer = label:get_parent()
         footer:remove(label)
         return footer
      end
      local buttonset = get_footer():get_children()
      for i, button in ipairs(buttonset) do
         local label = button:get_label()
         if label == "_Apply" then
            button:set_label("Done")
            button.on_clicked = function()
               if self.pages[#self.pages].screen:show_message_box("Press OK to proceed.", 'OK_CANCEL') == "OK" then
                  self.done = true
               end
            end
         elseif label == "_Cancel" then
            button.on_clicked = function()
               if self.pages[#self.pages].screen:show_message_box("Are you sure you want to quit?", 'YES_NO') == "YES" then
                  self.done = true
               end
            end
         elseif label == "_Finish" then
            get_footer():remove(button)
         end
      end
   end
   config_nav_buttons()
   self.assistant:show_all()
   Gtk.main()
   while true do
      if self.done then
         return util.collect_data(self, iter_screen_items)
      end
   end
end

return AbsGtk