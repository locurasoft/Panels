require("DefaultControllerBase")
require("Logger")
require("model/EmuProteus2Bank")
require("model/EmuProteus2Patch")
require("model/EmuProteus2StandalonePatch")
require("cutils")

local log = Logger("EmuProteus2Controller")


EmuProteus2Controller = {}
EmuProteus2Controller.__index = EmuProteus2Controller

local GetPresetNumber = function(presetData)
  local ll = presetData:getByte(5)
  local mm = presetData:getByte(6)
  return ll + (mm * 128)
end

setmetatable(EmuProteus2Controller, {
  __index = DefaultControllerBase, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#EmuProteus2Controller] _init
--
function EmuProteus2Controller:_init()
  DefaultControllerBase._init(self, SINGLE_DATA_SIZE, BANK_BUFFER_SIZE, EmuProteus2StandalonePatch, EmuProteus2Bank)
end

---
-- @function [parent=#EmuProteus2Controller] onSaveMenu
--
function EmuProteus2Controller:onSaveMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Patch to file", true, false, Image())
  menu:addItem(2, "Bank to file", true, false, Image())
  menu:addItem(3, "Bank to Proteus/2", true, false, Image())
  local ret = menu:show(0,0,0,0)
  if ret == 1 then
    local patch = self.bank:getSelectedPatch()
    self:v2p(patch)
    cutils.writeSyxDataToFile(patch:toStandaloneData())
  elseif ret == 2 then
    self:saveBankToFile()
  elseif ret == 3 then
    -- This method instructs the user or synth to
    -- store the current patch
    self:v2p(self.bank:getSelectedPatch())
    self:sendMidiMessages(self.bank:toSyxMessages(), 100)
  end
end

---
-- @function [parent=#EmuProteus2Controller] onLoadMenu
--
function EmuProteus2Controller:onLoadMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Patch from file", true, false, Image())
  menu:addItem(2, "Bank from file", true, false, Image())
  menu:addItem(3, "Bank from Proteus/2", true, false, Image())
  local ret = menu:show(0,0,0,0)
  if ret == 1 then
    -- Load Patch
    local alertValue = AlertWindow.showYesNoCancelBox(AlertWindow.InfoIcon, "Load patch", "Load patch.\nWhat do you want to do?", "Discard bank and load patch", "Insert patch in bank", "Cancel")
    if alertValue == false then return end

    local f = utils.openFileWindow ("Open Patch", File(""), "*.syx", true)
    self:loadVoiceFromFile(f)
    -- Load Bank
  elseif ret == 2 then
    self:loadBankFromFile()
  elseif ret == 3 then
    -- Prompt user to save bank
    if not AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Overwrite bank?", "You have loaded a bank. The current action will overwrite your existing bank. Are you sure you want to continue?", "OK", "Cancel") then
      return
    end
    self:requestDump({ AllUserPresetsRequest(), AllFactoryPresetsRequest() })
  end
end

---
-- @function [parent=#EmuProteus2Controller] onPatchSelect
-- This method assigns the selected patch to the panel modulators 
function EmuProteus2Controller:onPatchSelect (mod, value)

  if VoiceBankData == nil then
    mod:getComponent():setProperty("componentDisabled", 1, false)
    return
  end

  if VoiceUpdateBank == true then
    VoiceUpdateBank = false
    mod:setValue(Voice_SelectedPatchIndex, false)
    return
  end

  if value < 0 then
    return
  end

  log:debug("Voice_PatchSelect %d - %d", value + 1, Voice_SelectedPatchIndex)
  if (value + 1) ~= Voice_SelectedPatchIndex then
    if Voice_SelectedPatchIndex > 0 then
      local oldData = Voice_AssembleValues()
      Voice_putPatch(oldData, Voice_SelectedPatchIndex)
    end
    Voice_SelectedPatchIndex = value + 1
    local patchData = Voice_getPatch(Voice_SelectedPatchIndex)
    Voice_AssignValues(patchData, true)
  end
end

---
-- @function [parent=#EmuProteus2Controller] onGetValueForMIDI
--
function EmuProteus2Controller:onGetValueForMIDI(mod, value)
  return emuProteus2InstrumentService:c2m(value)
end

---
-- @function [parent=#EmuProteus2Controller] onGetValueFromMIDI
--
function EmuProteus2Controller:onGetValueFromMIDI(mod, value)
  return emuProteus2InstrumentService:m2c(value)
end
