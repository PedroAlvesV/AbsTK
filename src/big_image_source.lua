local abstk = require 'abstk'
abstk.set_mode(...)

local scr = abstk.new_screen("Software Selection")

local message = "At the moment, only the core of the system is installed. You may want to install some of the softwares listed below."
scr:add_label('message', message)

scr:create_selector('installation_type', "Installation type:",
   {
      "Default",
      "Full",
      "Custom",
   }
)

local software_list = {
   {"Desktop environment", true},
   {"... GNOME", true},
   {"... XFCE", false},
   {"... KDE", false},
   {"... Cinnamon", false},
   {"... MATE", false},
   {"... LXDE", false},
   {"Web Server", false},
   {"Print Server", true},
   {"SSH Server", false},
   {"Standard System Utilities", true},
}
scr:create_checklist('software_checklist', "Choose softwares to install:", software_list)

scr:add_label('space_required', "Space required: 20.8MB")
scr:run()