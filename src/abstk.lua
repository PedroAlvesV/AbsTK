local abstk = {}

local AbsGtk = require 'abstk.AbsGtk'
local AbsCurses = require 'abstk.AbsCurses'

local mode = nil

function abstk.set_mode(arg)
  if arg == 'curses' or arg == 'gtk' then
    mode = arg
  elseif os.getenv("DISPLAY") then
    mode = 'gtk'
  else
    mode = 'curses'
  end
end

function abstk.new_screen(title, w, h)
  local obj
  if mode == 'gtk' then
    if w == nil then
      w = 400
    end
    if h == nil then
      h = w*0.75
    end
    obj = AbsGtk.new_screen(title, w, h)
  elseif mode == 'curses' then
    obj = AbsCurses.new_screen(title)
  end
  local self = {
    add_label = function(self, id, label, tooltip, callback)
      obj:add_label(id, label, tooltip, callback)
    end,
    add_button = function(self, id, label, default_value, tooltip, callback)
      obj:add_button(id, label, default_value, tooltip, callback)
    end,
    create_button_box = function(self, id, labels, layout, default_value, tooltip, callback)
      obj:create_button_box(id, labels, layout, default_value, tooltip, callback)
    end,
    create_combobox = function(self, id, labels, default_value, tooltip, callback)
      obj:create_combobox(id, labels, default_value, tooltip, callback)
    end,
    add_image = function(self, id, path, dimensions, tooltip, callback)
      obj:add_image(id, path, dimensions, tooltip, callback)
    end,
    add_text_input = function(self, id, title, is_password, default_value, tooltip, callback)
      obj:add_text_input(id, title, is_password, default_value, tooltip, callback)
    end,
    add_textbox = function(self, id, width, height, default_value, tooltip, callback)
      obj:add_textbox(id, width, height, default_value, tooltip, callback)
    end,
    create_checklist = function(self, id, list, default_value, tooltip, callback)
      obj:create_checklist(id, list, default_value, tooltip, callback)
    end,
    create_radiolist = function(self, id, list, default_value, tooltip, callback)
      obj:create_radiolist(id, list, default_value, tooltip, callback)
    end,
    create_list = function(self, id, list, default_value, tooltip, callback)
      obj:create_list(id, list, default_value, tooltip, callback)
    end,
    run = function(self)
      obj:run()
    end,
  }
  return obj
end

function abstk.new_wizard(title, w, h)
  local obj
  if mode == 'gtk' then
    if w == nil then
      w = 400
    end
    if h == nil then
      h = w*0.75
    end
    obj = AbsGtk.new_wizard(title, w, h)
  elseif mode == 'curses' then
    obj = AbsCurses.new_wizard(title)
  end
  local self = {
    add_page = function(self, id, screen, page_type)
      obj:add_page(id, screen, page_type)
    end,
    run = function(self)
      obj:run()
    end,
  }
  return self
end

abstk.set_mode()

return abstk