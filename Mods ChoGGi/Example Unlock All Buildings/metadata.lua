return PlaceObj("ModDef", {
	"title", "Unlock All Buildings",
	"version", 1,
	"version_major", 0,
	"version_minor", 1,

	"image", "Preview.png",
	"id", "ChoGGi_UnlockAllBuildings",
	"pops_any_uuid", "2020d16d-07e0-4d39-8fd9-ea7e9e87303d",
	"author", "ChoGGi",
	"lua_revision", 1007000, -- Picard
	"code", {
		"Code/Script.lua",
	},
	"description", [[Unlock all buildings without having to unlock research (doesn't include sponsor locked ones).]],
})
