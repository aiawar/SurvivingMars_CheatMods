-- See LICENSE for terms

if g_Classes.ChoGGi_ConsoleLogWin then
  return
end

local Concat = ChoGGi.ComFuncs.Concat
local S = ChoGGi.Strings

local print,select,rawget = print,select,rawget

local FlushLogFile = FlushLogFile
local AsyncFileToString = AsyncFileToString
local RGBA = RGBA
local point = point
local GetLogFile = GetLogFile

-- 1 above console log, 5000 above examine
local zorder = 2005001

DefineClass.ChoGGi_ConsoleLogWin = {
  __parents = {"FrameWindow"},
  ZOrder = zorder,
  transp_mode = false,
  update_thread = false,
  MinSize = point(50, 50),
  translate = false,
}

function ChoGGi_ConsoleLogWin:Init()
  local ChoGGi = ChoGGi
  local g_Classes = g_Classes

  --element pos is based on
  self:SetPos(point(0,0))
  --make it easier to place elements and not have to manually set all positions
  local dialog_width = 700
  local dialog_height = 500
  self:SetSize(point(dialog_width, dialog_height))
  self:SetMovable(true)

  local border = 4
  local element_y
  local element_x
  dialog_width = dialog_width - border * 2
  local dialog_left = border

  ChoGGi.ComFuncs.DialogAddCloseX(self)
  ChoGGi.ComFuncs.DialogAddCaption(self,{
    title = S[302535920001120--[[Console Log Window--]]],
    pos = point(25, border),
    size = point(dialog_width-self.idCloseX:GetSize():x(), 22)
  })

  element_y = border / 2 + self.idCaption:GetPos():y() + self.idCaption:GetSize():y()

  local title = S[302535920000865--[[Toggle Trans--]]]
  self.idToggleTrans = g_Classes.CheckButton:new(self)
  self.idToggleTrans:SetPos(point(dialog_left, element_y))
  self.idToggleTrans:SetSize(ChoGGi.ComFuncs.RetCheckTextSize(title) + point(20,5))
  self.idToggleTrans:SetText(title)
  self.idToggleTrans:SetButtonSize(point(16, 16))
  self.idToggleTrans:SetImage("CommonAssets/UI/Controls/Button/CheckButton.tga")
  self.idToggleTrans:SetHSizing("AnchorToLeft")
  self.idToggleTrans:SetVSizing("AnchorToTop")
  --make checkbox work like a button
  function self.idToggleTrans.button.OnButtonPressed()
    self.transp_mode = not self.transp_mode
    g_Classes.Examine.SetTranspMode(self,self.transp_mode)
  end

  element_x = self.idToggleTrans:GetPos():x() + self.idToggleTrans:GetSize():x() - 20

  title = S[302535920001026--[[Show File Log--]]]
  self.idShowFileLog = g_Classes.Button:new(self)
  self.idShowFileLog:SetPos(point(element_x, element_y))
  self.idShowFileLog:SetText(title)
  self.idShowFileLog:SetSize(ChoGGi.ComFuncs.RetButtonTextSize(title) + point(20,5))
  self.idShowFileLog:SetHSizing("AnchorToLeft")
  self.idShowFileLog:SetVSizing("AnchorToTop")
  self.idShowFileLog:SetHint(S[302535920001091--[[Flushes log to disk and displays in console log.--]]])
  function self.idShowFileLog.OnButtonPressed()
    FlushLogFile()
    print(select(2,AsyncFileToString(GetLogFile())))
  end

  element_x = self.idShowFileLog:GetPos():x() + self.idShowFileLog:GetSize():x() - 20

  title = S[302535920000071--[[Mods Log--]]]
  self.idShowModsLog = g_Classes.Button:new(self)
  self.idShowModsLog:SetPos(point(element_x, element_y))
  self.idShowModsLog:SetText(title)
  self.idShowModsLog:SetSize(ChoGGi.ComFuncs.RetButtonTextSize(title) + point(20,5))
  self.idShowModsLog:SetHSizing("AnchorToLeft")
  self.idShowModsLog:SetVSizing("AnchorToTop")
  self.idShowModsLog:SetHint(S[302535920000870--[[Shows any errors from loading mods in console log.--]]])
  function self.idShowModsLog.OnButtonPressed()
    print(ModMessageLog)
  end

  element_x = self.idShowModsLog:GetPos():x() + self.idShowModsLog:GetSize():x()

  title = S[302535920000734--[[Clear Log--]]]
  self.idClearLog = g_Classes.Button:new(self)
  self.idClearLog:SetPos(point(element_x, element_y))
  self.idClearLog:SetText(title)
  self.idClearLog:SetSize(ChoGGi.ComFuncs.RetButtonTextSize(title) + point(-10,5))
  self.idClearLog:SetHSizing("AnchorToLeft")
  self.idClearLog:SetVSizing("AnchorToTop")
  self.idClearLog:SetHint(S[302535920000477--[[Clear out the windowed console log.--]]])
  function self.idClearLog.OnButtonPressed()
    self:ClearText()
  end

  element_x = self.idClearLog:GetPos():x() + self.idClearLog:GetSize():x()

  title = S[302535920000563--[[Copy Log Text--]]]
  self.idCopyText = g_Classes.Button:new(self)
  self.idCopyText:SetPos(point(element_x, element_y))
  self.idCopyText:SetText(title)
  self.idCopyText:SetSize(ChoGGi.ComFuncs.RetButtonTextSize(title) + point(20,5))
  self.idCopyText:SetHSizing("AnchorToLeft")
  self.idCopyText:SetVSizing("AnchorToTop")
  self.idCopyText:SetHint(S[302535920001154--[[Displays the log text in a window you can copy sections from.--]]])
  function self.idCopyText.OnButtonPressed()
    ChoGGi.ComFuncs.SelectConsoleLogText()
  end

----------------------------------------end of line of controls


  element_y = border / 2 + self.idShowFileLog:GetPos():y() + self.idShowFileLog:GetSize():y()

  self.idText = g_Classes.StaticText:new(self)
  self.idText:SetPos(point(dialog_left, element_y))
  self.idText:SetSize(point(dialog_width, dialog_height-element_y-border))
  self.idText:SetHSizing("Resize")
  self.idText:SetVSizing("Resize")
  self.idText:SetBackgroundColor(RGBA(0, 0, 0, 50))
  self.idText:SetFontStyle("Editor12Bold")
  self.idText:SetScrollBar(true)
  self.idText:SetScrollAutohide(true)

--~   self.transp_mode = transp_mode or false
--~   g_Classes.Examine.SetTranspMode(self,transp_mode)
--~   self:SetTranspMode(self.transp_mode)

  --so elements move when dialog re-sizes
  self:InitChildrenSizing()
end

function ChoGGi_ConsoleLogWin:ClearText()
  self.idText:SetText("")
end

function ChoGGi_ConsoleLogWin:Done(result)
  local ChoGGi = ChoGGi
  --closing means user doesn't want to see it next time (probably)
  ChoGGi.UserSettings.ConsoleHistoryWin = false
  dlgChoGGi_ConsoleLogWin = false
  ChoGGi.SettingFuncs.WriteSettings()
  --save the dimensions
  ChoGGi.UserSettings.ConsoleLogWin_Pos = self:GetPos()
  ChoGGi.UserSettings.ConsoleLogWin_Size = self:GetSize()
  Dialog.Done(self,result)
end

dlgChoGGi_ConsoleLogWin = rawget(_G, "dlgChoGGi_ConsoleLogWin") or false

function OnMsg.ConsoleLine(text, bNewLine)
  local dlg = dlgChoGGi_ConsoleLogWin
  if dlg then
    local old_text = dlg.idText:GetText()

    if bNewLine then
      text = Concat(old_text,"\n",text)
    else
      text = Concat(old_text,text)
    end
    dlg.idText:SetText(text)

    --always scroll to end of text
    dlg.idText.scroll:SetPosition(text:len())
  end
end
