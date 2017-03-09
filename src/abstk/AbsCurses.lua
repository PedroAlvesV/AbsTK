-------------------------------------------------
-- AbsCurses (text-mode) to AbsTK-Lua
-- 
-- @classmod AbsCurses
-- @author Pedro Alves
-- @license MIT
-- @see abstk
-------------------------------------------------

-- fix bbox starting subfocus (when first button is disabled)

local AbsCurses = {}

local curses = require 'curses' -- http://www.pjb.com.au/comp/lua/lcurses.html
-- https://github.com/jballanc/playgo/blob/master/doc/curses-examples/lcurses-test.lua
-- http://invisible-island.net/ncurses/man/ncurses.3x.html
-- https://lcurses.github.io/lcurses/modules/curses.html
-- https://www.ibm.com/support/knowledgecenter/ssw_aix_61/com.ibm.aix.basetrf2/newpad.htm

local util = require 'abstk.util'

local Screen = {}
local Wizard = {}

local AbsCursesLabel = {}
local AbsCursesButton = {}
local AbsCursesButtonBox = {}
local AbsCursesTextInput = {}
local AbsCursesTextBox = {}
local AbsCursesCheckBox = {}
local AbsCursesCheckList = {}
local AbsCursesSelector = {}

local stdscr
local scr_w, scr_h
local colors = {}
local ASSIST_BUTTONS, NAV_BUTTONS = {}, {}
local actions = {
   PASSTHROUGH = 0,
   HANDLED = -2,
   PREVIOUS = -1,
   NEXT = 1,
}
local keys = {
   TAB = 9,
   ENTER = 13,
   ESC = 27,
   SPACE = 32,
   DOWN = 258,
   UP = 259,
   LEFT = 260,
   RIGHT = 261,
   HOME = 262,
   END = 360,
   PAGE_DOWN = 338,
   PAGE_UP = 339,
}
local buttons = {
   PREVIOUS = 0,
   NEXT = 1,
   QUIT = 2,
   LAST = 2,
}

local function attr_code(attr)
   local ch = curses.new_chstr(1)
   ch:set_str(0, " ", attr)
   local c, code = ch:get(0)
   return code
end

local function draw_scrollbar(drawable, x, y, h_box, h_data, current_line)
   drawable:attrset(colors.default)
   for i=1, h_box do
      drawable:mvaddstr(y+i, x, " ")
   end
   local h_scroll = h_box - 2
   local n_scroll = h_data - h_box + 1  
   local bar_h = math.ceil( (h_scroll / n_scroll) )
   local bar_y = math.ceil( (h_scroll / n_scroll) * current_line )
   drawable:attrset(colors.button)
   drawable:mvaddstr(y+1, x, '^')
   for i=0, bar_h-1 do
      drawable:mvaddstr(y+bar_y-i+1, x, " ")
   end
   drawable:mvaddstr(y+h_box, x, 'v')
end

local function run_callback(self, ...)
   if self.callback then
      self.callback(self.id, ...)
   end
end

function AbsCurses.new_screen(title)
   local self = {
      title = title,
      widgets = {},
      focus = 1,
   }
   local mt = {
      __index = Screen,
   }
   setmetatable(self, mt)
   return self
end

function AbsCurses.new_wizard(title)
   local self = {
      title = title,
      pages = {},
      current_page = 1,
      nav_buttons = {},
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

function AbsCursesLabel:process_key(key)
   if key == keys.TAB or key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function AbsCursesButton.new(label, tooltip, callback)
   local self = {
      height = 1,
      label = label,
      focusable = true,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   return setmetatable(self, { __index = AbsCursesButton })
end

function AbsCursesButton:draw(drawable, x, y, focus)
   if self.focusable then
      drawable:attrset(colors.button)
   else
      drawable:attrset(colors.widget_disabled)
   end
   local label = " "..self.label.." "
   drawable:mvaddstr(y, x+1, label)
   local left, right = " ", " "
   if focus then
      left, right = ">", "<"
   end
   drawable:attrset(colors.title)
   drawable:mvaddstr(y, x, left)
   drawable:mvaddstr(y, x+string.len(label)+1, right)
end

function AbsCursesButton:process_key(key, index)
   if key == keys.ENTER or key == keys.SPACE then
      if index then
         run_callback(self, index, self.label)
      else
         run_callback(self, self.label)
      end
   elseif key == keys.TAB or key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function AbsCursesButtonBox.new(labels, tooltips, callbacks)
   local buttons = {}
   local width = 0
   for i, label in ipairs(labels) do
      table.insert(buttons, AbsCursesButton.new(label, tooltips and tooltips[i], callbacks and callbacks[i]))
      width = width + utf8.len(label) + 5
   end
   local self = {
      height = 1,
      width = width,
      buttons = buttons,
      focusable = true,
      subfocus = 1,
      enabled = true,
      tooltip = "",
   }
   return setmetatable(self, { __index = AbsCursesButtonBox })
end

function AbsCursesButtonBox:draw(drawable, x, y, focus)
   for i, button in ipairs(self.buttons) do
      button:draw(drawable, x, y, focus and i == self.subfocus)
      x = x + utf8.len(button.label) + 5
   end
end

function AbsCursesButtonBox:process_key(key)
   local function move_focus(direction)
      local button = self.buttons[self.subfocus]
      local next_focus = self.subfocus + direction
      while true do
         if next_focus < 1 or next_focus > #self.buttons then
            if next_focus < 1 then
               return actions.PREVIOUS
            else
               return actions.NEXT
            end
         end
         if self.buttons[next_focus].focusable then
            break
         end
         next_focus = next_focus + direction
      end
      self.subfocus = next_focus
      return actions.HANDLED
   end
   if key == keys.LEFT then
      return move_focus(-1)
   elseif key == keys.RIGHT then
      return move_focus(1)
   end
   return self.buttons[self.subfocus]:process_key(key, self.subfocus)
end

function AbsCursesTextInput.new(label, visibility, default_value, tooltip, callback)
   local self = {
      height = 1,
      focusable = true,
      label = label or " ",
      visibility = visibility,
      text = default_value or "",
      hidden_text_start = "",
      hidden_text_end = "",
      cursor = 0,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   self.cursor = utf8.len(self.label) + utf8.len(self.text) + 5
   return setmetatable(self, { __index = AbsCursesTextInput })
end

function AbsCursesTextInput:draw(drawable, x, y, focus)
   self.field_limit = scr_w - 6
   self.max_text = self.field_limit - utf8.len(self.label) - 3
   if utf8.len(self.text) > self.field_limit then
      self.hidden_text_start = self.text:sub(1, self.field_limit-utf8.len(self.text)) -- MUST FIX
      self.text = self.text:sub( -(utf8.len(self.hidden_text_start)) )
   end
   if self.focusable then
      drawable:attrset(colors.widget)
   else
      drawable:attrset(colors.widget_disabled)
   end
   local gap = utf8.len(self.label) + 5
   local iter = gap
   while iter < scr_w-5 do
      drawable:mvaddstr(y, iter, " ")
      iter = iter + 1
   end
   local placeholder = ""
   if self.visibility then
      placeholder = self.text or ""
   else
      for i=1, utf8.len(self.text or "") do
         placeholder = placeholder.."*"
      end
   end
   drawable:mvaddstr(y, gap, placeholder)
   if focus then
      drawable:attrset(colors.cursor)
      local ch_pos_x = self.cursor-utf8.len(self.label)-utf8.len(self.text)-5
      if self.visibility then
         drawable:mvaddstr(y, self.cursor, string.sub(self.text, ch_pos_x, ch_pos_x))
      else
         drawable:mvaddstr(y, self.cursor, "*")
      end
      if ch_pos_x == 0 then
         drawable:mvaddstr(y, self.cursor, " ")
      end
      drawable:attrset(colors.subcurrent)
   else
      drawable:attrset(colors.default)
   end
   local title = self.label.." ".."["
   if self.label == "" then
      title = "["
   end
   drawable:mvaddstr(y, x, title)
   drawable:mvaddstr(y, iter, "]")
end

function AbsCursesTextInput:process_key(key)
   local first_position = utf8.len(self.label) + 5
   local last_position = first_position + utf8.len(self.text)
   local has_hidden_text_at_start = utf8.len(self.hidden_text_start) > 0
   local has_hidden_text_at_end = utf8.len(self.hidden_text_end) > 0
   local function bring_char()
      if has_hidden_text_at_end then
         self.text = self.text..self.hidden_text_end:sub(1,1)
         self.hidden_text_end = self.hidden_text_end:sub(2)
      end
   end
   if utf8.len(self.text) >= self.max_text-1 then
      last_position = last_position - 1
   end
   if key == keys.LEFT then
      if self.cursor > first_position then
         self.cursor = self.cursor - 1
      elseif has_hidden_text_at_start then
         local iter = 0
         while utf8.len(self.text) < self.max_text-1 do
            self.text = self.hidden_text_start:sub(-iter)..self.text
            iter = iter + 1
         end
         self.hidden_text_end = self.text:sub(-1)..self.hidden_text_end
         self.text = self.text:sub(1,-2)
         self.text = self.hidden_text_start:sub(-1)..self.text
         self.hidden_text_start = self.hidden_text_start:sub(1,-2)
      end
      return actions.HANDLED
   elseif key == keys.RIGHT then
      if self.cursor < last_position then
         self.cursor = self.cursor + 1
      elseif utf8.len(self.text) >= self.max_text-1 then
         self.hidden_text_start = self.hidden_text_start..self.text:sub(1,1)
         self.text = self.text:sub(2)
         bring_char()
      end
      return actions.HANDLED
   elseif key == keys.TAB or key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   elseif key == keys.HOME then
      self.cursor = first_position
      return actions.HANDLED
   elseif key == keys.END then
      self.cursor = last_position
      return actions.HANDLED
   elseif key == keys.PAGE_UP or key == keys.PAGE_DOWN then
      return actions.PASSTHROUGH
   elseif key >= 32 and key <= 382 then
      local pos_x = self.cursor-utf8.len(self.label)-utf8.len(self.text)-5
      if key == curses.KEY_BACKSPACE then
         if self.cursor == first_position then
            if has_hidden_text_at_start then
               self.hidden_text_start = self.hidden_text_start:sub(1,-2)
            end
         else
            if self.cursor == last_position then
               self.text = self.text:sub(1,-2)
               bring_char()
            else
               self.text = self.text:sub(1, pos_x-2)..self.text:sub(pos_x)
               bring_char()
            end
            self.cursor = self.cursor-1
         end
         run_callback(self, self.text)
         return actions.HANDLED
      elseif key == curses.KEY_DC then
         if self.cursor < last_position then
            if self.cursor == last_position - 1 then
               self.text = self.text:sub(1,-2)
            else
               self.text = self.text:sub(1, pos_x-1)..self.text:sub(pos_x+1)
            end
            bring_char()
         end
         run_callback(self, self.text)
         return actions.HANDLED
      else
         if self.cursor == last_position then
            self.text = self.text..string.char(key)
            self.cursor = self.cursor + 1
            if self.cursor > self.field_limit then
               self.cursor = self.cursor - 1
               self.hidden_text_start = self.hidden_text_start..self.text:sub(1,1)
               self.text = self.text:sub(2)
            end
         else
            self.text = self.text:sub(1, pos_x-1)..string.char(key)..self.text:sub(pos_x)
            if utf8.len(self.text) >= self.max_text then
               self.hidden_text_end = self.text:sub(-1)..self.hidden_text_end
               self.text = self.text:sub(1,-2)
            end
         end
         run_callback(self, self.text)
         return actions.HANDLED
      end
   end
   return actions.PASSTHROUGH
end

function AbsCursesTextBox.new(title, default_value, tooltip, callback)
   local self = {
      height = 12,
      width = 0,
      view_pos = 1,
      title = title,
      focusable = true,
      inside = false,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   if type(title) == 'string' then
      self.height = self.height + 1
   end
   self.text, self.text_height = "", 0
   if default_value then
      self.text = {}
      for line in default_value:gmatch("[^\n]*") do
         table.insert(self.text, line)
      end
   end
   return setmetatable(self, { __index = AbsCursesTextBox })
end

function AbsCursesTextBox:draw(drawable, x, y, focus)
   self.width = scr_w-5
   self.inside_box_h = self.height - 2
   if type(self.title) == 'string' then
      self.inside_box_h = self.inside_box_h - 1
   end
   local function title_colors()
      if focus then
         return colors.current
      end
      return colors.default
   end
   local function box_colors()
      if self.inside then
         return colors.widget
      end
      return colors.default
   end
   if self.title then
      drawable:attrset(title_colors())
      drawable:mvaddstr(y, x, self.title)
      y = y + 1
   end
   local pad = curses.newpad(self.inside_box_h+2, self.width-2)
   pad:wbkgd(attr_code(box_colors()))
   for i=self.view_pos, self.view_pos + self.height - 1 do
      pad:mvaddstr(i-self.view_pos+1, 1, self.text[i] or "")
   end
   pad:attrset(colors.default)
   pad:border(0,0)
   pad:copywin(drawable, 0, 0, y, x, y+self.inside_box_h+1, self.width, false)
   if self.inside and #self.text > self.inside_box_h then
      draw_scrollbar(drawable, self.width, y, self.inside_box_h, #self.text, self.view_pos)
   end
end

function AbsCursesTextBox:process_key(key)
   if key == keys.ENTER then
      self.inside = not self.inside
      return actions.HANDLED
   elseif key == keys.ESC then -- must fix delay
      self.inside = false
      return actions.HANDLED
   elseif key == keys.TAB then
      self.inside = false
      return actions.NEXT
   elseif key == keys.DOWN then
      if self.inside and #self.text > self.inside_box_h then
         if self.view_pos <= #self.text - self.inside_box_h then
            self.view_pos = self.view_pos + 1
         end
         return actions.HANDLED
      end
      self.inside = false
      return actions.NEXT
   elseif key == keys.UP then
      if self.inside and #self.text > self.inside_box_h then
         if self.view_pos > 1 then
            self.view_pos = self.view_pos - 1
         end
         return actions.HANDLED
      end
      self.inside = false
      return actions.PREVIOUS
   elseif key == keys.PAGE_DOWN then
      if self.inside and #self.text > self.inside_box_h then
         if self.view_pos <= #self.text - self.inside_box_h then
            local temp_vpos = self.view_pos + 5
            if temp_vpos > #self.text - self.inside_box_h then
               self.view_pos = #self.text - self.inside_box_h + 1
            else
               self.view_pos = temp_vpos
            end
         end
         return actions.HANDLED
      end
   elseif key == keys.PAGE_UP then
      if self.inside and #self.text > self.inside_box_h then
         if self.view_pos > 1 then
            local temp_vpos = self.view_pos - 5
            if temp_vpos < 1 then
               self.view_pos = 1
            else
               self.view_pos = temp_vpos
            end
         end
         return actions.HANDLED
      end
   elseif key == keys.HOME then
      if self.inside then
         self.view_pos = 1
         return actions.HANDLED
      end
   elseif key == keys.END then
      if self.inside then
         self.view_pos = #self.text - self.inside_box_h + 1
         return actions.HANDLED
      end
   end
   return actions.PASSTHROUGH
end

function AbsCursesCheckBox.new(label, default_value, tooltip, callback)
   local self = {
      height = 1,
      label = label,
      state = default_value or false,
      focusable = true,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   return setmetatable(self, { __index = AbsCursesCheckBox })
end

function AbsCursesCheckBox:draw(drawable, x, y, focus)
   if not focus then
      if self.focusable then
         drawable:attrset(colors.default)
      else
         drawable:attrset(colors.widget_disabled)
      end
   else
      if type(focus) == 'table' then
         if focus[1] then
            drawable:attrset(colors.current)
         end
         if focus[2] then
            drawable:attrset(colors.subcurrent)
         end
      else
         drawable:attrset(colors.subcurrent)
      end
   end
   local mark = " "
   if self.state then
      mark = "x"
   end
   drawable:mvaddstr(y, x, "["..mark.."] "..self.label)
end

function AbsCursesCheckBox:process_key(key, index)
   if key == keys.ENTER or key == keys.SPACE then
      self.state = not self.state
      if index then
         run_callback(self, index, self.state, self.label)
      else
         run_callback(self, self.state, self.label)
      end
   elseif key == keys.TAB then
      return actions.NEXT
   elseif key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function AbsCursesCheckList.new(title, list, default_value, tooltip, callback)
   local function make_item(i, label, value)
      return AbsCursesCheckBox.new(label, value, tooltip, callback)
   end
   local checklist = util.make_list_items(make_item, list, default_value)
   local self = {
      height = #checklist+1,
      checklist = checklist,
      focusable = true,
      subfocus = 1,
      view_pos = 1,
      visible = 5,
      title = title,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   if self.height > self.visible then
      self.height = self.visible + 1
      self.scrollable = true
   end
   return setmetatable(self, { __index = AbsCursesCheckList })
end

function AbsCursesCheckList:draw(drawable, x, y, focus)
   self.width = scr_w-8
   if focus then
      drawable:attrset(colors.current)
   else
      if self.focusable then
         drawable:attrset(colors.default)
      else
         drawable:attrset(colors.widget_disabled)
      end
   end
   drawable:mvaddstr(y, x, self.title)
   for i=self.view_pos, #self.checklist do
      local attr = false
      if focus then
         if i == self.subfocus then
            attr = {true, true}
         else
            attr = {true, false}
         end
      end
      if i < self.view_pos + self.visible then
         self.checklist[i]:draw(drawable, x, y+i-self.view_pos+1, attr)
      end
   end
   if #self.checklist > self.visible then
      draw_scrollbar(drawable, self.width+3, y, self.visible, #self.checklist, self.view_pos)
   end
end

function AbsCursesCheckList:process_key(key)
   if key == keys.DOWN then
      if self.subfocus < #self.checklist then
         self.subfocus = self.subfocus + 1
         if self.scrollable and self.subfocus - self.view_pos + 1 == self.visible + 1 then
            self.view_pos = self.view_pos + 1
         end
         return actions.HANDLED
      elseif self.subfocus == #self.checklist then
         return actions.NEXT
      end
   elseif key == keys.UP then
      if self.subfocus > 1 then
         self.subfocus = self.subfocus - 1
         if self.scrollable and self.subfocus == self.view_pos - 1 then
            self.view_pos = self.view_pos - 1
         end
         return actions.HANDLED
      elseif self.subfocus == 1 then
         return actions.PREVIOUS
      end
   else
      return self.checklist[self.subfocus]:process_key(key, self.subfocus)
   end
end

function AbsCursesSelector.new(title, list, default_value, tooltip, callback)
   local function make_item(i, label, value)
      if value then
         default_value = i
      end
      return label
   end
   local items = util.make_list_items(make_item, list, default_value)
   local self = {
      height = #items+1,
      list = items,
      focusable = true,
      subfocus = 1,
      view_pos = 1,
      visible = 5,
      title = title,
      marked = default_value or 1,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   if self.height > self.visible then
      self.height = self.visible + 1
      self.scrollable = true
   end
   return setmetatable(self, { __index = AbsCursesSelector })
end

function AbsCursesSelector:draw(drawable, x, y, focus)
   self.width = scr_w-8
   if focus then
      drawable:attrset(colors.current)
   else
      if self.focusable then
         drawable:attrset(colors.default)
      else
         drawable:attrset(colors.widget_disabled)
      end
   end
   drawable:mvaddstr(y, x, self.title)
   for i=self.view_pos, #self.list do
      if focus then
         if i == self.subfocus then
            drawable:attrset(colors.subcurrent)
         else
            drawable:attrset(colors.current)
         end
      else
         drawable:attrset(colors.default)
      end
      local mark = " "
      if i == self.marked then
         mark = "*"
      end
      if i < self.view_pos + self.visible then
         drawable:mvaddstr(y+i-self.view_pos+1, x, "("..mark..") "..self.list[i])
      end
   end
   if #self.list > self.visible then
      draw_scrollbar(drawable, self.width+3, y, self.visible, #self.list, self.view_pos)
   end
end

function AbsCursesSelector:process_key(key)
   if key == keys.ENTER or key == keys.SPACE then
      if self.marked ~= self.subfocus then
         self.marked = self.subfocus
         run_callback(self, self.marked, self.list[self.marked])
      end
   elseif key == keys.TAB then
      return actions.NEXT
   elseif key == keys.DOWN then
      if self.subfocus < #self.list then
         self.subfocus = self.subfocus + 1
         if self.scrollable and self.subfocus - self.view_pos + 1 == self.visible + 1 then
            self.view_pos = self.view_pos + 1
         end
         return actions.HANDLED
      elseif self.subfocus == #self.list then
         return actions.NEXT
      end
   elseif key == keys.UP then
      if self.subfocus > 1 then
         self.subfocus = self.subfocus - 1
         if self.scrollable and self.subfocus == self.view_pos - 1 then
            self.view_pos = self.view_pos - 1
         end
         return actions.HANDLED
      elseif self.subfocus == 1 then
         return actions.PREVIOUS
      end
   end
   return actions.PASSTHROUGH
end

local function create_widget(self, type_name, class, id, ...)
   local item = {
      id = id,
      type = type_name,
      widget = class.new(...),
   }
   item.widget.id = id
   table.insert(self.widgets, item)
   return item.widget
end

function Screen:add_label(id, label)
   create_widget(self, 'LABEL', AbsCursesLabel, id, label)
end

function Screen:add_button(id, label, tooltip, callback)
   create_widget(self, 'BUTTON', AbsCursesButton, id, label, tooltip, callback)
end

function Screen:create_button_box(id, labels, tooltips, callbacks)
   local widget = create_widget(self, 'BUTTON_BOX', AbsCursesButtonBox, id, labels, tooltips, callbacks)
   for _, button in ipairs(widget.buttons) do
      button.id = id
   end
end

function Screen:create_combobox(id, title, labels, default_value, tooltip, callback)
   create_widget(self, 'SELECTOR', AbsCursesSelector, id, title, labels, default_value, tooltip, callback)
end

function Screen:add_image(id, path, dimensions, tooltip)
   return nil
end

function Screen:add_text_input(id, label, visibility, default_value, tooltip, callback)
   create_widget(self, 'TEXT_INPUT', AbsCursesTextInput, id, label, visibility, default_value, tooltip, callback)
end

function Screen:add_textbox(id, title, default_value, tooltip, callback)
   create_widget(self, 'TEXTBOX', AbsCursesTextBox, id, title, default_value, tooltip, callback)
end

function Screen:add_checkbox(id, label, default_value, tooltip, callback)
   create_widget(self, 'CHECKBOX', AbsCursesCheckBox, id, label, default_value, tooltip, callback)
end

function Screen:create_checklist(id, title, list, default_value, tooltip, callback)
   local widget = create_widget(self, 'CHECKLIST', AbsCursesCheckList, id, title, list, default_value, tooltip, callback)
   for _, checkbox in ipairs(widget.checklist) do
      checkbox.id = id
   end
end

function Screen:create_selector(id, title, list, default_value, tooltip, callback)
   create_widget(self, 'SELECTOR', AbsCursesSelector, id, title, list, default_value, tooltip, callback)
end

function Screen:show_message_box(message, buttons)
   local buttonset
   if buttons == 'OK' or not buttons then
      buttonset = {"Ok"}
   elseif buttons == 'CLOSE' then
      buttonset = {"Close"}
   elseif buttons == 'YES_NO' then
      buttonset = {"Yes", "No"}
   elseif buttons == 'OK_CANCEL' then
      buttonset = {"Ok", "Cancel"}
   else
      error('Invalid argument "'..buttons..'"')
   end
   local msgbox = {
      id = id,
      message = message,
      buttonset = buttonset,
   }
   local height, width = math.floor(scr_h/3), math.floor(scr_w/1.25)
   local y, x = math.floor(scr_h/3), math.floor(scr_w/10)
   local pad = curses.newpad(height, width)
   pad:wbkgd(colors.default)
   pad:attrset(colors.widget)
   pad:border(0,0)
   pad:attrset(colors.title)
   pad:mvaddstr(2, 1, msgbox.message or "")
   pad:copywin(stdscr, 0, 0, y, x, y+height-1, x+width-1, false)
end

function Screen:set_enabled(id, bool, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         local widget = item.widget
         if item.type == 'BUTTON_BOX' then
            widget = widget.buttons[index]
         end
         if item.type ~= 'LABEL' then
            widget.focusable = bool
         end
      end
   end
end

function Screen:set_value(id, value, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' or item.type == 'BUTTON' then
            item.widget.label = value
         elseif item.type == 'BUTTON_BOX' then
            item.widget.buttons[index].label = " "..value.." "
         elseif item.type == 'IMAGE' then
            return nil
         elseif item.type == 'TEXT_INPUT' then
            local entry = item.widget
            entry.text = value
            entry.hidden_text_start = ""
            entry.hidden_text_end = ""
            entry.cursor = utf8.len(entry.label) + utf8.len(entry.text) + 6
         elseif item.type == 'TEXTBOX' then
            local textbox = item.widget
            textbox.text = {}
            for line in value:gmatch("[^\n]*") do
               table.insert(textbox.text, line)
            end
         elseif item.type == 'CHECKBOX' then
            item.widget.state = value
         elseif item.type == 'CHECKLIST' then
            item.widget.checklist[index].state = value
         elseif item.type == 'SELECTOR' then
            item.widget.marked = value
         end
      end
   end
end

function Screen:get_value(id, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' then
            return item.widget.label
         elseif item.type == 'BUTTON' or item.type == 'BUTTON_BOX' then
            local label = item.widget.label
            if item.type == 'BUTTON_BOX' then
               label = item.widget.buttons[index].label
            end
            return label
         elseif item.type == 'IMAGE' then
            return nil
         elseif item.type == 'TEXT_INPUT' then
            local entry = item.widget
            local text = entry.hidden_text_start..entry.text..entry.hidden_text_end
            return text
         elseif item.type == 'TEXTBOX' then
            local textbox = item.widget
            local text = ""
            for _, line in ipairs(textbox.text) do
               text = text..line.."\n"
            end
            return text
         elseif item.type == 'CHECKBOX' then
            return item.widget.label, item.widget.state
         elseif item.type == 'CHECKLIST' then
            return item.widget.checklist[index].label, item.widget.checklist[index].state
         elseif item.type == 'SELECTOR' then
            local list = item.widget.list
            for i, button in ipairs(list) do
               if i == item.widget.marked then
                  return button
               end
            end
         end
      end
   end
end

local function run_screen(screen, pad, wizard_title)
   local function scroll_screen(item)
      local widget = item.widget
      if item.y > pad.min and item.y <= pad.max then
         if item.y + widget.height - 1 > pad.max then
            pad.min = pad.min + (item.y + widget.height - pad.max)
         end
      else
         if item.y < pad.min then
            pad.min = item.y - 1
         else
            pad.min = item.y + widget.height - pad.viewport_h + 1
         end
      end
      pad.max = pad.min + pad.viewport_h - 1
      if pad.total_h > pad.viewport_h then
         draw_scrollbar(stdscr, scr_w-1, 1, pad.viewport_h-1, pad.total_h-1, pad.min)
      end
   end
   local function process_key(key, item)
      local function move_focus(direction)
         local widget = screen.widgets[screen.focus].widget
         local next_focus = screen.focus + direction
         if next_focus > 0 and next_focus <= #screen.widgets then
            screen.focus = next_focus
         end
         return actions.HANDLED
      end
      local widget = item.widget
      local motion = widget:process_key(key)
      if motion == actions.PASSTHROUGH then
         if key == keys.LEFT or key == keys.RIGHT then
            screen.focus = #screen.widgets
         end
         if pad.total_h > pad.viewport_h then
            if key == keys.HOME then
               pad.min = 1
               scroll_screen(item)
            elseif key == keys.END then
               pad.min = pad.last_pos
            end
         end
         return motion
      end
      if motion == actions.PREVIOUS then
         move_focus(-1)
      elseif motion == actions.NEXT then
         move_focus(1)
      end
   end
   local function clear_tooltip_bar()
      stdscr:attrset(colors.widget)
      for i=0,scr_w-1 do
         stdscr:mvaddstr(scr_h-1, i, " ")
      end
   end
   stdscr:attrset(colors.title)
   local title = screen.title
   if wizard_title then
      title = wizard_title.." - "..title
   end
   stdscr:mvaddstr(1, 1, title)
   for i, item in ipairs(screen.widgets) do
      local arrow = " "
      if i == screen.focus then
         if type(item.widget.tooltip) == 'string' then
            local tooltip = item.widget.tooltip
            if item.type == 'BUTTON_BOX' then
               local j = 1
               while j < item.widget.subfocus do
                  j = j + 1
               end
               tooltip = item.widget.buttons[j].tooltip or ""
            end
            while utf8.len(tooltip) < scr_w do
               tooltip = tooltip.." "
            end
            stdscr:attrset(colors.widget)
            stdscr:mvaddstr(scr_h-1, 0, tooltip)
         else
            clear_tooltip_bar()
         end
         arrow = ">"
         if item.id ~= ASSIST_BUTTONS then
            scroll_screen(item)
         end
      end
      if item.widget.focusable then
         screen.pad:attrset(colors.title)
      else
         screen.pad:attrset(colors.default)
      end
      if item.id == NAV_BUTTONS or item.id == ASSIST_BUTTONS then
         item.widget:draw(stdscr, scr_w-item.widget.width-1, scr_h-3, i == screen.focus)
      else
         screen.pad:mvaddstr(item.y, 1, arrow)
         item.widget:draw(screen.pad, 3, item.y, i == screen.focus)
      end
      screen.pad:prefresh(pad.min, 0, 2, 1, pad.viewport_h, scr_w-2)
   end
   --screen.pad:clear()
   stdscr:move(scr_h-1,scr_w-1)
   process_key(stdscr:getch(), screen.widgets[screen.focus])
end

local function create_pad(screen)
   local function calculate_pad_h()
      local y = 2
      for i, item in ipairs(screen.widgets) do
         item.y = y
         y = y + item.widget.height + 1
      end
      return y-1
   end
   local pad_data = {
      viewport_h = scr_h-5,
      min = 1,
   }
   pad_data.total_h = calculate_pad_h()
   pad_data.max = pad_data.min + pad_data.viewport_h - 1
   pad_data.last_pos = pad_data.total_h - pad_data.viewport_h + 2
   local actual_pad = curses.newpad(pad_data.total_h, scr_w-2)
   return pad_data, actual_pad
end

local function setup_screen(screen)
   local function init_curses()
      local stdscr = curses.initscr()
      curses.cbreak()
      curses.echo(false)
      curses.nl(false)
      stdscr:keypad(true)
      scr_h, scr_w = stdscr:getmaxyx()
      scr_w = math.min(scr_w, 127)
      -- scr_h = math.min(scr_h, 24)
      curses.start_color()
      curses.use_default_colors()
      pcall(curses.init_pair, 1, curses.COLOR_WHITE, curses.COLOR_BLUE)
      pcall(curses.init_pair, 2, curses.COLOR_BLACK, curses.COLOR_BLUE)
      pcall(curses.init_pair, 3, curses.COLOR_YELLOW, curses.COLOR_BLUE)
      pcall(curses.init_pair, 4, curses.COLOR_BLACK, curses.COLOR_WHITE)
      pcall(curses.init_pair, 5, curses.COLOR_BLACK, curses.COLOR_CYAN)
      pcall(curses.init_pair, 6, curses.COLOR_CYAN, curses.COLOR_BLUE)
      pcall(curses.init_pair, 7, curses.COLOR_CYAN, curses.COLOR_BLACK)
      colors.default = curses.color_pair(1)
      colors.disabled = curses.color_pair(2) + curses.A_BOLD
      colors.title = curses.color_pair(3) + curses.A_BOLD
      colors.button = curses.color_pair(4)
      colors.widget = curses.color_pair(5)
      colors.widget_disabled = curses.color_pair(5) + curses.A_BOLD
      colors.current = curses.color_pair(1) + curses.A_BOLD
      colors.subcurrent = curses.color_pair(6) + curses.A_BOLD
      colors.cursor = curses.color_pair(7) + curses.A_BOLD
      stdscr:clear()
      stdscr:wbkgd(attr_code(colors.default))
      stdscr:attrset(colors.default)
      return stdscr
   end
   stdscr = init_curses()
   stdscr:sub(scr_h-1, scr_w, 0, 0):box(0, 0)
   stdscr:attrset(colors.default)
   stdscr:mvaddstr(scr_h-3, 2, "Tab: move focus   Enter: select")
   stdscr:refresh()
   screen.widgets[#screen.widgets].widget.subfocus = 1
   screen.focus = 1
   return screen
end

function Screen:run()
   local function create_assistant_buttons()
      local labels, tooltips, callbacks
      local quit_curses = function()
         self:show_message_box("Are you sure you want to quit?", 'YES_NO')
      end
      local done_curses = function()
         self:show_message_box("Press OK to proceed.", 'OK_CANCEL')
      end
      labels = {'Done', 'Quit'}
      tooltips = {"Done assistant", "Quit assistant"}
      callbacks = {done_curses, quit_curses}
      self:create_button_box(ASSIST_BUTTONS, labels, tooltips, callbacks)
   end
   self = setup_screen(self)
   local pad, actual_pad = create_pad(self)
   self.pad = actual_pad
   self.pad:wbkgd(attr_code(colors.default))
   create_assistant_buttons()
   while true do
      run_screen(self, pad)
   end
end

function Wizard:add_page(id, screen)
   local page = {
      id = id,
      title = screen.title,
      screen = screen,
   }
   table.insert(self.pages, page)
end

function Wizard:run()
   local function create_navigation_buttons(pages)
      local prev_page = function()
         self.current_page = self.current_page - 1
         setup_screen(self.pages[self.current_page].screen)
      end
      local next_page = function()
         self.current_page = self.current_page + 1
         setup_screen(self.pages[self.current_page].screen)
      end
      local quit_curses = function()
         self.pages[self.current_page].screen:show_message_box("Are you sure you want to quit?", 'YES_NO')
      end
      local done_curses = function()
         self.pages[self.current_page].screen:show_message_box("Press OK to proceed.", 'OK_CANCEL')
      end
      for page_number, page in ipairs(pages) do
         local labels, tooltips, callbacks
         if page_number == 1 then
            labels = {'Next >', 'Quit'}
            tooltips = {"Go to next page", "Quit wizard"}
            callbacks = {next_page, quit_curses}
         elseif page_number == #pages then
            labels = {'< Back', 'Done', 'Quit'}
            tooltips = {"Go to previous page", "Done wizard", "Quit wizard"}
            callbacks = {prev_page, done_curses, quit_curses}
         else
            labels = {'< Back', 'Next >', 'Quit'}
            tooltips = {"Go to previous page", "Go to next page", "Quit wizard"}
            callbacks = {prev_page, next_page, quit_curses}
         end
         page.screen:create_button_box(NAV_BUTTONS, labels, tooltips, callbacks)
      end
   end
   local current_screen = setup_screen(self.pages[self.current_page].screen)
   create_navigation_buttons(self.pages)
   while true do
      current_screen = self.pages[self.current_page].screen
      local pad, actual_pad = create_pad(current_screen)
      current_screen.pad = actual_pad
      current_screen.pad:wbkgd(attr_code(colors.default))
      run_screen(current_screen, pad, self.title)
   end
end

return AbsCurses
