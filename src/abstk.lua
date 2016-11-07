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
    obj = AbsGtk.new(title, w, h)
  elseif mode == 'curses' then
    obj = AbsCurses.new(title)
  end
  local self = {
    add_label = function(self, label)
      obj:add_label(label)
    end,
    add_button = function(self, label)
      obj:add_button(label)
    end,
    create_button_box = function(self, title, labels)
      obj:create_button_box(title, labels)
    end,
    create_combobox = function(self, labels, sort)
      obj:create_combobox(labels, sort)
    end,
    add_image = function(self, path, width, height)
      obj:add_image(path, width, height)
    end,
    add_text_input = function(self, title, is_password)
      obj:add_text_input(title, is_password)
    end,
    add_textbox = function(self, title, width, height)
      obj:add_textbox(title, width, height)
    end,
    run = function(self)
      obj:run()
    end,
  }
  return self
end

abstk.set_mode()

return abstk