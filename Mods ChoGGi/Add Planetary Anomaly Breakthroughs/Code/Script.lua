-- See LICENSE for terms

local mod_AddPlanetaryAnomalyBreakthroughs

-- fired when settings are changed/init
local function ModOptions(id)
	-- id is from ApplyModOptions
	if id and id ~= CurrentModId then
		return
	end

	mod_AddPlanetaryAnomalyBreakthroughs = CurrentModOptions:GetProperty("AddPlanetaryAnomalyBreakthroughs")

	if not CurrentModOptions:GetProperty("EnableMod") then
		return
	end

	-- make sure we're in-game
	if not UICity then
		return
	end

	local BreakthroughOrder = BreakthroughOrder
	local c = #BreakthroughOrder
	local unregs = UICity:GetUnregisteredBreakthroughs()
	for i = 1, mod_AddPlanetaryAnomalyBreakthroughs do
		local unreg = unregs[i]
		if unreg then
			c = c + 1
			BreakthroughOrder[c] = unreg
		end
	end

end
--~ OnMsg.ModsReloaded = ModOptions
OnMsg.ApplyModOptions = ModOptions
