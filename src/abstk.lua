-------------------------------------------------
-- Main module to AbsTK-Lua
--
-- @module abstk
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local abstk = {}

local AbsGtk = require 'abstk.AbsGtk'
local AbsCurses = require 'abstk.AbsCurses'

local mode = nil

-------------------------------------------------
-- Sets mode to determine whether interface will be drawn,
-- text (curses) or GUI (GTK).
--
-- @within abstk
--
-- @param arg the mode
-------------------------------------------------
function abstk.set_mode(arg)
   if arg == 'curses' or arg == 'gtk' then
      mode = arg
   elseif os.getenv("DISPLAY") then
      mode = 'gtk'
   else
      mode = 'curses'
   end
end

-------------------------------------------------
-- Constructs a screen. 
--
-- @param title the title of the screen
-- @param w the width of the screen (only used in GUI)
-- @param h the height of the screen (only used in GUI)
--
-- @within abstk
--
-- @return 	a Screen table.
-------------------------------------------------
function abstk.new_screen(title, w, h)
   local obj
   if mode == 'gtk' then
      if w == nil then
         w = 400
      end
      if h == nil then
         h = w*0.75
      end
      obj = AbsGtk.new_screen(title, w, h)
   elseif mode == 'curses' then
      obj = AbsCurses.new_screen(title)
   end
   local self = {
      -------------------------------------------------
      -- @type Screen
      -------------------------------------------------

      -------------------------------------------------
      -- Adds a label to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param label the label itself that will be written 
      -------------------------------------------------
      add_label = function(self, id, label)
         obj:add_label(id, label)
      end,
      -------------------------------------------------
      -- Creates a button and adds it to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param label the label that will be written over the button
      -- @param[opt] tooltip a tooltip to the button
      -- @param[opt] callback a callback function to the button
      -------------------------------------------------
      add_button = function(self, id, label, tooltip, callback)
         obj:add_button(id, label, tooltip, callback)
      end,
      -------------------------------------------------
      -- Creates a buttonset and adds it to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param labels the labels that will be written over the buttons
      -- @param[opt] tooltip a tooltip to the buttons
      -- @param[opt] callback a callback function to the buttons
      -------------------------------------------------
      create_button_box = function(self, id, labels, tooltips, callbacks)
         obj:create_button_box(id, labels, tooltips, callbacks)
      end,
      -------------------------------------------------
      -- Creates a dropdown menu and adds it to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param labels the labels that will be written on the entries
      -- @param[opt='1'] default_value the index of the entry selected at start
      -- @param[opt] tooltip a tooltip to the combobox
      -- @param[opt] callback a callback function to the row
      -------------------------------------------------
      create_combobox = function(self, id, labels, default_value, tooltip, callback)
         obj:create_combobox(id, labels, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Creates an image widget and adds it to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param path the path of the image file
      -- @param[opt] dimensions a table with the dimensions to resize the image
      -- @param[opt] tooltip a tooltip to the image
      --
      -- @usage scr:add_image('lua_img', 'imgs/lua.png')
      -- scr:add_image('batman_img', 'imgs/batman.png', {512, 384})
      -------------------------------------------------
      add_image = function(self, id, path, dimensions, tooltip)
         obj:add_image(id, path, dimensions, tooltip)
      end,
      -------------------------------------------------
      -- Creates a text input field and adds it to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param[opt] label a label that precedes the field
      -- @param[opt] default_value a placeholder
      -- @param[opt] tooltip a tooltip to the text input field
      -- @param[opt] callback a callback function to the field
      -------------------------------------------------
      add_text_input = function(self, id, label, default_value, tooltip, callback)
         obj:add_text_input(id, label, true, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Creates a password input field and adds it to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param[opt] label a label that precedes the field
      -- @param[opt] default_value a placeholder
      -- @param[opt] tooltip a tooltip to the text input field
      -- @param[opt] callback a callback function to the field
      -------------------------------------------------
      add_password = function(self, id, label, default_value, tooltip, callback)
         obj:add_text_input(id, label, false, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Creates a textbox field and adds it to the screen widgets table.
      --
      -- @param id the id to reference the widget later on
      -- @param[opt] title a title to the field
      -- @param[opt] default_value a pre-written text
      -- @param[opt] tooltip a tooltip to the textbox field
      -- @param[opt] callback a callback function to the field
      -------------------------------------------------
      add_textbox = function(self, id, title, default_value, tooltip, callback)
         obj:add_textbox(id, title, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Creates a single checkbox and adds it to the screen widgets table.
      --
      -- @see Screen:create_checklist
      --
      -- @param id the id to reference the widget later on
      -- @param label the label of the checkbox
      -- @param[opt] default_value a boolean to determine the initial state of the checkbox
      -- @param[opt] tooltip a tooltip to the checkbox
      -- @param[opt] callback a callback function to the checkbox
      -------------------------------------------------
      add_checkbox = function(self, id, label, default_value, tooltip, callback)
         obj:add_checkbox(id, label, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- <p align="justify">
      -- Creates a checkboxes list and adds it to the screen widgets table. 
      -- There are 4 ways to call it via client. The first one is by passing 
      -- just an array with the labels as the `list` parameter. The second one 
      -- is similar, but you pass, also, an array of booleans, as 
      -- `default_value`, representing the states of those buttons. The third 
      -- one is an alternative to the second, since it's better readable: you 
      -- pass an array of tables. Each table represents a box and its state.
      -- Also, there's a fourth way of doing that. `default_value` can be just a
      -- single index to mark an item.
      -- </p>
      --
      -- @param id the id to reference the widget later on
      -- @param title the title of the group
      -- @param list an array with the labels or an array of tables holding paired 
      -- info.
      -- @param[opt] default_value a table containing the states of the boxes or the index to a single item
      -- @param[opt] tooltip a tooltip to the list
      -- @param[opt] callback a callback function to the boxes
      --
      -- @usage scr:create_checklist('style1', "Checklist 1:", {'a', 'b', 'c'}, nil, tooltip, chk_callback)
      --
      -- scr:create_checklist('style2', "Checklist 2:", {'7', '8', '9'}, {true, false, true}, tooltip, chk_callback)
      --
      -- local check_table = {
      --   {'z', false},
      --   {'x', true},
      --   {'c', true},
      -- }
      -- scr:create_checklist('style3', "Checklist 3:", check_table, nil, tooltip, chk_callback)
      -- scr:create_checklist('style4', "Checklist 4:", {'x', 'y', 'z'}, 3, tooltip, chk_callback)
      -------------------------------------------------
      create_checklist = function(self, id, title, list, default_value, tooltip, callback)
         obj:create_checklist(id, title, list, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- <p align="justify">
      -- Creates a radiobuttons list and adds it to the screen widgets table. Its 
      -- calling is very similar to checkboxes. There are 3 ways to do so. The 
      -- first one is by passing just an array with the labels as the 'list' 
      -- parameter. The second one is different from it's equivalent in 
      -- checkboxes, because radiobuttons can only be active one at the time. So, 
      -- the second way asks for a number — the index, more precisely —, as 
      -- 'default_value', to activate that button. The third one is actually 
      -- equal to it's equivalent in checkboxes.
      -- </p>
      --
      -- @see Screen:create_checklist
      --
      -- @param id the id to reference the widget later on
      -- @param title the title of the group
      -- @param list an array with the labels or an array of tables holding paired 
      -- info.
      -- @param[opt] default_value a index to refer the active button
      -- @param[opt] tooltip a tooltip to the list
      -- @param[opt] callback a callback function to the boxes
      --
      -- @usage scr:create_radiolist('style1', "Radiolist 1:", {'x', 'y', 'z'}, nil, tooltip, rd_callback)
      --
      -- scr:create_radiolist('style2', "Radiolist 2:", {'a', 's', 'd'}, 3, tooltip, rd_callback)
      --
      -- local radiolist_values = {
      --   {'q', false},
      --   {'w', true},
      --   {'e', false},
      -- }
      -- scr:create_radiolist('style3', "Radiolist 3:", radiolist_values, nil, tooltip, rd_callback)
      -------------------------------------------------
      create_radiolist = function(self, id, title, list, default_value, tooltip, callback)
         obj:create_radiolist(id, title, list, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- <p align="justify">
      -- Creates a list with checkbuttons attached and adds it to the screen 
      -- widgets table. There are two ways of calling it: it may explicit the state 
      -- of every single row or let all the checkbuttons unchecked. The first one 
      -- is actually identical to checkboxes 3th construction. The second one 
      -- consists in passing an array of the labels.
      -- </p>
      --
      -- @see Screen:create_checklist
      --
      -- @param id the id to reference the widget later on
      -- @param list an array with the labels or an array of tables holding paired 
      -- info.
      -- @param[opt] default_value a table containing the states of the boxes
      -- @param[opt] tooltip a tooltip to the list
      -- @param[opt] callback a callback function to the boxes
      --
      -- @usage local list = {
      --   { "Item1", false },
      --   { "Item2", true },
      --   { "Item3", false },
      --   { "Item4", false },
      --   { "Item5", false },
      --   { "Item6", false },
      --   { "Item7", false },
      --   { "Item8", false },
      --   { "Item9", false },
      -- }
      -- scr:create_list('style1', list , tooltip, list_callback)
      --
      -- scr:create_list('style2', {"Item10", "Item11", "Item12"} , tooltip, list_callback)
      -------------------------------------------------
      create_list = function(self, id, title, list, tooltip, callback)
         obj:create_list(id, title, list, tooltip, callback)
      end,
      -------------------------------------------------
      -- Creates and shows a message box. There are a few constants to determine 
      -- which buttonset is going to be used in a message box. Those are:
      --
      -- * `NONE` - no button at all
      -- * `OK` - an OK button
      -- * `CLOSE` - a Close button
      -- * `CANCEL` - a Cancel button
      -- * `YES_NO` - Yes and No buttons
      -- * `OK_CANCEL` - OK and Cancel buttons<p>
      --
      -- @param id the id to reference the object later on
      -- @param message the message that will be written over the new window
      -- @param[opt='NONE'] buttons an constant that determines which buttonset is 
      -- going to be used
      -------------------------------------------------
      show_message_box = function(self, id, message, buttons)
         obj:show_message_box(id, message, buttons)
      end,
      -------------------------------------------------
      -- Enable or disable an widget.
      --
      -- @param id the id of the required widget
      -- @param bool the boolean value representing if it wil enable or disable 
      -- the widget
      -- @param[opt] index an index to target the child button of a buttonbox
      -------------------------------------------------
      set_enabled = function(self, id, bool, ...)
         obj:set_enabled(id, bool, ...)
      end,
      -------------------------------------------------
      -- Sets a value to an widget. Each widget works with a type of value:
      --
      -- * `Label - string (label itself)`
      -- * `Button - string (button label)`
      -- * `ButtonBox - string (single button label)`
      -- * `ComboBox - string (entry to be set active)`
      -- * `Image - string (image path)`
      -- * `Text Input - string (text to be insert)`
      -- * `TextBox - string (text to be insert)`
      -- * `CheckList - boolean (state of button)`
      -- * `RadioList - boolean (state of button)`
      -- * `List - boolean (state of button)`
      --
      -- Note that, since RadioButtons can only be active one at the time per group,
      -- the value parameter passed is the index representing which one must be set active.
      --
      -- @param id the id of the required widget
      -- @param value the value that will be assigned to the widget. 
      -- @param[opt] index an index to target the child of the widget. Must be 
      -- passed to refer to set ButtonBoxes, ComboBoxes, CheckLists and Lists.
      --
      -- @usage scr:set_value('label', "New Label"
      -- scr:set_value('button', "New Button Label")
      -- scr:set_value('button_box', "New Button Label", 2)
      -- TODO combobox example
      -- scr:set_value('image', 'imgs/image.png')
      -- scr:set_value('text_input', "New Text")
      -- scr:set_value('password_input', "New Password")
      -- scr:set_value('textbox', "New Text")
      -- scr:set_value('checkbox', true)
      -- scr:set_value('checklist', true, 1)
      -- scr:set_value('radiolist', 2)
      -- scr:set_value('list', true, 3)
      -------------------------------------------------
      set_value = function(self, id, value, index)
         obj:set_value(id, value, index)
      end,
      -------------------------------------------------
      -- Gets the value of an widget.
      --
      -- @param id the id of the required widget
      -- @param[opt] index an index to target the child of the widget, if it
      -- has children
      --
      -- @return * `Label - a string (label itself)`
      -- * `Button - a string (button label)`
      -- * `Buttonbox - a string (single button label)`
      -- * `Combobox - a string (active entry)`
      -- * `Image - a string (image path)`
      -- * `Text input - a string (current text)`
      -- * `Textbox - a string (current text)`
      -- * `Checklist - a string and a boolean (label and state of button)`
      -- * `Radiolist - a string and a boolean (label and state of button)`
      -- * `List - a string and a boolean (label and state of button)`
      -------------------------------------------------
      get_value = function(self, id, index)
         return obj:get_value(id, index)
      end,
      -------------------------------------------------
      -- Runs a single screen. Doing so, presumes a single screen window. If it 
      -- needs more than a single screen, must set them all into a wizard and run 
      -- only the wizard.
      --
      -- @see Wizard:add_page
      -------------------------------------------------
      run = function(self)
         obj:run()
      end,
   }
   local mt = {
      __index = obj,
   }
   setmetatable(self, mt)
   return self
end

-------------------------------------------------
-- Constructs a wizard.
--
-- @param title the title of the window
-- @param w the width of the window (only used in GUI)
-- @param h the height of the window (only used in GUI)
--
-- @within abstk
--
-- @return  a Wizard table.
-------------------------------------------------
function abstk.new_wizard(title, w, h)
   local obj
   if mode == 'gtk' then
      if w == nil then
         w = 400
      end
      if h == nil then
         h = w*0.75
      end
      obj = AbsGtk.new_wizard(title, w, h)
   elseif mode == 'curses' then
      obj = AbsCurses.new_wizard(title)
   end
   local self = {
      -------------------------------------------------
      -- @type Wizard
      -------------------------------------------------

      -------------------------------------------------
      -- Adds a screen to a wizard. The screen turns into a whole page. There are a 
      -- few constants to determine which buttonset is going to be used in the 
      -- page. Those are:
      --
      -- * `CONTENT` - The page has regular contents.
      -- * `INTRO` - The page contains an introduction to the assistant task.
      -- * `CONFIRM` - The page lets the user confirm or deny the changes.
      -- * `SUMMARY` - The page informs the user of the changes done.
      -- * `PROGRESS` - Used for tasks that take a long time to complete, blocks 
      -- the assistant until the page is marked as complete.<p>
      --
      -- @param id the id to reference the screen later on
      -- @param screen the screen that will be added
      -- @param[opt] page_type a constant that determines which buttonset is 
      -- going to be used.
      -------------------------------------------------
      add_page = function(self, id, screen, page_type)
         obj:add_page(id, screen, page_type)
      end,
      -------------------------------------------------
      -- Runs a wizard. Must be called in the end of the code, because depends 
      -- that all its pages have been set.
      --
      -- @see Wizard:add_page
      -------------------------------------------------
      run = function(self)
         obj:run()
      end,
   }
   return self
end

abstk.set_mode()

return abstk