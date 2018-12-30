-- See LICENSE for terms

local StringFormat = string.format
local TableFind = table.find
local TableClear = table.clear
local TableIClear = table.iclear
local type = type
local pairs = pairs
local Sleep = Sleep
local IsValid = IsValid
local IsValidEntity = IsValidEntity

local getinfo
local debug = rawget(_G,"debug")
if debug then
	getinfo = debug.getinfo
end

function OnMsg.ClassesGenerate()
	local S = ChoGGi.Strings
	local blacklist = ChoGGi.blacklist
	local MsgPopup = ChoGGi.ComFuncs.MsgPopup
	local RetName = ChoGGi.ComFuncs.RetName
	local Trans = ChoGGi.ComFuncs.Translate
	local TableConcat = ChoGGi.ComFuncs.TableConcat

	function ChoGGi.ComFuncs.GenerateScreenshotFilename(prefix, folder, ext, just_name)
		local match = string.match
		local Max = Max

		prefix = prefix or ""
		ext = ext or "png"
		folder = folder or "AppData/"
		if not match(folder, "/$") and #folder > 0 then
			folder = StringFormat("%s/",folder)
		end
		local existing_files = io.listfiles(folder, StringFormat("%s*.%s",prefix,ext))
		local index = 0
		for i = 1, #existing_files do
			index = Max(index, tonumber(match(existing_files[i], StringFormat("%s%s",prefix,"(%d+)")) or 0))
		end
		if just_name then
			return StringFormat("%s%04d", prefix, index + 1)
		end
		return StringFormat("%s%s%04d.%s", folder, prefix, index + 1, ext)
	end
	local GenerateScreenshotFilename = ChoGGi.ComFuncs.GenerateScreenshotFilename

	function ChoGGi.ComFuncs.Dump(obj,mode,file,ext,skip_msg,gen_name)
		if blacklist then
			print(S[302535920000242--[[%s is blocked by SM function blacklist; use ECM HelperMod to bypass or tell the devs that ECM is awesome and it should have �ber access.--]]]:format("Dump"))
			return
		end

--~ 		if mode == "w" or mode == "w+" then
		if mode then
			mode = nil
		else
			mode = "-1"
		end

		local filename
		if gen_name then
			filename = GenerateScreenshotFilename(file or "DumpedText","AppData/logs/",ext or "txt")
		else
			filename = StringFormat("AppData/logs/%s.%s",file or "DumpedText",ext or "txt")
		end

		ThreadLockKey(filename)
		AsyncStringToFile(filename,obj,mode)
		ThreadUnlockKey(filename)

		-- let user know
		if not skip_msg then
			MsgPopup(
				S[302535920000002--[[Dumped: %s--]]]:format(RetName(obj)),
				filename,
				"UI/Icons/Upgrades/magnetic_filtering_04.tga",
				nil,
				obj
			)
		end
	end

	function ChoGGi.ComFuncs.DumpLua(obj)
		ChoGGi.ComFuncs.Dump(StringFormat("%s%s",ChoGGi.newline,ValueToLuaCode(obj)),nil,"DumpedLua","lua")
	end

	do -- DumpTableFunc
		local output_string
		local function RetTextForDump(obj,funcs)
			local obj_type = type(obj)
			if obj_type == "userdata" then
				return Trans(obj)
			elseif funcs and obj_type == "function" then
				local newline = ChoGGi.newline
				return StringFormat("Func: %s%s%s%s%s",newline,newline,obj:dump(),newline,newline)
			elseif obj_type == "table" then
				return StringFormat("%s len: %s",tostring(obj),#obj)
			else
				return tostring(obj)
			end
		end

		local function DumpTableFunc(obj,hierarchyLevel,funcs)
			if (hierarchyLevel == nil) then
				hierarchyLevel = 0
			elseif (hierarchyLevel == 4) then
				return 0
			end

			if type(obj) == "table" then
				if obj.id then
					output_string = StringFormat("%s\n-----------------obj.id: %s :",output_string,obj.id)
				end
				for k,v in pairs(obj) do
					if type(v) == "table" then
						DumpTableFunc(v, hierarchyLevel+1)
					else
						if k ~= nil then
							output_string = StringFormat("%s\n%s = ",output_string,k)
						end
						if v ~= nil then
							output_string = StringFormat("%s%s",output_string,RetTextForDump(v,funcs))
						end
						output_string = StringFormat("%s\n",output_string)
					end
				end
			end
		end

		--[[
		Mode = -1 to append or nil to overwrite (default: -1)
		Funcs = true to dump functions as well (default: false)
		ChoGGi.ComFuncs.DumpTable(Object)
		--]]
		function ChoGGi.ComFuncs.DumpTable(obj,mode,funcs)
			if blacklist then
				print(S[302535920000242--[[%s is blocked by SM function blacklist; use ECM HelperMod to bypass or tell the devs that ECM is awesome and it should have �ber access.--]]]:format("DumpTable"))
				return
			end
			if not obj then
				MsgPopup(
					302535920000003--[[Can't dump nothing--]],
					302535920000004--[[Dump--]]
				)
				return
			end
			mode = mode or "-1"
			--make sure it's empty
			output_string = ""
			DumpTableFunc(obj,nil,funcs)
			AsyncStringToFile("AppData/logs/DumpedTable.txt",output_string,mode)

			MsgPopup(
				S[302535920000002--[[Dumped: %s--]]]:format(RetName(obj)),
				"AppData/logs/DumpedText.txt",
				nil,
				nil,
				obj
			)
		end
	end --do

	-- write logs funcs
	do -- WriteLogs_Toggle
		local Dump = ChoGGi.ComFuncs.Dump
		local SaveOrigFunc = ChoGGi.ComFuncs.SaveOrigFunc
		local pack_params = pack_params
		local tostring = tostring
		local newline = ChoGGi.newline

		-- every 5s check buffer and print if anything
		local timer = ChoGGi.testing and 2500 or 5000
		-- we always start off with a newline so the first line or so isn't merged
		local buffer_table = {newline}
		local buffer_cnt = 1

		if rawget(_G,"ChoGGi_print_buffer_thread") then
			DeleteThread(ChoGGi_print_buffer_thread)
		end
		ChoGGi_print_buffer_thread = CreateRealTimeThread(function()
			while true do
				Sleep(timer)
				if buffer_cnt > 1 then
					Dump(TableConcat(buffer_table,newline),nil,"Console","log",true)
					TableIClear(buffer_table)
					buffer_table[1] = newline
					buffer_cnt = 1
				end
			end
		end)

		local function ReplaceFunc(funcname)
			SaveOrigFunc(funcname)
			-- we want to local this after SaveOrigFunc just in case
			local ChoGGi_OrigFuncs = ChoGGi.OrigFuncs
			local name = StringFormat("%s: %s",funcname,"%s")
			_G[funcname] = function(...)

				-- table.concat don't work with non strings/numbers
				local str = pack_params(...) or ""
				for i = 1, #str do
					str[i] = tostring(str[i])
				end
				str = TableConcat(str, " ")

				if buffer_table[buffer_cnt] ~= str then
					buffer_cnt = buffer_cnt + 1
					buffer_table[buffer_cnt] = name:format(str)
				end

				-- fire off orig func...
				ChoGGi_OrigFuncs[funcname](...)
			end

		end

		local function ResetFunc(funcname)
			if ChoGGi.OrigFuncs[funcname] then
				_G[funcname] = ChoGGi.OrigFuncs[funcname]
			end
		end

		function ChoGGi.ComFuncs.WriteLogs_Toggle(which)
			if blacklist then
				print(S[302535920000242--[[%s is blocked by SM function blacklist; use ECM HelperMod to bypass or tell the devs that ECM is awesome and it should have �ber access.--]]]:format("WriteLogs_Toggle"))
				return
			end

			if which then
				-- move old log to previous and add a blank log
				AsyncCopyFile("AppData/logs/Console.log","AppData/logs/Console.previous.log","raw")
				AsyncStringToFile("AppData/logs/Console.log"," ")

				-- redirect functions
				ReplaceFunc("dlc_print")
				ReplaceFunc("DebugPrintNL")
				ReplaceFunc("OutputDebugString")
				ReplaceFunc("AddConsoleLog") -- also does print()
				ReplaceFunc("assert")
				ReplaceFunc("printf")
				ReplaceFunc("error")
				-- causes an error and stops games from loading
				-- ReplaceFunc("DebugPrint")
			else
				ResetFunc("dlc_print")
				ResetFunc("DebugPrintNL")
				ResetFunc("OutputDebugString")
				ResetFunc("AddConsoleLog")
				ResetFunc("assert")
				ResetFunc("printf")
				ResetFunc("error")
			end
		end
	end -- do

	-- returns table with list of files without path or ext and path, or exclude ext to return all files
	function ChoGGi.ComFuncs.RetFilesInFolder(folder,ext)
		local err, files = AsyncListFiles(folder,ext and StringFormat("*%s",ext) or "*")
		if not err and #files > 0 then
			local table_path = {}
			local path = StringFormat("%s/",folder)
			for i = 1, #files do
				local name
				if ext then
					name = files[i]:gsub(path,""):gsub(ext,"")
				else
					name = files[i]:gsub(path,"")
				end
				table_path[i] = {
					path = files[i],
					name = name,
				}
			end
			return table_path
		end
	end

	function ChoGGi.ComFuncs.RetFoldersInFolder(folder)
		local err, folders = AsyncListFiles(folder,"*","folders")
		if not err and #folders > 0 then
			local table_path = {}
			local temp_path = StringFormat("%s/",folder)
			for i = 1, #folders do
				table_path[i] = {
					path = folders[i],
					name = folders[i]:gsub(temp_path,""),
				}
			end
			return table_path
		end
	end

	do -- OpenInExamineDlg
		local function OpenInExamineDlg(obj,parent,title)
			return Examine:new({}, terminal.desktop,{
				obj = obj,
				parent = parent,
				title = title,
			})
		end

		ChoGGi.ComFuncs.OpenInExamineDlg = OpenInExamineDlg
		function OpenExamine(obj,parent,title)
			OpenInExamineDlg(obj,parent,title)
		end
		ex = OpenExamine
	end -- do

	function ChoGGi.ComFuncs.OpenInMonitorInfoDlg(list,parent)
		if type(list) ~= "table" then
			return
		end

		return ChoGGi_MonitorInfoDlg:new({}, terminal.desktop,{
			obj = list,
			parent = parent,
			tables = list.tables,
			values = list.values,
		})
	end

	function ChoGGi.ComFuncs.OpenInObjectEditorDlg(obj,parent)
		obj = obj or ChoGGi.ComFuncs.SelObject()
		if not obj then
			return
		end

		return ChoGGi_ObjectEditorDlg:new({}, terminal.desktop,{
			obj = obj,
			parent = parent,
		})
	end

	function ChoGGi.ComFuncs.OpenIn3DManipulatorDlg(obj,parent)
		obj = IsValid(obj) and obj or ChoGGi.ComFuncs.SelObject()
		if not obj then
			return
		end

		return ChoGGi_3DManipulatorDlg:new({}, terminal.desktop,{
			obj = obj,
			parent = parent,
		})
	end

	function ChoGGi.ComFuncs.OpenInExecCodeDlg(context,parent)
		return ChoGGi_ExecCodeDlg:new({}, terminal.desktop,{
			obj = context,
			parent = parent,
		})
	end

	function ChoGGi.ComFuncs.OpenInFindValueDlg(context,parent)
		if not context then
			return
		end

		return ChoGGi_FindValueDlg:new({}, terminal.desktop,{
			obj = context,
			parent = parent,
		})
	end

	function ChoGGi.ComFuncs.OpenInImageViewerDlg(context,parent)
		if not context then
			return
		end

		return ChoGGi_ImageViewerDlg:new({}, terminal.desktop,{
			obj = context,
			parent = parent,
		})
	end
	function ChoGGi.ComFuncs.OpenInDTMSlotsDlg(context,parent)
		return ChoGGi_DTMSlotsDlg:new({}, terminal.desktop,{
			obj = context,
			parent = parent,
		})
	end

	function ChoGGi.ComFuncs.CloseDialogs(dlg_class)
		local dlgs = ChoGGi.Temp.Dialogs
		for dlg,class in pairs(dlgs) do
			if class == dlg_class then
				dlg:Done()
			end
		end
	end

	function ChoGGi.ComFuncs.CloseDialogsECM(bool)
		if bool or ChoGGi.UserSettings.CloseDialogsECM then
			local dlgs = ChoGGi.Temp.Dialogs
			for dlg in pairs(dlgs) do
				dlg:Done()
			end
		end
	end

	function ChoGGi.ComFuncs.EntitySpawner(obj,skip_msg,list_type,planning)
		local ChoGGi = ChoGGi
		local const = const

		local title = planning and 302535920000862--[[Object Planner--]] or 302535920000475--[[Entity Spawner--]]
		local hint = planning and 302535920000863--[[Places fake construction site objects at mouse cursor (collision disabled).--]] or 302535920000476--[["Shows list of objects, and spawns at mouse cursor."--]]

		local default
		local ItemList,c

		if IsValid(obj) and IsValidEntity(obj.ChoGGi_orig_entity) then
			default = S[1000121--[[Default--]]]
			ItemList = {{text = StringFormat(" %s",default),value = default}}
			c = 1
		else
			ItemList = {}
			c = 0
		end

		if planning then
			local BuildingTemplates = BuildingTemplates
			for key,obj in pairs(BuildingTemplates) do
				c = c + 1
				ItemList[c] = {
					text = key,
					value = obj.entity,
				}
			end
		else
			local all_entities = GetAllEntities()
			for key in pairs(all_entities) do
				c = c + 1
				ItemList[c] = {
					text = key,
					value = key,
				}
			end
		end

		local function CallBackFunc(choice)
			if #choice < 1 then
				return
			end
			local value = choice[1].value

			if not obj then
				obj = PlaceObj("ChoGGi_BuildingEntityClass",{
					"Pos",ChoGGi.ComFuncs.CursorNearestHex()
				})
				if planning then
					obj.planning = true
					obj:SetGameFlags(const.gofUnderConstruction)
				end
			end

			-- backup orig entity
			if not IsValidEntity(obj.ChoGGi_orig_entity) then
				obj.ChoGGi_orig_entity = obj:GetEntity()
			end

			-- if it's playing certain anims on certains objs, then crash if we don't idle it
			obj:SetState("idle")

			if value == default and IsValidEntity(obj.ChoGGi_orig_entity) then
				obj:ChangeEntity(obj.ChoGGi_orig_entity)
			else
				obj:ChangeEntity(value)
			end

			if SelectedObj == obj then
				SelectionRemove(obj)
				SelectObj(obj)
			end

			-- needs to fire whenever entity changes
			obj:ClearEnumFlags(const.efCollision + const.efApplyToGrids)

			if not skip_msg then
				MsgPopup(
					StringFormat("%s: %s",choice[1].text,S[302535920000014--[[Spawned--]]]),
					title
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = title,
			hint = hint,
			custom_type = list_type or 0,
			custom_func = CallBackFunc,
		}
	end

	function ChoGGi.ComFuncs.SetAnimState(sel)
		local ChoGGi = ChoGGi
		sel = sel or ChoGGi.ComFuncs.SelObject()
		if not sel then
			return
		end

		local ItemList = {}

		local states = sel:GetStates() or ""
		for i = 1, #states do
			ItemList[i] = {
				text = StringFormat("%s: %s, %s: %s",S[302535920000858--[[Index--]]],i,S[1000037--[[Name--]]],states[i]),
				value = states[i],
			}
		end

		local function CallBackFunc(choice)
			if #choice < 1 then
				return
			end

			local value = choice[1].value
			-- if user wants to play it again we'll need to have it set to another state and everything has idle
			sel:SetState("idle")
			sel:SetState(value)
			if value ~= "idle" then
				MsgPopup(
					ChoGGi.ComFuncs.SettingState(choice[1].text,3722--[[State--]]),
					302535920000859--[[Anim State--]]
				)
			end
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = 302535920000860--[[Set Anim State--]],
			hint = S[302535920000861--[[Current State: %s--]]]:format(sel:GetState()),
			custom_type = 7,
			custom_func = CallBackFunc,
		}
	end

	function ChoGGi.ComFuncs.MonitorThreads()
		if blacklist then
			print(S[302535920000242--[[%s is blocked by SM function blacklist; use ECM HelperMod to bypass or tell the devs that ECM is awesome and it should have ܢer access.--]]]:format("MonitorThreads"))
			return
		end

		local table_list = {}
		local dlg = ChoGGi.ComFuncs.OpenInExamineDlg(table_list)
		dlg:EnableAutoRefresh()

		CreateRealTimeThread(function()
			local table_str = "%s(%s) %s"
			-- stop when dialog is closed
			while dlg and dlg.window_state ~= "destroying" do
				TableClear(table_list)
				local ThreadsRegister = ThreadsRegister
				for thread in pairs(ThreadsRegister) do
					local info = getinfo(thread, 1, "Slfun")
					if info then
						table_list[table_str:format(info.short_src,info.linedefined,thread)] = thread
					end
				end
				Sleep(1000)
			end
		end)
	end

	-- sortby: nil = table length, 1 = table names
	-- skip_under: don't show any tables under this length
	-- pad_to: needed for sorting in examine (prefixes zeros to length)
--~ 	ChoGGi.ComFuncs.MonitorTableLength(_G)
	function ChoGGi.ComFuncs.MonitorTableLength(obj,skip_under,pad_to,sortby,name)
		name = name or RetName(obj)
		skip_under = skip_under or 25
		local table_list = {}
		local dlg = ChoGGi.ComFuncs.OpenInExamineDlg(table_list,nil,name)
		dlg:EnableAutoRefresh()
		local table_str = "%s %s"
		local PadNumWithZeros = ChoGGi.ComFuncs.PadNumWithZeros

		CreateRealTimeThread(function()
			-- stop when dialog is closed
			while dlg and dlg.window_state ~= "destroying" do
				TableClear(table_list)

				for key,value in pairs(obj) do
					if type(value) == "table" then
						-- tables can be index or associative or a mix
						local length = 0
						for _ in pairs(value) do
							length = length + 1
						end
						-- skip the tiny tables
						if length > skip_under then
							if not sortby then
								table_list[table_str:format(PadNumWithZeros(length,pad_to),key)] = value
							elseif sortby == 1 then
								table_list[table_str:format(key,length)] = value
							end
						end

					end
				end

				Sleep(1000)
			end
		end)
	end

	function ChoGGi.ComFuncs.SetParticles(sel)
		local name = StringFormat("%s %s",S[302535920000129--[[Set--]]],S[302535920001184--[[Particles--]]])
		sel = sel or ChoGGi.ComFuncs.SelObject()
		if not sel or sel and not sel:IsKindOf("FXObject") then
			MsgPopup(
				StringFormat("%s: %s",S[302535920000027--[[Nothing selected--]]],"FXObject"),
				name
			)
			return
		end

		local PlayFX = PlayFX
		-- make a list of spot names for the obj, so we skip particles that need that spot
		local spots = {}
		local id_start, id_end = sel:GetAllSpots(sel:GetState())
		for i = id_start, id_end do
			spots[sel:GetSpotName(i)] = true
		end

		local default = S[1000121--[[Default--]]]

		local name_str = "%s, %s: %s"
		local hint_str = "Actor: %s, Action: %s: Moment: %s"
		local ItemList = {{text = StringFormat(" %s",default),value = default}}
		local c = 1
		local particles = FXLists.ActionFXParticles
		for i = 1, #particles do
			local p = particles[i]
			if spots[p.Spot] or p.Spot == "" then
				c = c + 1
				ItemList[c] = {
					text = name_str:format(p.Actor,p.Action,p.Moment),
					value = p.Actor,
					action = p.Action,
					moment = p.Moment,
					hint = hint_str:format(p.Actor,p.Action,p.Moment),
				}
			end
		end

		local function CallBackFunc(choice)
			if #choice < 1 then
				return
			end
			local actor = choice[1].value
			local action = choice[1].action
			local moment = choice[1].moment

			-- if there's one playing then stop it
			if sel.ChoGGi_playing_fx then
				PlayFX(sel.ChoGGi_playing_fx, "end", sel)
			end
			-- so we can stop it
			sel.ChoGGi_playing_fx = action

			if type(sel.fx_actor_class_ChoGGi_Orig) == "nil" then
				sel.fx_actor_class_ChoGGi_Orig = sel.fx_actor_class
			end

			sel.fx_actor_class = actor

			if actor == default then
				if sel.fx_actor_class_ChoGGi_Orig then
					sel.fx_actor_class = sel.fx_actor_class_ChoGGi_Orig
				end
				sel.ChoGGi_playing_fx = nil
			else
				PlayFX(action, moment, sel)
			end

			MsgPopup(
				action,
				name
			)
		end

		ChoGGi.ComFuncs.OpenInListChoice{
			callback = CallBackFunc,
			items = ItemList,
			title = name,
			hint = 302535920001421--[[Shows list of particles to quickly test out on objects.--]],
			custom_type = 7,
			custom_func = CallBackFunc,
		}
	end

	function ChoGGi.ComFuncs.ToggleConsole(show)
		local dlgConsole = dlgConsole
		if dlgConsole then
			ShowConsole(show or not dlgConsole:GetVisible())
			dlgConsole.idEdit:SetFocus()
		end
	end

	do -- UpdateConsoleLogMargins
		local margin_vis = box(10, 80, 10, 65)
		local margin_hidden = box(10, 80, 10, 10)
		function ChoGGi.ComFuncs.UpdateConsoleLogMargins(which)
			if dlgConsoleLog then
				-- move log text above the buttons i added and make sure log text stays below the cheat menu
				if which then
					dlgConsoleLog.idText:SetMargins(margin_vis)
				else
					dlgConsoleLog.idText:SetMargins(margin_hidden)
				end
			end
		end
	end -- do

	function ChoGGi.ComFuncs.SelectConsoleLogText()
		local dlgConsoleLog = dlgConsoleLog
		if not dlgConsoleLog then
			return
		end
		local text = dlgConsoleLog.idText:GetText()
		if #text < 1 then
			print(S[302535920000692--[[Log is blank (well not anymore).--]]])
			return
		end

		ChoGGi.ComFuncs.OpenInMultiLineTextDlg{text = text}
	end

	function ChoGGi.ComFuncs.ShowConsoleLogWin(visible)
		if visible and not dlgChoGGi_ConsoleLogWin then
			dlgChoGGi_ConsoleLogWin = ChoGGi_ConsoleLogWin:new({}, terminal.desktop,{})
			local _,text = ReadLog()
			dlgChoGGi_ConsoleLogWin:UpdateText(text)
		end

		local dlg = dlgChoGGi_ConsoleLogWin
		if dlg then
			dlg:SetVisible(visible)

			--size n position
			local size = ChoGGi.UserSettings.ConsoleLogWin_Size
			local pos = ChoGGi.UserSettings.ConsoleLogWin_Pos
			--make sure dlg is within screensize
			if size then
				dlg:SetSize(size)
			end
			if pos then
				dlg:SetPos(pos)
			else
				dlg:SetPos(point(100,100))
			end

		end
	end

	-- Any png files in AppData/Logos folder will be added to mod as converted logo files.
	-- They have to be min of 8bit, and will be resized to power of 2.
	-- This doesn't add anything to metadata/items, it only converts files.
--~ 	ChoGGi.ComFuncs.ConvertImagesToLogoFiles("MOD_ID")
--~ 	ChoGGi.ComFuncs.ConvertImagesToLogoFiles(Mods.MOD_ID,".tga")
	function ChoGGi.ComFuncs.ConvertImagesToLogoFiles(mod,ext)
		if blacklist then
			print(S[302535920000242--[[%s is blocked by SM function blacklist; use ECM HelperMod to bypass or tell the devs that ECM is awesome and it should have Über access.--]]]:format("ConvertImagesToLogoFiles"))
			return
		end
		if type(mod) == "string" then
			mod = Mods[mod]
		end
		local images = ChoGGi.ComFuncs.RetFilesInFolder("AppData/Logos",ext or ".png")
		if images then
			local ModItemDecalEntity = ModItemDecalEntity
			local Import = ModItemDecalEntity.Import
			local ConvertToOSPath = ConvertToOSPath
			for i = 1, #images do
				local filename = ConvertToOSPath(images[i].path)
				Import(nil,ModItemDecalEntity:new{
					entity_name = images[i].name,
					name = images[i].name,
					filename = filename:gsub("\\","/"),
					mod = mod,
				})
				print(filename)
			end
		end
	end

	do -- ConvertImagesToResEntities
		local ConvertToOSPath = ConvertToOSPath
		local RetFilesInFolder = ChoGGi.ComFuncs.RetFilesInFolder
	--~ 	ModItemDecalEntity:Import
		local function ModItemDecalEntityImport(name,filename,mod)
			local ss = "%s%s"
			local ssdds = "%s%s.dds"
			local output_dir = ConvertToOSPath(mod.content_path)

			local ent_dir = StringFormat("%sEntities/",output_dir)
			local ent_file = StringFormat("%s.ent",name)
			local ent_output = ss:format(ent_dir,ent_file)

			local mtl_dir = StringFormat("%sEntities/Materials/",output_dir)
			local mtl_file = StringFormat("%s_mesh.mtl",name)
			local mtl_output = ss:format(mtl_dir,mtl_file)

			local texture_dir = StringFormat("%sEntities/Textures/",output_dir)
			local texture_output = ssdds:format(texture_dir,name)

			local fallback_dir = StringFormat("%sFallbacks/",texture_dir)
			local fallback_output = ssdds:format(fallback_dir,name)

			local err = AsyncCreatePath(ent_dir)
			if err then
				return err
			end
			err = AsyncCreatePath(mtl_dir)
			if err then
				return err
			end
			err = AsyncCreatePath(texture_dir)
			if err then
				return err
			end
			err = AsyncCreatePath(fallback_dir)
			if err then
				return err
			end

			err = AsyncStringToFile(ent_output, StringFormat([[<?xml version="1.0" encoding="UTF-8"?>
<entity path="">
	<state id="idle">
		<mesh_ref ref="mesh"/>
	</state>
	<mesh_description id="mesh">
		<src file=""/>
		<mesh file="SignConcreteDeposit_mesh.hgm"/>
		<material file="%s"/>
		<bsphere value="0,0,50,1301"/>
		<box min="-920,-920,50" max="920,920,50"/>
	</mesh_description>
</entity>
]],mtl_file))
			if err then
				return
			end

			local cmdline = StringFormat([["%s" -dds10 -24 bc1 -32 bc3 -srgb "%s" "%s"]], ConvertToOSPath(g_HgnvCompressPath), filename, texture_output)
			err = AsyncExec(cmdline, "", true, false)
			if err then
				return err
			end
			cmdline = StringFormat([["%s" "%s" "%s" %d]], ConvertToOSPath(g_DdsTruncPath), texture_output, fallback_output, const.FallbackSize)
			err = AsyncExec(cmdline, "", true, false)
			if err then
				return err
			end
			cmdline = StringFormat([["%s" "%s" "%s"]], ConvertToOSPath(g_HgimgcvtPath), texture_output, ui_output)
			err = AsyncExec(cmdline, "", true, false)
			if err then
				return err
			end

			err = AsyncStringToFile(mtl_output,StringFormat([[<?xml version="1.0" encoding="UTF-8"?>
<Materials>
	<Material>
		<BaseColorMap Name="%s.dds" mc="0"/>
		<SIMap Name="BackLight.dds" mc="0"/>
		<Property Special="None"/>
		<Property AlphaBlend="Blend"/>
	</Material>
</Materials>]],name))

			if err then
				return err
			end
		end

--~ 	ChoGGi.ComFuncs.ConvertImagesToResEntities("ChoGGi_ExampleNewResIcon")
--~ 	ChoGGi.ComFuncs.ConvertImagesToResEntities("MOD_ID")
--~ 	ChoGGi.ComFuncs.ConvertImagesToResEntities(Mods.MOD_ID,".tga")
		function ChoGGi.ComFuncs.ConvertImagesToResEntities(mod,ext)
			if blacklist then
				print(S[302535920000242--[[%s is blocked by SM function blacklist; use ECM HelperMod to bypass or tell the devs that ECM is awesome and it should have Über access.--]]]:format("ConvertImagesToResEntities"))
				return
			end
			if type(mod) == "string" then
				mod = Mods[mod]
			end
			local images = RetFilesInFolder("AppData/Logos",ext or ".png")
			if images then
				for i = 1, #images do
					local filename = ConvertToOSPath(images[i].path)
					ModItemDecalEntityImport(
						images[i].name,
						filename:gsub("\\","/"),
						mod
					)
					print(filename)
				end
			end

		end
	end -- do

	do -- ExamineEntSpots
		local spots_str = [[<attach name="%s" spot_note="%s" bone="%s" spot_pos="%s,%s,%s" spot_scale="%s" spot_rot="%s,%s,%s,%s"/>]]
		local bsphere_str = [[<bsphere value="%s,%s,%s,%s"/>]]
		local box_str = [[<box min="%s,%s,%s" max="%s,%s,%s"/>]]
		local readme_str = [[Readme:
See bottom for box/bsphere.
The func I use for spot_rot rounds to two decimal points...

]]

--~ local list = ChoGGi.ComFuncs.ExamineEntSpots(s,true)
--~ list = ChoGGi.ComFuncs.TableConcat(list,"\n")
--~ ChoGGi.ComFuncs.Dump(list)
		function ChoGGi.ComFuncs.ExamineEntSpots(obj,parent_or_ret)
			obj = obj or ChoGGi.ComFuncs.SelObject()
			if not IsValid(obj) then
				return
			end

			local spots_table = {[-1] = readme_str}

			local origin = obj:GetSpotBeginIndex("Origin")
			local origin_pos_x, origin_pos_y, origin_pos_z = obj:GetSpotLocPosXYZ(origin)

			local id_start, id_end = obj:GetAllSpots(EntityStates.idle)
			for i = id_start, id_end do
				local name = obj:GetSpotName(i)

				-- make a copy to edit
				local spots_str_t = spots_str

				-- we don't want to fill the list with stuff we don't use
				local annot = obj:GetSpotAnnotation(i)
				if not annot then
					annot = ""
					spots_str_t = spots_str_t:gsub([[ spot_note="%%s"]],"%%s")
				end

				local bone = obj:GetSpotBone(i)
				if bone == "" then
					spots_str_t = spots_str_t:gsub([[ bone="%%s"]],"%%s")
				end

				-- scale angle,axis (position numbers are off-by-one for negative numbers)
				local _,_,_,angle,axis_x,axis_y,axis_z,scale = obj:GetSpotLocXYZ(i)

				-- 100 is default
				if scale == 100 then
					spots_str_t = spots_str_t:gsub([[ spot_scale="%%s"]],"%%s")
					scale = ""
				end

				-- means nadda for spot_rot
				if angle == 0 and axis_x == 0 and axis_y == 0 and axis_z == 4096 then
					spots_str_t = spots_str_t:gsub([[ spot_rot="%%s,%%s,%%s,%%s"]],"%%s%%s%%s%%s")
					angle,axis_x,axis_y,axis_z = "","","",""
				else
					axis_x = (axis_x + 0.0) / 100
					axis_y = (axis_y + 0.0) / 100
					axis_z = (axis_z + 0.0) / 100
					angle = DivRound(angle, const.Scale.degrees) + 0.0
				end

				local pos_x,pos_y,pos_z = obj:GetSpotPosXYZ(i)

				spots_table[i] = spots_str_t:format(
					name,annot,bone,
					pos_x - origin_pos_x,pos_y - origin_pos_y,pos_z - origin_pos_z,
					scale,axis_x,axis_y,axis_z,angle
				)
			end

			-- this is our bonus eh
			local bbox = obj:GetEntityBBox()
			local x1,y1,z1 = bbox:minxyz()
			local x2,y2,z2 = bbox:maxxyz()
			spots_table.box = box_str:format(x1,y1,z1,x2,y2,z2)

			local pos_x, pos_y, pos_z, rad = obj:GetBSphere("idle", true)
			spots_table.bsphere = bsphere_str:format(pos_x - origin_pos_x, pos_y - origin_pos_y, pos_z - origin_pos_z, rad)

			if parent_or_ret == true then
				return spots_table
			else
				ChoGGi.ComFuncs.OpenInExamineDlg(
					spots_table,
					parent_or_ret,
					StringFormat("%s: %s",S[302535920000235--[[Attach Spots List--]]],RetName(obj))
				)
			end
		end
	end -- do

--~ 	ChoGGi.ComFuncs.ProcessHexSurfaces(s.entity)
	-- not in a working state as yet (trying to re-create .ent/mtl files)
	function ChoGGi.ComFuncs.ProcessHexSurfaces(entity,parent_or_ret)
		local hexes = {}
		local EntitySurfaces = EntitySurfaces
		for name,surface_num in pairs(EntitySurfaces) do
			if HasAnySurfaces(entity, surface_num) then
				local all_states = GetStates(entity)
				for _,state in ipairs(all_states) do
					local state_idx = GetStateIdx(state)
					local outline, interior, hash = GetSurfaceHexShapes(entity, state_idx, surface_num)
--~ 					if #outline > 0 or #interior > 0 then
						hexes[name] = {outline = outline, interior = interior, hash = hash}
--~ 					end
				end
			end
		end

		if parent_or_ret == true then
			return hexes
		else
			ChoGGi.ComFuncs.OpenInExamineDlg(hexes)
		end
	end

	do -- ObjFlagsList
		local IsFlagSet = IsFlagSet
		local const = const

		-- get list of const.rf* flags
		local rf_flags = {}
		local int_flags = {}
		for flag,value in pairs(const) do
			if flag:sub(1,2) == "rf" and type(value) == "number" then
				rf_flags[flag] = value
			elseif flag:sub(1,3) == "int" and type(value) == "number" then
				int_flags[flag] = value
			end
		end

		local flags_table
		local function CheckFlags(flags,list)
			for i = 1, #list do
				local f = list[i]
				flags_table[f] = IsFlagSet(flags, const[f])
			end
		end

--~ 		function ChoGGi.ComFuncs.ObjFlagsList_XWin(flags)
--~ 			if not flags then
--~ 				return
--~ 			end
--~ 			flags_table = {}

--~ 			for flag,value in pairs(int_flags) do
--~ 				flags_table[flag] = IsFlagSet(flags,value)
--~ 			end

--~ 			if parent_or_ret == true then
--~ 				return flags_table
--~ 			else
--~ 				ChoGGi.ComFuncs.OpenInExamineDlg(flags_table,parent_or_ret)
--~ 			end
--~ 		end

		function ChoGGi.ComFuncs.ObjFlagsList_TR(obj,parent_or_ret)
			if not obj or obj.__name ~= "HGE.TaskRequest" then
				return
			end
			flags_table = {}

			for flag,value in pairs(rf_flags) do
				flags_table[flag] = obj:IsAnyFlagSet(value)
			end

			if parent_or_ret == true then
				return flags_table
			else
				ChoGGi.ComFuncs.OpenInExamineDlg(flags_table,parent_or_ret,RetName(obj))
			end
		end

		function ChoGGi.ComFuncs.ObjFlagsList(obj,parent_or_ret)
			obj = obj or ChoGGi.ComFuncs.SelObject()
			if not IsValid(obj) then
				return
			end

			flags_table = {}

			local class = obj:GetClassFlags()
			local enum = obj:GetEnumFlags()
			local game = obj:GetGameFlags()

			local Flags = Flags
			CheckFlags(class,Flags.Class)
			CheckFlags(enum,Flags.Enum)
			CheckFlags(game,Flags.Game)

			if parent_or_ret == true then
				return flags_table
			else
				ChoGGi.ComFuncs.OpenInExamineDlg(flags_table,parent_or_ret,RetName(obj))
			end

		end
	end -- do

	do -- GetMaterialProperties
		local GetMaterialProperties = GetMaterialProperties
		local GetStateNumMaterials = GetStateNumMaterials
		local GetStateMaterial = GetStateMaterial
		local GetStateIdx = GetStateIdx
		local GetStateLODCount = GetStateLODCount
		local GetStates = GetStates
		local TableIsEqual = ChoGGi.ComFuncs.TableIsEqual
		local mat_table_str = S[302535920001477--[["%s, Mat: %s, LOD: %s, State: %s"--]]]

		local function EntityMats(entity)
			local mats = {}
			local c = 0
			local states = GetStates(entity) or ""
			for si = 1, #states do
				local state = GetStateIdx(states[si])
				local num_lods = GetStateLODCount(entity, state) or 0
				for li = 1, num_lods do
					local num_mats = GetStateNumMaterials(entity, state, li - 1) or 0
					for mi = 1, num_mats do
						local mat_name = GetStateMaterial(entity,state,mi - 1,li - 1)
						local mat = GetMaterialProperties(mat_name)
						mat.__mtl = mat_name
						mat.__lod = li
						mat.__state = li
						mats[mat_table_str:format(mat_name,mi,li,si)] = mat
					end
				end
			end
			if #mats == 1 then
				return mats[1]
			end

--~ 			for i = #mats, 1, -1 do
--~ 				if i == 1 then
--~ 					break
--~ 				end
--~ 				local t1,t2 = mats[i],mats[1]
--~ 				if type(t1) == "table" and type(t2) == "table" and TableIsEqual(t1,t2) then
--~ 					table.remove(mats,i)
--~ 				end
--~ 			end

--~ 			if #mats == 1 then
--~ 				return mats[1]
--~ 			end

			return mats
		end

		local function EntityMatsORIG(entity)
			local mats = {}
			local c = 0
			local states = GetStates(entity) or ""
			for si = 1, #states do
				local state = GetStateIdx(states[si])
				local num_lods = GetStateLODCount(entity, state) or 0
				for li = 1, num_lods do
					local num_mats = GetStateNumMaterials(entity, state, li - 1) or 0
					for mi = 1, num_mats do
						local mat_name = GetStateMaterial(entity,state,mi - 1,li - 1)
						local mat = GetMaterialProperties(mat_name)
						mat.__mtl = mat_name
						mat.__lod = li
						local t1 = mats[c]
						local t1_type = type(t1) == "table"
						if not t1_type or t1_type and not TableIsEqual(t1,mat) then
							c = c + 1
							mats[c] = mat
						end
					end
				end
			end
			if #mats == 1 then
				return mats[1]
			end

			for i = #mats, 1, -1 do
				if i == 1 then
					break
				end
				local t1,t2 = mats[i],mats[1]
				if type(t1) == "table" and type(t2) == "table" and TableIsEqual(t1,t2) then
					table.remove(mats,i)
				end
			end

			if #mats == 1 then
				return mats[1]
			end

			return mats
		end

		function ChoGGi.ComFuncs.GetMaterialProperties(obj,parent_or_ret)
			if not UICity then
				return
			end
			obj = obj or ChoGGi.ComFuncs.SelObject()
			if IsValid(obj) then
				obj = obj:GetEntity()
			end

			if IsValidEntity(obj) then
				if parent_or_ret == true then
					return EntityMats(obj)
				else
					ChoGGi.ComFuncs.OpenInExamineDlg(EntityMats(obj),parent_or_ret,S[302535920001458--[[Material Properties--]]])
				end
			else
				local materials = {}
				local all_entities = GetAllEntities()
				for entity in pairs(all_entities) do
					materials[entity] = EntityMats(entity)
--~ 					if entity:find("AlienDiggerBig") then
--~ 						break
--~ 					end
				end
				ChoGGi.ComFuncs.OpenInExamineDlg(materials,parent,S[302535920001458--[[Material Properties--]]])
			end
		end
	end -- do

	do -- DisplayObjectImages
		local ext_list = {
			[".dds"] = true,
			[".tga"] = true,
			[".png"] = true,
		}

		function ChoGGi.ComFuncs.DisplayObjectImages(obj,parent,images)
			images = images or {}
			if type(obj) ~= "table" then
				return
			end
			local c = #images

			-- grab any strings with the correct ext
			for _,value in pairs(obj) do
				if type(value) =="string" and ext_list[value:sub(-4)] then
					c = c + 1
					images[c] = value
				end
			end

			local meta = getmetatable(obj)
			while meta do
				for _,value in pairs(meta) do
					if type(value) =="string" and ext_list[value:sub(-4)] then
						c = c + 1
						images[c] = value
					end
				end
				meta = getmetatable(meta)
			end

			if #images > 0 then
				images = ChoGGi.ComFuncs.RetTableNoDupes(images)
				table.sort(images)
				ChoGGi.ComFuncs.OpenInImageViewerDlg(images,parent)
				return true
			end
		end
	end -- do

	do -- BBoxLines_Toggle
		local guim = guim
		local MulDivRound = MulDivRound
		local Max = Max
		local point = point
		local PlacePolyline = PlacePolyline
		local GetHeight = terrain.GetHeight

		local function SpawnBoxLine(lines, bbox, list, color)
			local line = PlacePolyline(list, color)
			line:SetPos(bbox:Center())
			lines[#lines+1] = line
		end
		local pillar_lines = {}
		local function SpawnPillarLine(pt, z, height, lines, color)
			TableIClear(pillar_lines)
			pillar_lines[1] = pt:SetZ(z)
			pillar_lines[2] = pt:SetZ(height)
			local line = PlacePolyline(pillar_lines, color)
			line:SetPos(AveragePoint2D(line.vertices))
			lines[#lines+1] = line
		end

		-- CommonLua\Classes\CodeRenderableObject.lua
		local function GetBoxPoints(pt1, pt2, z, step, offset, obj_height, points_top, points_bot)
			return points_top,points_bot
		end

		local edges = {}
		local function PlaceTerrainBox(bbox, z, color, step, offset, obj_height)
			step = step or guim
			offset = offset or 0

			local a,b,c,d = bbox:ToPoints2D()
			edges[1] = a
			edges[2] = b
			edges[3] = c
			edges[4] = d
			-- needed to complete the square
			edges[5] = edges[1]
			edges[6] = edges[2]


			-- top of box
			local points_top = {}
			-- bottom
			local points_bot = {}
			-- stores all line objs for deletion later
			local lines = {}

			for i = 1, #edges - 1 do

				local pt1 = edges[i]
				local pt2 = edges[i + 1]
				local diff = pt2 - pt1
				local steps = Max(2, 1 + diff:Len2D() / step)

				for j = 1, steps do
					local pos = pt1 + MulDivRound(diff, j - 1, steps - 1)
					local x, y = pos:xy()
					local t_height = GetHeight(x, y)
					z = z
					if z < t_height then
						z = t_height
					end
					z = z + offset

					-- add the four "pillars"
					if i < 5 then
						SpawnPillarLine(edges[i], z, z + obj_height, lines, color)
					end

					points_top[#points_top + 1] = point(x, y, z + obj_height)
					points_bot[#points_bot + 1] = point(x, y, z)
				end


				points_bot[#points_bot] = nil
				points_top[#points_top] = nil
			end

			SpawnBoxLine(lines, bbox, points_top, color)
			SpawnBoxLine(lines, bbox, points_bot, color)

			return lines
		end

		function ChoGGi.ComFuncs.BBoxLines_Toggle(obj)
			obj = obj or ChoGGi.ComFuncs.SelObject()
			if not IsValid(obj) then
				return
			end

			-- check if bbox showing
			if obj.ChoGGi_bboxobj then
				for i = 1, #obj.ChoGGi_bboxobj do
					local line = obj.ChoGGi_bboxobj[i]
					if IsValid(line) then
						line:delete()
					end
				end
				obj.ChoGGi_bboxobj = nil
			else
				local bbox = obj.GetObjectBBox and obj:GetObjectBBox()
				if bbox then
					obj.ChoGGi_bboxobj = PlaceTerrainBox(
						bbox,
						obj:GetZ(),
						nil,nil,nil,
						bbox:sizez() or 1500
					)
				end
			end
		end
	end -- do

	function ChoGGi.ComFuncs.MoveObjToGround(obj)
		local t_height = terrain.GetHeight(obj:GetVisualPos())
		obj:SetPos(obj:GetPos():SetZ(t_height))

	end

end
