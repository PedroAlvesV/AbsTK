local AbsCurses = {}

local curses = require 'curses' -- http://www.pjb.com.au/comp/lua/lcurses.html

function AbsCurses.new(title)
  curses.initscr()
  local self = {
    stdscr = curses.stdscr(),
    alt_line = 0,
  }
  local mt = {
     __index = AbsCurses,
  }
  setmetatable(self, mt)
  self:add_label('AbsTk Minimalist Test')
  return self
end

function AbsCurses:add_label(label)
  self.stdscr:mvaddstr(self.alt_line,0,label)
  self.alt_line = self.alt_line + 2
end

function AbsCurses:run()
  self.stdscr:refresh()
  local c = self.stdscr:getch()
  curses.endwin()
end

return AbsCurses