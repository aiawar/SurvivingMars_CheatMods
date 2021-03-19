return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 9,
			"version_minor", 4,
		}),
	},
	"title", "Unit Thoughts",
	"id", "ChoGGi_UnitThoughts",
	"lua_revision", 1001551,
	"steam_id", "2196814512",
	"pops_any_uuid", "528635cc-5241-4303-87aa-6fa9cfef66c3",
	"version", 5,
	"version_major", 0,
	"version_minor", 5,
	"image", "Preview.png",
	"author", "ChoGGi",
	"code", {
		"Code/Script.lua",
	},
	"has_options", true,
	"TagInterface", true,
	"description", [[Select a unit (drone/rover/colonist/shuttle) to see what it's up to.
Optionally show unit name, target, map grid target area, drone battery life.

Mod Options:
Enable Lines, Show Names, Drone Battery Info, Only Battery Info, Force Clear Lines, Enable Mod, Enable Text, Text Background, Text Opacity, Text Style
]],
})
