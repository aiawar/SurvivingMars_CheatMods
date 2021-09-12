-- See LICENSE for terms

return {
	PlaceObj("ModItemOptionToggle", {
		"name", "EnableMod",
		"DisplayName", T(302535920011303, "<color ChoGGi_yellow>Enable Mod</color>"),
		"Help", T(302535920011793, "Disable mod without having to see missing mod msg."),
		"DefaultValue", true,
	}),
	PlaceObj("ModItemOptionToggle", {
		"name", "RevealDarkness",
		"DisplayName", T(0000, "Reveal Darkness"),
		"Help", T(0000, "Lights act more like surface."),
		"DefaultValue", false,
	}),
}
