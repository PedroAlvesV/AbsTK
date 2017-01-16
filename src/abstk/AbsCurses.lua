local AbsCurses = {}

-- FOCUS_ON_BUTTONS não existe mais como widget
-- Wizard trata botões e reaproveita button_box

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
   UP = 65,
   DOWN = 66,
   RIGHT = 67,
   LEFT = 68,
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

local function run_callback(self)
   if self.callback then
      self.callback()
   end
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

function AbsCursesButton.new(label, tooltip, callback)
   local self = {
      height = 1,
      label = " "..label.." ",
      focusable = true,
      tooltip = tooltip,
      callback = callback,
   }
   return setmetatable(self, { __index = AbsCursesButton })
end

function AbsCursesButton:draw(drawable, x, y, focus)
   drawable:attrset(colors.button)
   drawable:mvaddstr(y, x+1, self.label)
   local left, right = " ", " "
   if focus then
      left, right = ">", "<"
   end
   drawable:attrset(colors.title)
   drawable:mvaddstr(y, x, left)
   drawable:mvaddstr(y, x+string.len(self.label)+1, right)
end

function AbsCursesButton:process_key(key)
   if (key == keys.ENTER or key == keys.SPACE) and self.enabled then
      run_callback(self)
   elseif key == keys.LEFT or key == keys.RIGHT then
      return actions.FOCUS_ON_BUTTONS
   elseif key == keys.TAB or key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function AbsCursesButtonBox.new(labels, tooltips, callbacks)
   local buttons = {}
   for i, label in ipairs(labels) do
      table.insert(buttons, AbsCursesButton.new(label, tooltips and tooltips[i], callbacks and callbacks[i]))
   end
   local self = {
      height = 1,
      buttons = buttons,
      focusable = true,
      subfocus = 1,
   }
   return setmetatable(self, { __index = AbsCursesButtonBox })
end

function AbsCursesButtonBox:draw(drawable, x, y, focus)
   for i, button in ipairs(self.buttons) do
      button:draw(drawable, x, y, focus and i == self.subfocus)
      x = x + utf8.len(button.label) + 3
   end
end

function AbsCursesButtonBox:process_key(key)
   if key == keys.LEFT then
      if self.subfocus > 1 then
         self.subfocus = self.subfocus - 1
         return actions.HANDLED
      end
   elseif key == keys.RIGHT then
      if self.subfocus < #self.buttons then
         self.subfocus = self.subfocus + 1
         return actions.HANDLED
      end
   end
   return self.buttons[self.subfocus]:process_key(key)
end

local function create_widget(self, type_name, class, id, ...)
   local item = {
      id = id,
      type = type_name,
      widget = class.new(...),
   }
   table.insert(self.widgets, item)
end

function Screen:add_label(id, label)
   create_widget(self, 'LABEL', AbsCursesLabel, id, label)
end

function Screen:add_button(id, label, tooltip, callback)
   create_widget(self, 'BUTTON', AbsCursesButton, id, label, tooltip, callback)
end

function Screen:create_button_box(id, labels, tooltips, callbacks)
   create_widget(self, 'BUTTON_BOX', AbsCursesButtonBox, id, labels, tooltips, callbacks)
end

function Screen:create_combobox(id, labels, default_value, tooltip, callback)
   create_widget(self, 'COMBOBOX', AbsCursesComboBox, id, labels, default_value, tooltip, callback)
end

function Screen:add_image(id, path, dimensions, tooltip)
   return nil
end

function Screen:add_text_input(id, label, visibility, default_value, tooltip, callback)
   create_widget(self, 'TEXT_INPUT', AbsCursesTextInput, id, label, visibility, default_value, tooltip, callback)
end

function Screen:add_textbox(id, default_value, tooltip, callback)
   create_widget(self, 'TEXTBOX', AbsCursesTextBox, id, default_value, tooltip, callback)
end

function Screen:create_checklist(id, list, default_value, tooltip, callback)
   create_widget(self, 'CHECKLIST', AbsCursesCheckList, id, list, default_value, tooltip, callback)
end

function Screen:create_radiolist(id, list, default_value, tooltip, callback)
   create_widget(self, 'RADIOLIST', AbsCursesRadioList, id, list, default_value, tooltip, callback)
end

function Screen:create_list(id, list, tooltip, callback)
   create_widget(self, 'LIST', AbsCursesList, id, list, tooltip, callback)
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
   stdscr:attrset(colors.default)
   stdscr:mvaddstr(max_y-3, 2, "Tab: move focus   Enter: select")
   stdscr:refresh()
   local function move_focus(direction)
      local widget = self.widgets[self.focus].widget
      --widget.inside = False
      local gap = direction
      while self.focus > 0 and self.focus < #self.widgets and not self.widgets[self.focus + gap].widget.focusable do
         gap = gap + direction
      end
      self.focus = self.focus + gap
      if self.focus == -1 or self.focus > #self.widgets then
         return actions.FOCUS_ON_BUTTONS
      end
      --widget = self.__setupFocusAndCurrent(direction)
      if self.widgets[self.focus].widget.enabled then
         return actions.HANDLED
      end
   end
   local function process_key(key, widget)
      local motion = widget:process_key(key)
      if motion == actions.PASSTHROUGH or motion == actions.HANDLED then
         return motion
      elseif motion == actions.FOCUS_ON_BUTTONS then
         self.focus = #self.widgets + 1
         return motion
      end
      if motion == actions.PREVIOUS then
         move_focus(-1)
      elseif motion == actions.NEXT then
         move_focus(1)
      end
   end
   for i, item in ipairs(self.widgets) do
      if item.widget.focusable then
         self.focus = i
         break
      end
   end
   while true do
      self.pad:attrset(colors.title)
      self.pad:mvaddstr(0, 0, self.title)
      local y = 3
      for i, item in ipairs(self.widgets) do
         if i == self.focus then
            self.pad:attrset(colors.title)
            self.pad:mvaddstr(y-1, 1, ">")
         else
            self.pad:mvaddstr(y-1, 1, " ")
         end
         self.pad:prefresh(0, 0, 1, 1, max_y-5, max_x-2)
         item.widget:draw(stdscr, 4, y, i == self.focus)
         y = y + item.widget.height + 1
      end
      stdscr:move(max_y-1,max_x-1)
      process_key(stdscr:getch(), self.widgets[self.focus].widget)
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
