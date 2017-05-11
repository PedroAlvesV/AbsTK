-------------------------------------------------
-- Main module to AbsTK
--
-- @module abstk
-- @author Pedro Alves
-- @license MIT
-------------------------------------------------

local abstk = {}

local AbsGtk
local AbsCurses

do
   local has_gtk, gtk_module = pcall(require,'abstk.AbsGtk')
   local has_curses, curses_module = pcall(require,'abstk.AbsCurses')
   if has_gtk then AbsGtk = gtk_module end
   if has_curses then AbsCurses = curses_module end
end

local mode = nil

-------------------------------------------------
-- Sets mode to determine whether UI will be drawn,
-- TUI (Curses) or GUI (GTK).
--
-- @within abstk
--
-- @param arg the mode
-------------------------------------------------
function abstk.set_mode(arg)
   if (arg == 'curses' and AbsCurses) or (arg == 'gtk' and AbsGtk) then
      mode = arg
   elseif os.getenv("DISPLAY") and AbsGtk then
      mode = 'gtk'
   else
      mode = 'curses'
   end
end

-------------------------------------------------
-- Constructs a Screen. 
--
-- @param title the title of the screen
-- @param w the width of the screen (only used in GUI)
-- @param h the height of the screen (only used in GUI)
--
-- @within abstk
--
-- @return 	a Screen.
-------------------------------------------------
function abstk.new_screen(title, w, h)
   local obj
   if mode == 'gtk' then
      if w == nil then
         w = 600
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
      -- Adds a label to screen.
      --
      -- @param id the id of the object
      -- @param label the text itself to be the label
      -------------------------------------------------
      add_label = function(self, id, label)
         obj:add_label(id, label)
      end,
      -------------------------------------------------
      -- Adds a button to screen.
      --
      -- @param id the id of the object
      -- @param label the label that will be written over the button
      -- @param[opt] tooltip a tooltip text for the button
      -- @param[opt] callback a callback function to the button. This callback 
      -- function receives two arguments: the id (string) and the label of the
      -- button (string).
      -------------------------------------------------
      add_button = function(self, id, label, tooltip, callback)
         obj:add_button(id, label, tooltip, callback)
      end,
      -------------------------------------------------
      -- Creates a buttonset and adds it to screen.
      --
      -- @param id the id of the object
      -- @param labels a table containing the labels that will be written over the buttons
      -- @param[opt] tooltips a table containing the tooltips texts for the buttons
      -- @param[opt] callbacks a table containing the callback functions to the buttons. Every
      -- function receives three arguments: the id (string), the index of the
      -- clicked button (number) and its label (string).
      -------------------------------------------------
      create_button_box = function(self, id, labels, tooltips, callbacks)
         obj:create_button_box(id, labels, tooltips, callbacks)
      end,
      -------------------------------------------------
      -- Creates a ComboBox and adds it to screen.
      -- On GUI it's a dropdown menu, on TUI turns into a Selector.
      --
      -- @see Screen:create_selector
      --
      -- @param id the id of the object
      -- @param title the title of the field
      -- @param labels a table containing the labels that will be the entries
      -- @param[opt=<code>1</code>] default_value the index of the entry selected by default
      -- @param[opt] tooltip a tooltip text for the object
      -- @param[opt] callback a callback function. This callback function receives three
      -- arguments: the id (string), the index of the clicked item (number) its label
      -- (string).
      -------------------------------------------------
      create_combobox = function(self, id, title, labels, default_value, tooltip, callback)
         obj:create_combobox(id, title, labels, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Adds an image widget to screen.
      -- Does nothing if running TUI.
      --
      -- @param id the id of the object
      -- @param path the path of the image file
      -- @param[opt] dimensions a table containing the dimensions to resize the image
      -- @param[opt] tooltip a tooltip text for the object
      --
      -- @usage scr:add_image('lua_img', 'images/lua.png')
      -- scr:add_image('batman_img', 'images/batman.png', {512, 384})
      -------------------------------------------------
      add_image = function(self, id, path, dimensions, tooltip)
         obj:add_image(id, path, dimensions, tooltip)
      end,
      -------------------------------------------------
      -- Adds a text input field to screen.
      --
      -- @param id the id of the object
      -- @param[opt] label a label that precedes the field
      -- @param[opt] default_value a placeholder
      -- @param[opt] tooltip a tooltip text for the object
      -- @param[opt] callback a callback function to the field. This callback 
      -- function receives two arguments: the id (string) and the text that is
      -- inside the field (string).
      -------------------------------------------------
      add_text_input = function(self, id, label, default_value, tooltip, callback)
         obj:add_text_input(id, label, true, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Adds a password input field to screen.
      -- It's essentially a text input that covers the text on the UI.
      --
      -- @see Screen:add_text_input
      --
      -- @param id the id of the object
      -- @param[opt] label a label that precedes the field
      -- @param[opt] default_value a placeholder
      -- @param[opt] tooltip a tooltip text for the object
      -- @param[opt] callback a callback function to the field. This callback 
      -- function receives two arguments: the id (string) and the text that is
      -- inside the field (string).
      -------------------------------------------------
      add_password = function(self, id, label, default_value, tooltip, callback)
         obj:add_text_input(id, label, false, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Adds a TextBox field to the screen.
      --
      -- @param id the id of the object
      -- @param[opt] title a title to the box
      -- @param[opt] default_value the text
      -- @param[opt] tooltip a tooltip text for the object
      -------------------------------------------------
      add_textbox = function(self, id, title, default_value, tooltip)
         obj:add_textbox(id, title, default_value, tooltip)
      end,
      -------------------------------------------------
      -- Adds a single checkbox to the screen.
      --
      -- @see Screen:create_checklist
      --
      -- @param id the id of the object
      -- @param label the label of the checkbox
      -- @param[opt] default_value a boolean to determine the default state of the checkbox
      -- @param[opt] tooltip a tooltip text for the object
      -- @param[opt] callback a callback function to the checkbox. This callback 
      -- function receives three arguments: the id (string), the state of the
      -- box (boolean) and its label (string).
      -------------------------------------------------
      add_checkbox = function(self, id, label, default_value, tooltip, callback)
         obj:add_checkbox(id, label, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- <p align="justify">
      -- Creates a checkboxes list and adds it to the screen. 
      -- There are 4 ways to call it. The first one is by passing just an array
      -- with the labels as the `list` parameter. The second one is similar, but
      -- you pass, also, an array of booleans, as `default_value`, representing the
      -- states of those buttons. The third one is an alternative to the second,
      -- since it's better readable: you pass an array of tables. Each table
      -- represents a box and its state. Also, there's a fourth way of doing that:
      -- `default_value` can be just a single index to mark an item.
      -- </p>
      --
      -- @see Screen:add_checkbox
      --
      -- @param id the id of the object
      -- @param title the title of the list
      -- @param list an array with the labels or an array of tables holding paired 
      -- info.
      -- @param[opt] default_value a table containing the states of the boxes or
      -- the index to a single item
      -- @param[opt] tooltip a tooltip text to the list
      -- @param[opt] callback a callback function to the boxes. This callback 
      -- function receives four arguments: the id (string), the index of the
      -- clicked checkbox (number), its index (number) and its label (string).
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
      -- Creates a list in which just one item can be selected at a time and adds
      -- it to the screen. Its calling is very similar to checkboxes. 
      -- There are 3 ways to do so. The first one is by passing just an array with 
      -- the labels as the `list` parameter. The second one is different from it's 
      -- equivalent in checkboxes, because selector items can only be active one at
      -- the time. So, the second way asks for a number — the index, more precisely 
      -- —, as `default_value`, to activate that button. The third one is actually 
      -- equal to it's equivalent in checkboxes (`list` being an array of tables).
      -- </p>
      --
      -- @see Screen:create_checklist
      --
      -- @param id the id of the object
      -- @param title the title of the list
      -- @param list an array with the labels or an array of tables holding paired 
      -- info.
      -- @param[opt] default_value a index to refer the active button
      -- @param[opt] tooltip a tooltip text to the list
      -- @param[opt] callback a callback function to the list. This callback 
      -- function receives three arguments: the id (string), the index of the
      -- clicked item (number) and its label (string).
      --
      -- @usage scr:create_selector('style1', "Selector 1:", {'x', 'y', 'z'}, nil, tooltip, slct_callback)
      --
      -- scr:create_selector('style2', "Selector 2:", {'a', 's', 'd'}, 3, tooltip, slct_callback)
      --
      -- local selector_values = {
      --   {'q', false},
      --   {'w', true},
      --   {'e', false},
      -- }
      -- scr:create_selector('style3', "Selector 3:", selector_values, nil, tooltip, slct_callback)
      -------------------------------------------------
      create_selector = function(self, id, title, list, default_value, tooltip, callback)
         obj:create_selector(id, title, list, default_value, tooltip, callback)
      end,
      -------------------------------------------------
      -- Shows a message box. There are a few constants to determine 
      -- which buttonset is going to be used in a message box. Those are:
      --
      -- * `OK` - an OK button
      -- * `CLOSE` - a Close button
      -- * `YES_NO` - Yes and No buttons
      -- * `OK_CANCEL` - OK and Cancel buttons
      --
      -- @param message the message that will be written over the message dialog
      -- @param[opt=<code>'OK'</code>] buttons an constant that determines which buttonset 
      -- is going to be used
      --
      -- @return usually, the clicked button label in uppercase. However, `CLOSE` button 
      -- returns "CANCEL".
      -------------------------------------------------
      show_message_box = function(self, message, buttons)
         return obj:show_message_box(message, buttons)
      end,
      -------------------------------------------------
      -- Enables or disables a widget.
      --
      -- @param id the id of the object
      -- @param bool the boolean value representing if it will enable or disable 
      -- the widget
      -- @param[opt] index an index to target the child button of a buttonbox
      -------------------------------------------------
      set_enabled = function(self, id, bool, index)
         obj:set_enabled(id, bool, index)
      end,
      -------------------------------------------------
      -- Deletes a widget from screen.
      --
      -- @param id the id of the object
      --
      -- @return `true` if successful, `false` if not
      -------------------------------------------------
      delete_widget = function(self, id)
         return obj:delete_widget(id)
      end,
      -------------------------------------------------
      -- Sets a value to a widget. Each widget works with a type of value:
      --
      -- * `Label - string (label itself)`
      -- * `Button - string (button label)`
      -- * `ButtonBox - string (single button label)`
      -- * `ComboBox - integer (item to be set active index)`
      -- * `Image - string (image path)`
      -- * `Text Input - string (text to be insert)`
      -- * `Password Input - string (text to be insert)`
      -- * `TextBox - string (text to be insert)`
      -- * `CheckBox - boolean (state of button)`
      -- * `CheckList - boolean (state of button) and integer (item index)`
      -- * `Selector - table (the new items list) and integer (default value)`
      --
      -- @param id the id of the object
      -- @param value the value that will be assigned to the widget
      -- @param[opt] index an index to target the child of the widget. Must be 
      -- passed to refer to set ButtonBoxes, ComboBoxes and CheckLists. To Selectors
      -- it becames new list's `default_value` and is optional.
      --
      -- @usage scr:set_value('label', "New Label")
      -- scr:set_value('button', "New Button Label")
      -- scr:set_value('button_box', "New Button Label", 2)
      -- scr:set_value('combobox', 2)
      -- scr:set_value('image', 'imgs/image.png')
      -- scr:set_value('text_input', "New Text")
      -- scr:set_value('password_input', "New Password")
      -- scr:set_value('textbox', "New Text")
      -- scr:set_value('checkbox', true)
      -- scr:set_value('checklist', true, 1)
      -- scr:set_value('selector', {'item1', 'item2', 'item3'}, 2)
      -------------------------------------------------
      set_value = function(self, id, value, index)
         obj:set_value(id, value, index)
      end,
      -------------------------------------------------
      -- Gets the value of a widget.
      --
      -- @param id the id of the object
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
      -- * `Selector - a string and a boolean (label and state of button)`
      -------------------------------------------------
      get_value = function(self, id, index)
         return obj:get_value(id, index)
      end,
      -------------------------------------------------
      -- Runs a single screen. Doing so, presumes a single screen window. If it 
      -- needs more than a single screen, must add them all to a wizard and run 
      -- only the wizard.
      --
      -- @see Wizard:add_page
      --
      -- @return a table containing all widgets data
      -------------------------------------------------
      run = function(self)
         return obj:run()
      end,
   }
   local mt = {
      __index = obj,
   }
   setmetatable(self, mt)
   return self
end

-------------------------------------------------
-- Constructs a Wizard.
--
-- @param title the title of the window
-- @param[opt=<code>600</code>] w the width of the window (only used in GUI)
-- @param[opt=<code>w*0.75</code>] h the height of the window (only used in GUI)
-- @param exit_callback a callback function to override the default confirmation
-- messagebox.
-- Receives `exit` (`"DONE"` or `"QUIT"`), `data` and `screen`. Must return `true` or `false`.
-- More info at [https://github.com/PedroAlvesV/AbsTK/wiki/Callbacks#exit-callback](https://github.com/PedroAlvesV/AbsTK/wiki/Callbacks#exit-callback)
--
-- @within abstk
--
-- @return  a Wizard.
-------------------------------------------------
function abstk.new_wizard(title, w, h, exit_callback)
   local obj
   if mode == 'gtk' then
      if w == nil then
         w = 600
      end
      if h == nil then
         h = w*0.75
      end
      obj = AbsGtk.new_wizard(title, w, h, exit_callback)
   elseif mode == 'curses' then
      obj = AbsCurses.new_wizard(title, nil, nil, exit_callback)
   end
   local self = {
      -------------------------------------------------
      -- @type Wizard
      -------------------------------------------------

      -------------------------------------------------
      -- Adds a screen to a wizard. The screen turns into a page with footer navigation 
      -- buttons. 
      --
      -- @param id the id of the object
      -- @param screen the screen that will be added
      -------------------------------------------------
      add_page = function(self, id, screen)
         obj:add_page(id, screen)
      end,
      -------------------------------------------------
      -- Runs a wizard. Must be called in the end of the UI construction.
      --
      -- @see Wizard:add_page
      --
      -- @return a table containing all widgets data
      -------------------------------------------------
      run = function(self)
         return obj:run()
      end,
   }
   return self
end

abstk.set_mode()

return abstk
