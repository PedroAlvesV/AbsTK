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
    create_button_box = function(self, number_buttons, labels)
      obj:create_button_box(number_buttons, labels)
    end,
    create_combobox = function(self, labels, sort)
      obj:create_combobox(labels, sort)
    end,
    run = function(self)
      obj:run()
    end,
  }
  return self
end

abstk.set_mode()

return abstk