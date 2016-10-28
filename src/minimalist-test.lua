local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local curses = require 'curses'

local GtkClass

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

function runInCurses()
  curses.initscr()
  curses.cbreak()
  curses.echo(false)  -- not noecho !
  curses.nl(false)    -- not nonl !
  local stdscr = curses.stdscr()  -- it's a userdatum
  stdscr:clear()
  local i = 0
  function addLabel(label)
    stdscr:mvaddstr(i,0,label)
    i = i + 2
  end
  addLabel('AbsTk Minimalist Test')
  addLabel('Parameter 1:\t\t1234')
  addLabel('Parameter 2:\t\tABCD')
  addLabel('Parameter 3:\t\tWXYZ')
  stdscr:refresh()
  local c = stdscr:getch()
  curses.endwin()
end

function runInGtk()
  local gtk = GtkClass.new('AbsTk Minimalist Test', 400, 300)
  gtk:addLabel('Parameter 1:\t\t1234')
  gtk:addLabel('Parameter 2:\t\tABCD')
  gtk:addLabel('Parameter 3:\t\tWXYZ')
  gtk:run()
end

function main()
  local s = io.read();
  if s == 'cur' then
    runInCurses()
  elseif s == 'gtk' then
    runInGtk()
  end
end

main()
