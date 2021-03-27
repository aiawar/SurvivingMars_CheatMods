-- See LICENSE for terms

local PlaceObj = PlaceObj
local T = T
local table_concat = table.concat

-- add some descriptions
local SafeTrans
-- use rawget so game doesn't complain about _G
if rawget(_G, "ChoGGi") then
	SafeTrans = ChoGGi.ComFuncs.Translate
else
	local _InternalTranslate = _InternalTranslate
	local procall = procall

	SafeTrans = function(...)
		local varargs = ...
		local str
		procall(function()
			str = _InternalTranslate(T(varargs))
		end)
		return str or T(302535920011424, "Missing text... Nope just needs UICity which isn't around till in-game (ask the devs).")
	end
end

local properties = {}
local c = 0

local bt = Presets.TechPreset.Breakthroughs
for i = 1, #bt do
	local item = bt[i]
	local id = item.id
	if id ~= "None" then
		c = c + 1
		properties[c] = PlaceObj("ModItemOptionToggle", {
			"name", id,
			"DisplayName", T(item.display_name),
			"Help", table_concat(T(SafeTrans(item.description, item)) .. "\n\n<image " .. item.icon .. ">"),
			"DefaultValue", false,
		})
	end
end

local CmpLower = CmpLower
local _InternalTranslate = _InternalTranslate
table.sort(properties, function(a, b)
	return CmpLower(_InternalTranslate(a.DisplayName), _InternalTranslate(b.DisplayName))
end)

-- stick res option first
table.insert(properties, 1, PlaceObj("ModItemOptionToggle", {
	"name", "BreakthroughsResearched",
	"DisplayName", table_concat(T("<yellow>") .. T(302535920011423, "Breakthroughs Researched")),
	"Help", T(302535920011813, "Turn on to research instead of unlock breakthroughs."),
	"DefaultValue", false,
}))
table.insert(properties, 1, PlaceObj("ModItemOptionToggle", {
	"name", "AlwaysApplyOptions",
	"DisplayName", T(),
	"DisplayName", table_concat(T("<yellow>") .. T(302535920011814, "Always Apply Options")),
	"Help", T(302535920011815, "Unlock/Research Breakthroughs whenever you load a game/start a new game."),
	"DefaultValue", false,
}))

return properties
