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

return util