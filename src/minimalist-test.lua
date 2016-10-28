local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local curses = require 'curses' 

local GtkClass, CursesClass

GtkClass = {
  new = function(title, w, h)
    local self = {
      window = Gtk.Window {
        title = title,
        default_width = w,
        default_height = h,
        on_destroy = Gtk.main_quit
      }
    }
    local mt = {
      __index = GtkClass,
    }
    setmetatable(self, mt)
    return self
  end,
  
  vbox = Gtk.VBox(),
  
  addLabel = function(self, label)
    self.vbox:pack_start(Gtk.Label { label = label }, true, true, 0)
  end,

  run = function(self)
    self.window:add(self.vbox)
    self.window:show_all()
    Gtk.main()
  end,
}

CursesClass = {
  new = function(title)
    curses.initscr()
    local self = {
      stdscr = curses.stdscr()
    }
    local mt = {
       __index = CursesClass,
    }
    setmetatable(self, mt)
    self:addLabel('AbsTk Minimalist Test')
    return self
  end,
  
  altLine = 0,
  
  addLabel = function(self, label)
    self.stdscr:mvaddstr(self.altLine,0,label)
    self.altLine = self.altLine + 2
  end,

  run = function(self)
    self.stdscr:refresh()
    local c = self.stdscr:getch()
    curses.endwin()
  end,
}

function main()
  local s = io.read()
  local scr
  if s == 'cur' then
    scr = CursesClass.new('AbsTk Minimalist Test')
  elseif s == 'gtk' then
    scr = GtkClass.new('AbsTk Minimalist Test', 400, 300)
  end
  scr:addLabel('Parameter 1:\t\t1234')
  scr:addLabel('Parameter 2:\t\tABCD')
  scr:addLabel('Parameter 3:\t\tWXYZ')
  scr:run()
end

main()