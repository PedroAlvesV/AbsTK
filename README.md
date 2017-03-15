<img src="http://i.imgur.com/yvU16Wg.png" align="right" width="350" height="265"/>

# [![AbsTK-Lua](logo/232x72.png?raw=true)](https://github.com/PedroAlvesV/AbsTK-Lua)

[![Join the chat at https://gitter.im/AbsTK-Lua/Lobby](https://badges.gitter.im/AbsTK-Lua/Lobby.svg)](https://gitter.im/AbsTK-Lua/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![MIT License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

><p align="justify">The Abstract Toolkit – a widget toolkit for GUI and text-mode applications. It allows you to write an UI and, depending on the OS having or not a desktop environment, it runs on GUI (GTK) or text-mode (Curses).</p>

Documentation available at <https://pedroalvesv.github.io/AbsTK-Lua>.

<!---
## Usage

![Curses UI](http://i.imgur.com/xAq4KJX.png) ![GTK UI](http://i.imgur.com/xAq4KJX.png)

Both UIs were produced by the following code:

```lua
local abstk = require 'abstk'
local scr = abstk.new_screen("AbsTK First UI")
scr:add_label('hellow', "Hello, World!")
scr:run()
```
--->


## Installation

AbsTK can generate GUI and text-mode applications, with those being GTK and Curses. So, to install the dependencies:

```
$ [sudo] luarocks install lgi
$ [sudo] luarocks install lcurses
```

And to install AbsTK:

```
$ [sudo] luarocks install --server=http://luarocks.org/dev abstk
```

## Getting Started

### Routines

AbsTK routines are simple.

#### Single Screen

1. Create a Screen
2. Populate Screen with widgets
3. Run Screen

As you can see [here](https://github.com/PedroAlvesV/AbsTK-Lua/blob/master/src/minimalist-test/minimalist-test.lua).

#### Wizard

1. Create Wizard
2. Create Screens
3. Populate Screens with widgets
4. Add Screens to Wizard
5. Run Wizard

As you can see [here](https://github.com/PedroAlvesV/AbsTK-Lua/blob/master/src/complete-test/wizard.lua).

### First steps

There are two lines that you will put on the top of most of your codes that use AbsTK:

```lua
local abstk = require 'abstk'
abstk.set_mode(...)
```

The first one is pretty obvious, it's just the usual lib requirement. The second one is not, actually, necessary, but you'll probably want to use it to, manually, set in which mode the UI will run and see how it looks like. This line gets the args passed when running the application. Like:

```
$ lua minimalist-test.lua curses
```

All it accepts is "curses" and "gtk", because it's not the kind of thing that should be on the final version of your code.
When nothing is passed, the toolkit decides which one to use based on `os.getenv("DISPLAY")` returning value. If it returns something, the OS runs in a GUI, so AbsTK runs in GUI as well. Otherwise, it runs in text-mode.

### Widgets

#### Screen

To add widgets to a Screen, all that must be done is call its construction method with the desired Screen object.
About the functions names, they are very clear and follow a golden rule:
>"add" refers to single widgets construction;
>"create" refers to groups of widgets construction.

For instance,

```lua
scr:add_button('button', "I'm a Button!")
scr:create_button_box('bbox', {"We", "Are", "A", "Button", "Group."})
```

#### Wizard

As Screens for widgets, Wizards follow the same pattern:

```lua
wizard:add_page('screen', scr)
```

You can see more examples in [src/complete-test/](src/complete-test/) and a list with every function at the [documentation](<https://pedroalvesv.github.io/AbsTK-Lua>).

## License

The MIT License (MIT)

Copyright (c) 2017 Pedro Alves Valentim

<p align="justify">Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:</p>

<p align="justify">The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.</p>

<p align="justify">THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.</p>