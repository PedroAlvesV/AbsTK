-------------------------------------------------
-- util functions to both AbsCurses and AbsGtk
-- 
-- @classmod util
-- @author Pedro Alves
-- @license MIT
-- @see AbsCurses
-- @see AbsGtk
-------------------------------------------------

local utf8

if _VERSION < "Lua 5.3" then
   local has_dep
   has_dep, utf8 = pcall(require, 'lua-utf8')
   if not has_dep then
      utf8 = { len = string.len }
   end
else
   utf8 = require 'utf8'
end

local util = {}

function util.make_list_items(make_item, list, default_value)
   local items = {}
   if type(list[1]) == "table" then
      for i, pair in ipairs(list) do
         local label, value = pair[1], pair[2]
         table.insert(items, make_item(i, label, value))
      end
   else
      for i, label in ipairs(list) do
         local value = false
         if type(default_value) == "table" then
            value = default_value[i] or false
         elseif type(default_value) == "number" then
            value = (i == default_value)
         end
         table.insert(items, make_item(i, label, value))
      end
   end
   return items
end

function util.append_blank_space(string, limit)
   while utf8.len(string) < limit do
      string = string.." "
   end
   return string
end

function util.collect_data(arg, iter_screen_items)
   if arg.widgets then
      return iter_screen_items(arg)
   else
      local data = {}
      for _, page in ipairs(arg.pages) do
         data[page.id] = iter_screen_items(page.screen)
      end
      return data
   end
end

function util.set_default_exit_callback(wizard)
   if not wizard.exit_callback then
      wizard.exit_callback = function(exit, data, screen)
         if exit == "QUIT" then
            return screen:show_message_box("Are you sure you want to quit?", 'YES_NO') == "YES"
         else
            return screen:show_message_box("Press OK to proceed.", 'OK_CANCEL') == "OK"
         end
      end
   end
end

function util.debug(debug_message)
   debug_message = tostring(debug_message)
   local file = io.open("debug.txt", 'w')
   file:write("\n"..debug_message.."\n")
   file:close()
end

return util
