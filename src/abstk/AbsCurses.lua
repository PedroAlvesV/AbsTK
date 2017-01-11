local AbsCurses = {}

local curses = require 'curses' -- http://www.pjb.com.au/comp/lua/lcurses.html

local Screen = {}
local Wizard = {}

function AbsCurses.new_screen(title)
  curses.initscr()
  curses.cbreak()
  curses.echo(false)
  curses.nl(false)
  local self = {
    stdscr = curses.stdscr(),
    alt_line = 0,
  }
  local mt = {
    __index = Screen,
  }
  setmetatable(self, mt)
  return self
end

function AbsCurses.new_wizard(title)
  local self = {
    pages = {},
  }
  local mt = {
    __index = Wizard,
  }
  setmetatable(self, mt)
  return self
end

function Screen:add_label(id, label)

  local item = {
    id = id,
    type = 'LABEL',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:add_button(id, label, tooltip, callback)

  local item = {
    id = id,
    type = 'BUTTON',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:create_button_box(id, labels, tooltip, callback)

  local item = {
    id = id,
    type = 'BUTTON_BOX',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:create_combobox(id, labels, default_value, tooltip, callback)

  local item = {
    id = id,
    type = 'COMBOBOX',
    labels = labels,
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:add_image(id, path, dimensions, tooltip)
  return nil
end

function Screen:add_text_input(id, label, visibility, default_value, tooltip, callback)

  local item = {
    id = id,
    type = 'TEXT_INPUT',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:add_textbox(id, default_value, tooltip, callback)

  local item = {
    id = id,
    type = 'TEXTBOX',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:create_checklist(id, list, default_value, tooltip, callback)

  local item = {
    id = id,
    type = 'GRID',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:create_radiolist(id, list, default_value, tooltip, callback)

  local item = {
    id = id,
    type = 'RADIOLIST',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:create_list(id, list, tooltip, callback)

  local item = {
    id = id,
    type = 'LIST',
    widget = widget,
  }
  table.insert(self.widgets, item)
end

function Screen:show_message_box(id, message, buttons)
  local buttons_number
  if buttons == 'OK' then
    buttons_number = 1
  elseif buttons == 'CLOSE' then
    buttons_number = 2
  elseif buttons == 'CANCEL' then
    buttons_number = 3
  elseif buttons == 'YES_NO' then
    buttons_number = 4
  elseif buttons == 'OK_CANCEL' then
    buttons_number = 5
  else
    buttons_number = 0
  end
end

function Screen:set_enabled(id, bool, index)
  for _, item in ipairs(self.widgets) do
    if item.id == id then

    end
  end
end

function Screen:set_value(id, value, index)
  for _, item in ipairs(self.widgets) do
    if item.id == id then
      if item.type == 'LABEL' then

      elseif item.type == 'BUTTON' then

      elseif item.type == 'BUTTON_BOX' then

      elseif item.type == 'COMBOBOX' then

      elseif item.type == 'IMAGE' then

      elseif item.type == 'TEXT_INPUT' then

      elseif item.type == 'TEXTBOX' then

      elseif item.type == 'GRID' then

      elseif item.type == 'CHECKLIST' or item.type == 'RADIOLIST' then

      elseif item.type == 'LIST' then

      end
    end
  end
end

function Screen:get_value(id, index)
  for _, item in ipairs(self.widgets) do
    if item.id == id then
      if item.type == 'LABEL' then

      elseif item.type == 'BUTTON' then

      elseif item.type == 'BUTTON_BOX' then

      elseif item.type == 'COMBOBOX' then

      elseif item.type == 'IMAGE' then

      elseif item.type == 'TEXT_INPUT' then

      elseif item.type == 'TEXTBOX' then

      elseif item.type == 'GRID' then

      elseif item.type == 'CHECKLIST' then

      elseif item.type == 'RADIOLIST' then

      elseif item.type == 'LIST' then

      end
    end
  end
end

function Screen:run()

end

function Wizard:add_page(id, screen, page_type)
  local content
  for _, item in ipairs(screen.widgets) do

  end
  local page = {
    id = id,
    title = screen.title,
    content = content,
  }
  table.insert(self.pages, page)
  if page_type == 'INTRO' or page_type == 'CONTENT' or page_type == 'CONFIRM'
  or page_type == 'SUMMARY' or page_type == 'PROGRESS' then

  end
end

function Wizard:run()

end

return AbsCurses