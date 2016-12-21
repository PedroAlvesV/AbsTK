-------------------------------------------------
-- Main module to AbsTK-Lua
-- @module abstk
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local abstk = {}

local AbsGtk = require 'abstk.AbsGtk'
local AbsCurses = require 'abstk.AbsCurses'

local mode = nil

-------------------------------------------------
-- Sets mode to determine whether interface will be drawn,
-- text (curses) or GUI (GTK).
-- @param arg   	the mode
-------------------------------------------------
function abstk.set_mode(arg)
  if arg == 'curses' or arg == 'gtk' then
    mode = arg
  elseif os.getenv("DISPLAY") then
    mode = 'gtk'
  else
    mode = 'curses'
  end
end

-------------------------------------------------
-- Constructs a screen. 
--
-- @param title    the title of the screen
-- @param w        the width of the screen (only used in GUI)
-- @param h        the height of the screen (only used in GUI)
--
-- @return 				 a Screen table.
-------------------------------------------------
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
    add_label = function(self, id, label)
      obj:add_label(id, label)
    end,
    add_button = function(self, id, label, tooltip, callback)
      obj:add_button(id, label, tooltip, callback)
    end,
    create_button_box = function(self, id, labels, tooltip, callback)
      obj:create_button_box(id, labels, tooltip, callback)
    end,
    create_combobox = function(self, id, labels, default_value, tooltip, callback)
      obj:create_combobox(id, labels, default_value, tooltip, callback)
    end,
    add_image = function(self, id, path, dimensions, tooltip)
      obj:add_image(id, path, dimensions, tooltip)
    end,
    add_text_input = function(self, id, label, default_value, tooltip, callback)
      obj:add_text_input(id, label, true, default_value, tooltip, callback)
    end,
    add_password = function(self, id, label, default_value, tooltip, callback)
      obj:add_text_input(id, label, false, default_value, tooltip, callback)
    end,
    add_textbox = function(self, id, default_value, tooltip, callback)
      obj:add_textbox(id, default_value, tooltip, callback)
    end,
    create_checklist = function(self, id, list, default_value, tooltip, callback)
      obj:create_checklist(id, list, default_value, tooltip, callback)
    end,
    create_radiolist = function(self, id, list, default_value, tooltip, callback)
      obj:create_radiolist(id, list, default_value, tooltip, callback)
    end,
    create_list = function(self, id, list, tooltip, callback)
      obj:create_list(id, list, tooltip, callback)
    end,
    show_message_box = function(self, id, message, buttons)
      obj:show_message_box(id, message, buttons)
    end,
    set_enabled = function(self, id, bool, ...)
      obj:set_enabled(id, bool, ...)
    end,
    set_value = function(self, id, value, index)
      obj:set_value(id, value, index)
    end,
    get_value = function(self, id, index)
      return obj:get_value(id, index)
    end,
    run = function(self)
      obj:run()
    end,
  }
  local mt = {
    __index = obj,
  }
  setmetatable(self, mt)
  return self
end

-------------------------------------------------
-- Constructs a wizard.
--
-- @param title    the title of the window
-- @param w        the width of the window (only used in GUI)
-- @param h        the height of the window (only used in GUI)
--
-- @return 				  a Wizard table.
-------------------------------------------------
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