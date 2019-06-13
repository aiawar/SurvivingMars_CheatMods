-- See LICENSE for terms

-- setting params are saved here
g_SaveMissionProfiles = {}

local Strings = ChoGGi.Strings

local function CleanGameRules(profile)
	local GameRulesMap = GameRulesMap
	local idGameRules = profile.idGameRules or empty_table
	for id in pairs(idGameRules) do
		if GameRulesMap[id].mod then
			idGameRules[id] = nil
		end
	end
end

local function WriteModSettings(settings)
	settings = settings or g_SaveMissionProfiles

	local lua_code = TableToLuaCode(settings)
	-- lz4 is quicker, but less compressy
	local err, data = AsyncCompress(lua_code, false, "lz4")
	if err then
		print(err)
		return
	end

	-- too large
	if #data > const.MaxModDataSize then
		-- see if it'll fit now
		err, data = AsyncCompress(lua_code, false, "zstd")
		if err then
			print(err)
			return
		end

		if #data > const.MaxModDataSize then
			ChoGGi.ComFuncs.MsgWait("SaveMissionProfiles: too much data, delete some saved settings")
			return
		end
	end

	err = WriteModPersistentData(data)
	if err then
		print(err)
		return
	end

	-- if we call it from ReadModSettings looking for defaults
	return data
end

local function ReadModSettings()
	local settings_table

	-- try to read saved settings
	local err, settings_data = ReadModPersistentData()

	if err or not settings_data or settings_data == "" then
		-- no settings found so write default settings (it returns the saved setting)
		settings_data = WriteModSettings{}
	end

	err, settings_table = AsyncDecompress(settings_data)
	if err then
		print(err)
	end

	-- and convert it to lua / update in-game settings
	err, g_SaveMissionProfiles = LuaCodeToTuple(settings_table)
	if err then
		print(err)
	end

	-- just in case
	if type(g_SaveMissionProfiles) ~= "table" then
		-- i have a defaults table i load up with my mod, if somethings wrong then at at the mod will have some settings to use
		g_SaveMissionProfiles = {}
	end

	return g_SaveMissionProfiles
end

local function SaveProfile(params)
	local choice_str = WaitInputText("Save Profile", "Type a profile name to use.")
	if choice_str and choice_str ~= "" then
		-- remove modded stuff
		CleanGameRules(g_CurrentMissionParams)

		g_SaveMissionProfiles[choice_str] = {
			map = g_CurrentMapParams,
			mission = g_CurrentMissionParams,
			game = params,
			cargo = g_RocketCargo,
		}
		WriteModSettings()
	end
end

local function LoadProfile(name, settings, pgmission)
	local function CallBackFunc(answer)
		if answer then
			-- update in-game settings
			pgmission.context.params = settings.game
			g_CurrentMapParams = settings.map
			g_RocketCargo = settings.cargo

			CleanGameRules(settings.mission)
			g_CurrentMissionParams = settings.mission
		end
	end

	ChoGGi.ComFuncs.QuestionBox(
		"Load profile: " .. name .. [[
You'll have to change the "page" to visually update settings.]],
		CallBackFunc
	)
end
local function DeleteProfile(name, settings_list)
	local function CallBackFunc(answer)
		if answer then
			settings_list[name] = nil
			WriteModSettings()
		end
	end

	ChoGGi.ComFuncs.QuestionBox(
		"Delete profile: " .. name,
		CallBackFunc,
		T(6779--[[Warning]]) .. ": " .. Strings[302535920000855--[[Last chance before deletion!]]]
	)
end

local function ProfileButtonPressed(pgmission, toolbar)
	-- load settings if it's an empty table
	local settings_list = ReadModSettings()
	-- always show save
	local menu = {
		{
			name = T(161964752558--[[Save]]) .. " Profile",
			hint = "Save current profile.",
			clicked = function()
				CreateRealTimeThread(SaveProfile, pgmission.context.params)
			end,
		},
	}
	-- show load/delete when there's something added
	if next(settings_list) then

		menu[#menu+1] = {
			name = T(885629433849--[[Load]]) .. " Profile >",
			hint = "Load saved profile.",
			submenu = {},
		}
		local loadm = menu[#menu]
		menu[#menu+1] = {
			name = T(502364928914--[[Delete]]) .. " Profile >",
			hint = "Delete saved profile.",
			submenu = {},
		}
		local delm = menu[#menu]

		-- add name/params to submenus
		for name, settings in pairs(settings_list) do
			loadm.submenu[#loadm.submenu+1] = {
				name = name,
				clicked = function()
					LoadProfile(name, settings, pgmission)
				end,
			}
			delm.submenu[#delm.submenu+1] = {
				name = name,
				clicked = function()
					DeleteProfile(name, settings_list)
				end,
			}
		end
	end

	-- and finally show menu
	ChoGGi.ComFuncs.PopupToggle(toolbar.idChoGGi_ProfileButton, "ChoGGi_MissionProfilesPopup", menu)
end

-- fired when we go to first new game section
local function AddProfilesButton(pgmission, toolbar)
	if toolbar.idChoGGi_ProfileButton then
		return
	end

	toolbar.idChoGGi_ProfileButton = XTextButton:new({
		Id = "idChoGGi_ProfileButton",
		Text = "PROFILES",
		FXMouseIn = "ActionButtonHover",
		FXPress = "ActionButtonClick",
		FXPressDisabled = "UIDisabledButtonPressed",
		HAlign = "center",
		Background = 0,
		FocusedBackground = 0,
		RolloverBackground = 0,
		PressedBackground = 0,
		RolloverZoom = 1100,
		TextStyle = "Action",
		MouseCursor = "UI/Cursors/Rollover.tga",
		RolloverTemplate = "Rollover",
		RolloverTitle = T(126095410863--[[Info]]),
		RolloverText = [[Save/Load save profiles.]],
		OnPress = function()
			ProfileButtonPressed(pgmission, toolbar)
		end,
	}, toolbar)

end

-- add settings button
local orig_SetPlanetCamera = SetPlanetCamera
function SetPlanetCamera(planet, state, ...)
	-- fire only in mission setup menu
	if not state then
		CreateRealTimeThread(function()
			WaitMsg("OnRender")
			local pgmission = Dialogs.PGMainMenu.idContent.PGMission
			local toolbar = pgmission[1][1].idToolBar
			AddProfilesButton(pgmission, toolbar)
			-- hook into toolbar button area so we can keep adding the button
			local orig_RebuildActions = toolbar.RebuildActions
			toolbar.RebuildActions = function(self, context, ...)
				orig_RebuildActions(self, context, ...)
				AddProfilesButton(pgmission, toolbar)
			end
		end)
	end
	return orig_SetPlanetCamera(planet, state, ...)
end
