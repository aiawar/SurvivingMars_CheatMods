return PlaceObj("ModDef", {
	"title", "Example Delay Mystery",
	"version", 1,
	"version_major", 0,
	"version_minor", 1,

	"image", "Preview.png",
	"id", "ChoGGi_ExampleDelayMystery",
	"author", "ChoGGi",
	"lua_revision", 1007000, -- Picard
	"code", {
		"Code/Script.lua",
	},
	"description", [[Looks for a gamerule id called "replace with gamerule id", if it finds it then the start of the mystery will be delayed 100 days (sols).]],
})
