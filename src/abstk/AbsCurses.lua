local AbsCurses = {}

local curses = require 'curses' -- http://www.pjb.com.au/comp/lua/lcurses.html
-- https://github.com/jballanc/playgo/blob/master/doc/curses-examples/lcurses-test.lua
local Screen = {}
local Wizard = {}

local AbsCursesLabel = {}
local AbsCursesButton = {}
local AbsCursesButtonBox = {}
local AbsCursesComboBox = {}
local AbsCursesTextInput = {}
local AbsCursesTextBox = {}
local AbsCursesGrid = {}
local AbsCursesCheckList = {}
local AbsCursesRadioList = {}
local AbsCursesList = {}

local max_x, max_y
local colors = {}
local actions = {
   PASSTHROUGH = 0,
   HANDLED = -2,
   PREVIOUS = -1,
   NEXT = 1,
   FOCUS_ON_BUTTONS = 10
}
local keys = {
   TAB = 9,
   ENTER = 10,
   ESC = 27,
   SPACE = 32,
}
local buttons = {
   PREVIOUS = 0,
   NEXT = 1,
   QUIT = 2,
   LAST = 2,
}

local function str_attr(str, attr)
   local ch = curses.new_chstr(#str)
   ch:set_str(0, str, attr)
   return ch
end

local function attr_code(attr)
   local ch = curses.new_chstr(1)
   ch:set_str(0, " ", attr)
   local c, code = ch:get(0)
   return code
end

function AbsCurses.new_screen(title)
   local self = {
      title = title,
      widgets = {},
      focus = 0,
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

function AbsCursesLabel.new(label)
   local self = {
      height = 1,
      label = label,
      focusable = false,
   }
   return setmetatable(self, { __index = AbsCursesLabel })
end

function AbsCursesLabel:draw(drawable, x, y)
   drawable:attrset(colors.default)
   drawable:mvaddstr(y, x, self.label)
end

function AbsCursesButton.new(label)
   local self = {
      height = 1,
      label = " "..label.." ",
      focusable = true,
   }
   return setmetatable(self, { __index = AbsCursesButton })
end

function AbsCursesButton:draw(drawable, x, y, focus)
   drawable:attrset(colors.button)
   drawable:mvaddstr(y, x, self.label)
   if focus then
      local left, right = ">", "<"
      drawable:mvaddstr(y, x-1, left)
      drawable:mvaddstr(y, x+string.len(self.label), right)
   end
end

function AbsCursesButton:process_key(key)
   if (key == keys.ENTER or key == keys.SPACE) and self.enabled then
      self.runCallback()
   elseif key == curses.KEY_LEFT or key == curses.KEY_RIGHT then
      return actions.FOCUS_ON_BUTTONS
   elseif key == keys.TAB or key == curses.KEY_DOWN then
      return actions.NEXT
   elseif key == curses.KEY_UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function AbsCursesButtonBox.new(labels)
   local self = {
      height = 1,
      labels = labels,
      focusable = true,
   }
   return setmetatable(self, { __index = AbsCursesButtonBox })
end

function AbsCursesButtonBox:draw(drawable, x, y, focus)
   for _, label in ipairs(self.labels) do
      drawable:mvaddstr(y, x, " "..label.." ", colors.button)
      x = x + 7
   end
   if focus then
      -- TODO subfocus
      local left, right = ">", "<"
      drawable.addstr(y, x-1, left)
      drawable.addstr(y, x+string.len(self.label), right)
   end
end

function Screen:add_label(id, label)
   local item = {
      id = id,
      type = 'LABEL',
      widget = AbsCursesLabel.new(label),
   }
   table.insert(self.widgets, item)
end

function Screen:add_button(id, label, tooltip, callback)
   local item = {
      id = id,
      type = 'BUTTON',
      widget = AbsCursesButton.new(label),
   }
   table.insert(self.widgets, item)
end

function Screen:create_button_box(id, labels, tooltip, callback)
   local item = {
      id = id,
      type = 'BUTTON_BOX',
      widget = AbsCursesButtonBox.new(labels),
   }
   table.insert(self.widgets, item)
end

function Screen:create_combobox(id, labels, default_value, tooltip, callback)
   local item = {
      id = id,
      type = 'COMBOBOX',
      labels = labels,
      widget = AbsCursesComboBox.new(labels),
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
      widget = AbsCursesTextInput.new(label, visibility),
   }
   table.insert(self.widgets, item)
end

function Screen:add_textbox(id, default_value, tooltip, callback)
   local item = {
      id = id,
      type = 'TEXTBOX',
      widget = AbsCursesTextBox.new(),
   }
   table.insert(self.widgets, item)
end

function Screen:create_checklist(id, list, default_value, tooltip, callback)
   if #list < 4 then
      local item = {
         id = id,
         type = 'CHECKLIST',
         widget = AbsCursesCheckList.new(list),
      }
   else
      local item = {
         id = id,
         type = 'GRID',
         widget = AbsCursesGrid.new(list),
      }
   end
   table.insert(self.widgets, item)
end

function Screen:create_radiolist(id, list, default_value, tooltip, callback)
   local item = {
      id = id,
      type = 'RADIOLIST',
      widget = AbsCursesRadioList.new(list),
   }
   table.insert(self.widgets, item)
end

function Screen:create_list(id, list, tooltip, callback)
   local item = {
      id = id,
      type = 'LIST',
      widget = AbsCursesList.new(list),
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

local function init_curses()
   local stdscr = curses.initscr()
   curses.cbreak()
   curses.echo(false)
   curses.nl(false)
   max_y, max_x = stdscr:getmaxyx()
   max_x = math.min(max_x, 127)
   -- max_y = math.min(max_y, 24)
   curses.start_color()
   curses.use_default_colors()
   pcall(curses.init_pair, 1, curses.COLOR_WHITE, curses.COLOR_BLUE)
   pcall(curses.init_pair, 2, curses.COLOR_BLACK, curses.COLOR_BLUE)
   pcall(curses.init_pair, 3, curses.COLOR_YELLOW, curses.COLOR_BLUE)
   pcall(curses.init_pair, 4, curses.COLOR_BLACK, curses.COLOR_WHITE)
   pcall(curses.init_pair, 5, curses.COLOR_BLACK, curses.COLOR_CYAN)
   pcall(curses.init_pair, 6, curses.COLOR_CYAN, curses.COLOR_BLUE)
   colors.default = curses.color_pair(1)
   colors.disabled = curses.color_pair(2) + curses.A_BOLD
   colors.title = curses.color_pair(3) + curses.A_BOLD
   colors.button = curses.color_pair(4)
   colors.widget = curses.color_pair(5)
   colors.widget_disabled = curses.color_pair(5) + curses.A_BOLD
   colors.current = curses.color_pair(6) + curses.A_BOLD
   stdscr:clear()
   stdscr:wbkgd(attr_code(colors.default))
   stdscr:attrset(colors.default)
   return stdscr
end

function Screen:run()
   local stdscr = init_curses()
   self.pad = curses.newpad(max_x-2 + 100, max_y-4 + 100)
   self.pad:wbkgd(attr_code(colors.default))
   stdscr:sub(max_y-1, max_x, 0, 0):box(0, 0)
   stdscr:refresh()
   local function move_focus(direction)
      local widget = self.widgets[self.focus]
      while true do
         --widget.inside = False
         self.focus = self.focus + direction
         if self.focus == -1 or self.focus == string.len(self.widgets) then
            return actions.FOCUS_ON_BUTTONS
         end
         --widget = self.__setupFocusAndCurrent(direction)
         if self.widgets[self.focus].enabled then
            return actions.HANDLED
         end
      end
   end
   local function process_key(key, widget)
      local motion = widget:process_key(key)
      if motion == actions.PASSTHROUGH or motion == actions.HANDLED then
         return motion
      elseif motion == actions.FOCUS_ON_BUTTONS then
         self.focus = #self.widgets
         return motion
      end
      if motion == actions.PREVIOUS then
         self.move_focus(-1)
      elseif motion == actions.NEXT then
         self.move_focus(1)
      end
   end
   for i, item in ipairs(self.widgets) do
      if item.widget.focusable then
         self.focus = i
         break
      end
   end
   while true do
      --stdscr:move(max_y-1,max_x-1)
      self.pad:attrset(colors.title)
      self.pad:mvaddstr(0, 0, self.title)
      self.pad:prefresh(0, 0, 1, 1, max_y-5, max_x-2)
      local y = 3
      for i, item in ipairs(self.widgets) do
         --process_key(stdscr:getch(), item.widget)
         if i == self.focus then
            self.pad:attrset(colors.title)
            self.pad:mvaddstr(y-1, 1, ">")
            self.pad:prefresh(0, 0, 1, 1, max_y-5, max_x-2)
         end
         item.widget:draw(stdscr, 4, y)
         y = y + item.widget.height + 1
      end
      local action = self.process_key(stdscr:getch())
      -- TODO process key
   end
   -- done_curses()
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
