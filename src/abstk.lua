local abstk = {}

local AbsGtk = require 'abstk/AbsGtk'
local AbsCurses = require 'abstk/AbsCurses'

local mode = nil

function abstk.set_mode(arg)
  if arg ~= 'curses' and arg ~= 'gtk' then
    mode = 'curses'
  else
    mode = arg
  end
end

function abstk.new_screen(title, w, h)
  local self = {}
  if mode == 'gtk' then
    if w == nil then
      w = 400
    end
    if h == nil then
      h = w*0.75
    end
    self = AbsGtk.new(title, w, h)
    setmetatable(self, { __index = AbsGtk } )
  elseif mode == 'curses' then
    self = AbsCurses.new(title)
    setmetatable(self, { __index = AbsCurses } )
  end
  return self
end

function abstk:add_label(label)
  self:add_label(label)
end

function abstk:run()
  self:run()
end

return abstk