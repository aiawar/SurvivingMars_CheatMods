return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 10,
			"version_minor", 3,
		}),
	},
	"title", "RC Bulldozer",
	"id", "ChoGGi_RCBulldozer",
	"steam_id", "1538213471",
	"pops_any_uuid", "c4cbd03c-5dc3-4953-9e13-fbea09273916",
	"version", 7,
	"version_major", 0,
	"version_minor", 7,
	"author", "ChoGGi",
	"image", "Preview.jpg",
	"code", {
		"Code/Script.lua",
	},
	"lua_revision", 1007000, -- Picard
	"description", [[Flattens the ground in front of it.

Options to change the radius, show a circle where it flattens, and change the ground texture (or turn it off).
The buildable area won't be updated till you turn off Dozer Toggle (expensive function call).


Known issues:
You can't place objects nearby the dozer when Dozer Toggle is enabled.
The sides of ground on tall hills don't look that good, you can use my Terraformer mod to smooth them.
Don't use near Philosopher's stones (the green stones).
]],
})
