return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 10,
			"version_minor", 3,
		}),
	},
	"title", "Set Speed Keys",
	"id", "ChoGGi_SetSpeedKeys",
	"steam_id", "2099080307",
	"pops_any_uuid", "d6997ba2-00c9-46bf-9cef-a32d6b2bb3a2",
	"lua_revision", 1007000, -- Picard
	"version", 3,
	"version_major", 0,
	"version_minor", 3,
	"image", "Preview.png",
	"author", "ChoGGi",
	"code", {
		"Code/Script.lua",
	},
--~ 	"has_options", true,
	"TagOther", true,
	"description", [[
Add keybindings for speed 1 2 3 4 5 (4/5 = *5/*10).


Requested by jaskij.
]],
})
