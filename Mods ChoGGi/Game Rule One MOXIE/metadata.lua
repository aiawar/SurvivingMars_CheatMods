return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 9,
			"version_minor", 9,
		}),
	},
	"title", "Game Rule One MOXIE",
	"id", "ChoGGi_GameRuleOneMOXIE",
	"steam_id", "2489093558",
	"pops_any_uuid", "f7026d21-7c46-4db2-9d7c-ab83df6f5cdb",
	"lua_revision", 1001514, -- Tito
	"version", 1,
	"version_major", 0,
	"version_minor", 1,
	"image", "Preview.jpg",
	"author", "ChoGGi",
	"code", {
		"Code/Script.lua",
	},
--~ 	"has_options", true,
	"TagGameplay", true,
	"description", [[
You can only build one MOXIE (Farms and algae ftw).


Requested by YertyL.
]],
})