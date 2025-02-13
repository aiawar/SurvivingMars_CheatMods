return PlaceObj("ModDef", {
	"title", "Fix Colonists Long Walks",
	"version", 6,
	"version_major", 0,
	"version_minor", 6,
	"image", "Preview.png",
	"id", "ChoGGi_FixColonistsLongWalks",
	"steam_id", "1811507300",
	"pops_any_uuid", "000d3384-12ac-42a4-9808-191b1038060f",
	"author", "ChoGGi",
	"lua_revision", 1007000, -- Picard
	"code", {
		"Code/Script.lua",
	},
	"has_options", true,
	"TagOther", true,
	"description", [[Changes the AreDomesConnectedWithPassage func to also check the walking distance instead of assuming passages == walkable.

This [i]should[/i] stop the random colonist has died from dehydration events we know and love.

Includes mod option to disable fix.
]],
})
