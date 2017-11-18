require("DefaultControllerBase")
require("Logger")
require("model/EnsoniqEsq1StandalonePatch")
require("model/EnsoniqEsq1Patch")
require("model/EnsoniqEsq1Bank")
require("message/AllProgDumpRequest")
require("message/SingleProgDumpRequest")
require("cutils")

local log = Logger("EnsoniqEsq1Controller")

EnsoniqEsq1Controller = {}
EnsoniqEsq1Controller.__index = EnsoniqEsq1Controller

setmetatable(EnsoniqEsq1Controller, {
  __index = DefaultControllerBase, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#EnsoniqEsq1Controller] _init
--
function EnsoniqEsq1Controller:_init()
  DefaultControllerBase._init(self, PATCH_BUFFER_SIZE, BANK_BUFFER_SIZE, EnsoniqEsq1StandalonePatch, EnsoniqEsq1Bank)
end

function EnsoniqEsq1Controller:loadData(data)
  local midiSize = data:getSize()
  if midiSize == self.bankSize then
    local status, bank = pcall(self.bankPointer, data)
    if status then
      self:assignBank(bank)
    else
      log:warn(cutils.getErrorMessage(bank))
      utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
      return
    end
  elseif midiSize == self.voiceSize then
    local status, patch = pcall(self.standAlonePatchPointer, data)
    if not status then
      log:warn(cutils.getErrorMessage(patch))
      utils.warnWindow ("Load Patch", cutils.getErrorMessage(patch))
      return
    end
    -- Assign values
    self:p2v(patch, true)
  end
end


---
-- @function [parent=#EnsoniqEsq1Controller] onSaveMenu
--
function EnsoniqEsq1Controller:onSaveMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Patch to file", true, false, Image())
  menu:addItem(2, "Bank to file", true, false, Image())
  menu:addItem(3, "Patch to ESQ-1", true, false, Image())
  menu:addItem(4, "Bank to ESQ-1", true, false, Image())
  local ret = menu:show(0,0,0,0)
  if ret == 1 then
    self:savePatchToFile()
  elseif ret == 2 then
    self:saveBankToFile()
  elseif ret == 3 then
    self:writePatchToSynth()  
  elseif ret == 4 then
    self:writeBankToSynth(10)
  end
end

---
-- @function [parent=#EnsoniqEsq1Controller] onLoadMenu
--
function EnsoniqEsq1Controller:onLoadMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Patch from file", true, false, Image())
  menu:addItem(2, "Bank from file", true, false, Image())
  menu:addItem(3, "Patch from ESQ-1", true, false, Image())
  menu:addItem(4, "Bank from ESQ-1", true, false, Image())
  local menuSelect = menu:show(0,0,0,0)
  if menuSelect == 1 then
    -- Load Patch
    local alertValue = AlertWindow.showYesNoCancelBox(AlertWindow.InfoIcon, "Load patch", "Load patch.\nWhat do you want to do?", "Discard bank and load patch", "Insert patch in bank", "Cancel")
    if alertValue == false then return end

    local loadedData = cutils.getSyxAsMemBlock(utils.openFileWindow ("Open Patch", File(""), "*.syx", true))
    self:loadData(loadedData)
  -- Load Bank
  elseif menuSelect == 2 then
    self:loadBankFromFile()
  elseif menuSelect == 3 then
    -- This method instructs the synth or user
    -- to perform a single patch dump
    -- Prompt user to save bank
    if not AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Overwrite bank?", "You have loaded a bank. The current action will overwrite your existing bank. Are you sure you want to continue?", "OK", "Cancel") then
      return
    end
    self:sendMidiMessage(SingleProgDumpRequest())
  elseif menuSelect == 4 then
    self:sendMidiMessage(AllProgDumpRequest())
  end
end
