local lgi = require 'lgi'
local curses = require 'curses'

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
  local Gtk = lgi.require('Gtk')
  local window = Gtk.Window {
     title = 'AbsTk Minimalist Test',
     default_width = 400,
     default_height = 300,
     on_destroy = Gtk.main_quit
  }
  function addLabel(vbox, label)
    vbox:pack_start(Gtk.Label { label = label }, true, true, 0)
  end
  local vbox = Gtk.VBox()
  addLabel(vbox, 'Parameter 1:\t\t1234')
  addLabel(vbox, 'Parameter 2:\t\tABCD')
  addLabel(vbox, 'Parameter 3:\t\tWXYZ')
  window:add(vbox)
  window:show_all()
  Gtk.main()
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
