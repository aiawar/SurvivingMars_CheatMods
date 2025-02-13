return PlaceObj("ModDef", {
	"title", "Fix Landscaping Freeze",
	"version", 2,
	"version_major", 0,
	"version_minor", 2,
	"image", "Preview.png",
	"id", "ChoGGi_FixLandscapingFreeze",
	"steam_id", "1900633592",
	"pops_any_uuid", "b453de60-705c-4ba3-a88c-114828b2e35b",
	"author", "ChoGGi",
	"lua_revision", 1007000, -- Picard
	"code", {
		"Code/Script.lua",
	},
	"has_options", true,
	"TagOther", true,
	"description", [[For some reason LandscapeLastMark gets set to around 4090, when LandscapeMark hits 4095 bad things happen.
This resets LandscapeLastMark to whatever is the highest number in Landscapes when a save is loaded (assuming it's under 3000, otherwise 0).

For those wondering LandscapeLastMark is increased each time you open flatten/ramp (doesn't need to be placed).


Thanks to Quirquie for the bug report (and persistance).

Includes mod option to disable fix.
]],
})