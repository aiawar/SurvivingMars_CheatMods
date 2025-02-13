return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 10,
			"version_minor", 3,
		}),
	},
	"title", "Construction Show Drone Grid",
	"id", "ChoGGi_ConstructionShowDroneGrid",
	"pops_any_uuid", "8a21486a-8068-41a9-8790-f02074b283e3",
	"steam_id", "1424918098",
	"lua_revision", 1007000, -- Picard
	"version", 18,
	"version_major", 1,
	"version_minor", 8,
	"author", "ChoGGi",
	"image", "Preview.jpg",
	"code", {
		"Code/Script.lua",
	},
	"has_options", true,
	"description", [[
Shows grid radius around Drone Hubs, Rockets, and RC Commanders when you're in construction mode.
Press Numpad 3 to toggle grid anytime (rebind in game options).

Mod Options:
Hex Colour: Change colour of hex grids (default Rocket:green, RCRover:yellow, DroneHub:cyan).
Show during construction: If you don't want grids showing up during construction placement.
Dist From Cursor: Only show grids around buildings this close to the cursor (0 = disabled, 1 = 1000 and so on, 100 == over 2 map squares).
Grid Opacity: Set opacity of grid icons.
Grid Scale: Set scale of grid icons.

Requested by mysticlife.
]],
})
