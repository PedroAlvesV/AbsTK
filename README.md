# [![AbsTK](logo/232x72.png?raw=true)](https://github.com/PedroAlvesV/AbsTK-Lua)

[![Join the chat at https://gitter.im/AbsTK-Lua/Lobby](https://badges.gitter.im/AbsTK-Lua/Lobby.svg)](https://gitter.im/AbsTK-Lua/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![MIT License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

The Abstract ToolKit is a widget toolkit for GUI and text-mode applications. It allows you to, with the same source code, build an UI that runs on GUI (GTK) and text-mode (Curses).

![AbsTK Sample](http://i.imgur.com/3yx9zof.png)

## Getting Started

### Installation

The easiest way to install AbsTK is through [LuaRocks](https://github.com/luarocks/luarocks):

```
$ luarocks install --server=http://luarocks.org/dev abstk
```

### Concepts

<p align="justify">AbsTK goal is to produce form-like applications that can run with and without a desktop environment (DE). It's worth it for machines that doesn't have any DE installed, but, also, for instance, when the application is an installer, in which you may prefer a light-weight text-mode (curses) interface, instead of using GUI.</p>

<p align="justify">Although the toolkit focus is on building Wizards, individual Screens can also be produced. Actually, building Screens is the main part of building a Wizard. Wizards are nothing more than a group of ordered Screens.</p>

<p align="justify">The routine is really minimalistic, but, as stated in the previous paragraph, has two ways. To create a Screen, you initialize it and populate it with widgets. If your UI is a single Screen, just run it. If it's a Wizard, repeat the previous process to produce all the Screens. When done, simply create the Wizard, populate it with the Screens and run the Wizard.</p>

<p align="justify">About widgets, it's construction functions are quite similar to one another in terms of parameters. Also, there's an important pattern: if the widget is a singular object (like a button), its construction function name will start with "add", like in <code>add_button()</code>. Otherwise, if the widget is, in fact, a group of objets (like a button box), its construction function will start with "create", like in <code>create_button_box()</code>.</p>

Functions reference at [https://pedroalvesv.github.io/AbsTK-Lua/](https://pedroalvesv.github.io/AbsTK-Lua/).

<!--

### Examples

#### Screen

```lua
local abstk = require 'abstk'
local scr = abstk.new_screen("My First AbsTK UI")
scr:add_label('hellow', "Hello, World!")
scr:run()
```

![Curses UI](http://i.imgur.com/xAq4KJX.png) ![GTK UI](http://i.imgur.com/xAq4KJX.png)

#### Wizard

```lua
local abstk = require 'abstk'
local wizard = abstk.new_wizard("First AbsTK Wizard")
local scr1 = abstk.new_screen("Page 1")
local scr2 = abstk.new_screen("Page 2")
scr1:add_label('label', "While I'm at the first page, [...]")
scr2:add_label('label', "[...] I'm at the second page.")
wizard:add_page('page1', scr1)
wizard:add_page('page2', scr2)
wizard:run()
```

![Curses UI](http://i.imgur.com/xAq4KJX.png) ![GTK UI](http://i.imgur.com/xAq4KJX.png)

You can see a complete list of examples on [src/complete-test/](src/complete-test/).

-->

### Usage

There are two lines that you will put on the top of most of your codes that use AbsTK:

```lua
local abstk = require 'abstk'
abstk.set_mode(...)
```

<p align="justify">The first one is pretty obvious, it's just the usual lib requirement. The second one is not, actually, necessary, but you'll probably want to use it to, manually, set in which mode the UI will run and see how it looks like. This line gets the args passed when running the application. Like:</p>

```
$ lua minimalist-test.lua curses
```

<p align="justify">All it accepts is "curses" and "gtk", because it's not the kind of thing that should be on the final version of your code. When nothing is passed, the toolkit decides which one to use based on <code>os.getenv("DISPLAY")</code> returning value. If it returns something, the OS runs in a GUI, so AbsTK runs in GUI as well. Otherwise, it runs in text-mode.</p>

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