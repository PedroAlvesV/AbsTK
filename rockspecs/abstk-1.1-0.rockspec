package = "AbsTK"
version = "1.1-0"
source = {
   url = "git+https://github.com/PedroAlvesV/AbsTK.git"
}
description = {
   summary = "The Abstract Toolkit – a widget toolkit for GUI and text-mode applications.",
   detailed = [[
	The Abstract Toolkit – a widget toolkit for GUI and text-mode applications.
	It allows you to write an UI and, depending on the OS having or not a desktop environment, it runs on GUI (GTK) or text-mode (Curses).
   ]],
   homepage = "https://github.com/PedroAlvesV/AbsTK",
   license = "MIT"
}
dependencies = { "lgi >= 0.9.1", "lcurses >= 9.0" }
build = {
   type = "builtin",
   modules = {
      abstk = "src/abstk.lua",
      ["abstk.AbsCurses"] = "src/abstk/AbsCurses.lua",
      ["abstk.AbsGtk"] = "src/abstk/AbsGtk.lua",
      ["abstk.util"] = "src/abstk/util.lua",
   }
}
