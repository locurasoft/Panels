require("DefaultControllerBase")
require("Logger")
require("model/YamahaDX7Bank")
require("model/YamahaDX7Patch")
require("cutils")

local log = Logger("YamahaDX7Controller")

YamahaDX7Controller = {}
YamahaDX7Controller.__index = YamahaDX7Controller

setmetatable(YamahaDX7Controller, {
  __index = DefaultControllerBase, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#YamahaDX7Controller] _init
--
function YamahaDX7Controller:_init()
  DefaultControllerBase._init(self, PATCH_BUFFER_SIZE, BANK_BUFFER_SIZE, YamahaDX7Patch, YamahaDX7Bank)
end

function Voice_CalculateChecksum (sysex, csStart, csEnd, csOfs)
  csStart = csStart or Voice_checksumStart
  csEnd = csEnd or Voice_checksumEnd
  csOfs = csOfs or Voice_checksumOffset
  local sum = 0
  if csEnd < 0 then
    csEnd = sysex:getSize() + csEnd
  end

  for i = csStart, csEnd do
    sum = sum + sysex:getByte(i)
  end

  sysex:setByte(csOfs, (bit.band( - sum, 0x7f)))
end

---
-- @function [parent=#YamahaDX7Controller] onMidiReceived
--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   http://ctrlr.org/api/class_ctrlr_midi_message.html
function YamahaDX7Controller:onMidiReceived(midi)
  local data = midi:getData()
  if data:getSize() == PERFORMANCE_BUFFER_SIZE then
    for i = Voice_dxSysexHeaderSize, PERFORMANCE_BUFFER_SIZE do -- gets the voice parameter values
      local mod = self:getModulatorByCustomName(string.format("pp%d", i - Voice_dxSysexHeaderSize))
      if mod ~= nil and mod:getProperty("modulatorCustomName") ~= nil then
        mod:setValue(data:getByte(i), false)
      end
    end
  else
    self:loadData(midi:getData())
  end
end

---
-- @function [parent=#YamahaDX7Controller] onDisableMemoryProtect
--
function YamahaDX7Controller:onDisableMemoryProtect(mod, value)
  local syxMsgs = {
    ButtonPressSyxMsg(0x21),
    ButtonReleaseSyxMsg(0x21),
    ButtonPressSyxMsg(0x28),
    ButtonReleaseSyxMsg(0x28),
    ButtonPressSyxMsg(0x25),
    ButtonReleaseSyxMsg(0x25),
    ButtonPressSyxMsg(0x27),
    ButtonReleaseSyxMsg(0x27),
    ButtonPressSyxMsg(0x0d),
    ButtonReleaseSyxMsg(0x0d),
    ButtonPressSyxMsg(0x07),
    ButtonReleaseSyxMsg(0x07),
    ButtonPressSyxMsg(0x07),
    ButtonReleaseSyxMsg(0x07),
    ButtonPressSyxMsg(0x29),
    ButtonReleaseSyxMsg(0x29)
  }
  self:sendMidiMessages(syxMsgs, 50)
end

---
-- @function [parent=#YamahaDX7Controller] receiveBank
--
function YamahaDX7Controller:receiveBank()
  local syxMsgs = {
    ButtonPressSyxMsg(0x27),
    ButtonReleaseSyxMsg(0x27),
    ButtonPressSyxMsg(0x0d),
    ButtonReleaseSyxMsg(0x0d),
    ButtonPressSyxMsg(0x07),
    ButtonReleaseSyxMsg(0x07),
    ButtonPressSyxMsg(0x07),
    ButtonReleaseSyxMsg(0x07),
    ButtonPressSyxMsg(0x29),
    ButtonReleaseSyxMsg(0x29),
    ButtonPressSyxMsg(0x07),
    ButtonReleaseSyxMsg(0x07),
    ButtonPressSyxMsg(0x29),
    ButtonReleaseSyxMsg(0x29),
    ButtonPressSyxMsg(0x25),
    ButtonReleaseSyxMsg(0x25)
  }
  self:sendMidiMessages(syxMsgs, 50)
end

---
-- @function [parent=#YamahaDX7Controller] receivePatch
--
function YamahaDX7Controller:receivePatch()
  local syxMsgs = {
    ButtonPressSyxMsg(0x27),
    ButtonReleaseSyxMsg(0x27),
    ButtonPressSyxMsg(0x0d),
    ButtonReleaseSyxMsg(0x0d),
    ButtonPressSyxMsg(0x07),
    ButtonReleaseSyxMsg(0x07),
    ButtonPressSyxMsg(0x07),
    ButtonReleaseSyxMsg(0x07),
    ButtonPressSyxMsg(0x29),
    ButtonReleaseSyxMsg(0x29),
    ButtonPressSyxMsg(0x25),
    ButtonReleaseSyxMsg(0x25),
    ButtonPressSyxMsg(0x00),
    ButtonReleaseSyxMsg(0x00)
  }
  self:sendMidiMessages(syxMsgs, 50)
end


---
-- @function [parent=#YamahaDX7Controller] onSaveMenu
--
function YamahaDX7Controller:onSaveMenu(mod, value)
  if value < 0 then
    return
  end

  if value == 0 then
    local display = panel:getModulatorByName("info-lbl"):getComponent()
    display:setText("Saving bank...")
    self:writeBankToSynth(50)
  elseif value == 1 then
    self:saveBankToFile()
  elseif value == 2 then
    self:savePatchToFile()
  end
  mod:setValue(-1, false)
--  SetInfoLabelVisibility(false)
--  SetPatchNameVisibility(true)
end

---
-- @function [parent=#YamahaDX7Controller] onLoadMenu
--
function YamahaDX7Controller:onLoadMenu(mod, value)
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

    local f = utils.openFileWindow ("Open Patch", File(""), "*.syx", true)
    if f:existsAsFile() then
      local loadedData = MemoryBlock()
      f:loadFileAsData(loadedData)
      local status, patch = pcall(StandalonePatch, loadedData)
      if status then
        self:p2v(patch, true)
      else
        log:warn(cutils.getErrorMessage(patch))
        utils.warnWindow ("Load Patch", cutils.getErrorMessage(patch))
      end
    end
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
