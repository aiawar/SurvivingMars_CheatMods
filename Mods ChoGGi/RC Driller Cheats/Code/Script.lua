-- See LICENSE for terms

if not g_AvailableDlc.gagarin then
	print("RC Driller Cheats: Missing Space Race DLC!")
	return
end

local mod_EnableMod
local mod_AllowDeep
local mod_LossAmount
local mod_ProductionPerDay
local mod_RemoveSponsorLock

local function UpdateRovers()
	if not UICity then
		return
	end

	if mod_RemoveSponsorLock then
		BuildingTemplates.RCDrillerBuilding.sponsor_status1 = false
	else
		BuildingTemplates.RCDrillerBuilding.sponsor_status1 = "required"
	end

	RCDriller.deposit_lost_pct = mod_LossAmount
	RCDriller.production_per_day = mod_ProductionPerDay

	local objs = UICity.labels.RCDriller or ""
	for i = 1, #objs do
		local obj = objs[i]
		obj.deposit_lost_pct = mod_LossAmount
		obj.production_per_day = mod_ProductionPerDay
	end
end

OnMsg.CityStart = UpdateRovers
OnMsg.LoadGame = UpdateRovers
-- switch between different maps (happens before UICity)
OnMsg.ChangeMapDone = UpdateRovers

local function ModOptions(id)
	-- id is from ApplyModOptions
	if id and id ~= CurrentModId then
		return
	end

	mod_EnableMod = CurrentModOptions:GetProperty("EnableMod")
	mod_AllowDeep = CurrentModOptions:GetProperty("AllowDeep")
	mod_LossAmount = CurrentModOptions:GetProperty("LossAmount")
	mod_ProductionPerDay = CurrentModOptions:GetProperty("ProductionPerDay") * const.ResourceScale
	mod_RemoveSponsorLock = CurrentModOptions:GetProperty("RemoveSponsorLock")

	UpdateRovers()
end
-- load default/saved settings
OnMsg.ModsReloaded = ModOptions
-- fired when Mod Options>Apply button is clicked
OnMsg.ApplyModOptions = ModOptions

-- bit of copy pasta from transport code
function RCDriller:GetAutoGatherDeposits()
  return {
    "SubsurfaceDepositPreciousMinerals",
    "SubsurfaceDepositPreciousMetals",
    "SubsurfaceDepositMetals",
  }
end

function RCDriller:Automation_Gather()
  local unreachable_objects = self:GetUnreachableObjectsTable()
  local realm = GetRealm(self)
  local deposit = realm:MapFindNearest(self, "map", self:GetAutoGatherDeposits(), function(d)
		if not self:CanExploit(d) then
      return
    end
    return not unreachable_objects[d]
  end)

  if deposit then
		local pos = deposit:GetPos()
    if self:HasPath(deposit, pos) then
			-- probably not needed?
			if self:GetDist2D(pos) > 15000 then
				self:ReleaseStockpile()
			end
      self:SetCommand("Drill", deposit, GetRandomPassableAround(pos, 500, 500, UICity))
    else
      unreachable_objects[deposit] = true
    end
  end
end

function RCDriller:ProcAutomation()
--~   if self:GetStoredAmount() <= 0 then
    self:Automation_Gather()
--~   else
--~     self:Automation_Unload()
--~   end
  Sleep(2500)
end

local orig_RCDriller_Idle = RCDriller.Idle
function RCDriller:Idle(...)
	if not mod_EnableMod then
		return orig_RCDriller_Idle(self, ...)
	end

  self:Gossip("Idle")
  self:SetState("idle")
  if g_RoverAIResearched and self.auto_mode_on then
    self:ProcAutomation()
	else
		Halt()
	end
end

local allowed_res = {
	Metals = true,
	PreciousMetals = true,
	PreciousMinerals = true,
}
local orig_RCDriller_CanExploit = RCDriller.CanExploit
function RCDriller:CanExploit(deposit, ...)
	if not mod_AllowDeep then
		return orig_RCDriller_CanExploit(self, deposit, ...)
	end

	return allowed_res[deposit.resource]
end

RCDriller.ToggleAutoMode_Update = RCTransport.ToggleAutoMode_Update

function OnMsg.ClassesPostprocess()
	local xtemplate = XTemplates.ipRover[1]

	-- check for and remove existing template
	ChoGGi.ComFuncs.RemoveXTemplateSections(xtemplate, "ChoGGi_Template_RCDrillerCheats_ToggleAuto", true)

	table.insert(xtemplate, 1,
		PlaceObj("XTemplateTemplate", {
			"Id" , "ChoGGi_Template_RCDrillerCheats_ToggleAuto",
			"ChoGGi_Template_RCDrillerCheats_ToggleAuto", true,
			"__context_of_kind", "RCDriller",
			-- main button
			"__template", "InfopanelButton",
			-- section button
			"__condition", function()
				return mod_EnableMod and g_RoverAIResearched
			end,

			"Title", T(370544347739, "Automated Mode"),
			"RolloverTitle", T(370544347739, "Automated Mode"),
			"RolloverText", T(7656, "<left_click> Toggle Automated Mode"),
			"Icon", "UI/Icons/IPButtons/automated_mode_off.tga",

			"OnContextUpdate", function(self, context)
				if context.auto_mode_on then
					self:SetIcon("UI/Icons/IPButtons/automated_mode_on.tga")
				else
					self:SetIcon("UI/Icons/IPButtons/automated_mode_off.tga")
				end
			end,

			"OnPress", function (self, gamepad)
				local c = self.context
				c.auto_mode_on = not c.auto_mode_on
				ObjModified(c)
				if c then
					c:SetCommand("Idle")
				end
			end,
		})
	)

end
