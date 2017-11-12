require("DefaultControllerBase")
require("Logger")
require("model/RolandD50Bank")
require("model/RolandD50Patch")
require("model/RolandD50StandalonePatch")
require("cutils")

local log = Logger("RolandD50Controller")
local UPPER, LOWER = 0, 1
local BANK_BUFFER_SIZE = 36048
local PATCH_BUFFER_SIZE = 458

RolandD50Controller = {}
RolandD50Controller.__index = RolandD50Controller

setmetatable(RolandD50Controller, {
  __index = DefaultControllerBase, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#RolandD50Controller] _init
--
function RolandD50Controller:_init()
  DefaultControllerBase._init(self, PATCH_BUFFER_SIZE, BANK_BUFFER_SIZE, RolandD50StandalonePatch, RolandD50Bank)
end

-- This method assigns patch data from a memory block
-- to all modulators in the panel
function RolandD50Controller:p2v(patch, sendMidi)
  -- gets the voice parameter values
  self:setValue("toneSelector", 0)

  for i = 0, Voice_singleSize do
    local mod = panel:getModulatorWithProperty("modulatorCustomName", string.format("Voice%d", i))
    if mod ~= nil and i ~= 174 and i ~= 366 then
      mod:setModulatorValue(patch:getValue(i), false, false, false)
    end
  end

  self:setValue("UpperPartial1", patch:getUpperPartial1Value())
  self:setValue("UpperPartial2", patch:getUpperPartial2Value())
  self:setValue("LowerPartial1", patch:getLowerPartial1Value())
  self:setValue("LowerPartial2", patch:getLowerPartial2Value())

  -- Set Patch name
  self:setText("Name1", patch:getPatchName())
  self:setText("VoiceName12", patch:getUpperToneName())
  self:setText("VoiceName123", patch:getLowerToneName())

  if sendMidi == true then
    self:sendMidiMessage(patch:toSyxMsg())
  end
end

-- This method assembles the param values from
-- all modulators and stores them in a memory block
function RolandD50Controller:v2p(patch)
  for i = 0, Voice_singleSize - 1 do -- run through all modulators and fetch their value
    local mod = panel:getModulatorWithProperty("modulatorCustomName", string.format("Voice%d", i))
    if mod ~= nil and i ~= 174 and i ~= 366 then
      patch:setValue(i, mod:getValue())
    end
  end

  patch:setUpperPartialValue(self:getValue("UpperPartial1"), self:getValue("UpperPartial2"))
  patch:setLowerPartialValue(self:getValue("LowerPartial1"), self:getValue("LowerPartial2"))

  patch:setPatchName(self:getText("Name1"))
  patch:setUpperToneName(self:getText("VoiceName12"))
  patch:setLowerToneName(self:getText("VoiceName123"))

  return patch
end

function RolandD50Controller:updateStructures(tone, value)
  local p1 = false
  local p2 = false
  if value == 0 or value == 1 then
    p1 = false
    p2 = false
  elseif value == 2 or value == 3 then
    p1 = true
    p2 = false
  elseif value == 4 then
    p1 = false
    p2 = true
  elseif value == 5 or value == 6 then
    p1 = true
    p2 = true
  else
    log:warn("Invalid structure value %d", value)
  end

  self:toggleLayerVisibility("UP1PCM", p1 and tone == UPPER)
  self:toggleLayerVisibility("UP2PCM", p2 and tone == UPPER)
  self:toggleLayerVisibility("LP1PCM", p1 and tone == LOWER)
  self:toggleLayerVisibility("LP2PCM", p2 and tone == LOWER)
  self:toggleLayerVisibility("UP1WAV", not p1 and tone == UPPER)
  self:toggleLayerVisibility("UP2WAV", not p2 and tone == UPPER)
  self:toggleLayerVisibility("LP1WAV", not p1 and tone == LOWER)
  self:toggleLayerVisibility("LP2WAV", not p2 and tone == LOWER)
end

-- @function [parent=#RolandD50Controller] onMidiReceived
--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   http://ctrlr.org/api/class_ctrlr_midi_message.html
function RolandD50Controller:onMidiReceived(midi)
  local data = midi:getData()
  local midiSize = data:getSize()
  if self.receiveBuffer ~= nil then
    self.receiveBuffer:copyFrom(data, self.receiveBankOffset, midiSize)
    self.receiveBankOffset = self.receiveBankOffset + midiSize

    if self.receiveBankOffset == BANK_BUFFER_SIZE then
      local status, bank = pcall(RolandD50Bank, self.receiveBuffer)
      if status then
        self:assignBank(bank)
      else
        log:warn(cutils.getErrorMessage(bank))
        utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
      end
      self.receiveBuffer = nil
      self.receiveBankOffset = -1
    end
  end
end

--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function RolandD50Controller:onToggleTone(mod, value)
  self:toggleLayerVisibility("UpperTone", value == UPPER)
  self:toggleLayerVisibility("LowerTone", value == LOWER)

  local structVal = self:getValueByCustomName("Voice138")
  if value == LOWER then
    structVal = self:getValueByCustomName("Voice330")
  end
  self:updateStructures(value, structVal)
end

--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function RolandD50Controller:onStructureChange(mod, value)
  if mod:getProperty("modulatorCustomName") == "Voice138" and self:getValue("toneSelector") == UPPER then
    self:updateStructures(UPPER, value)
  elseif mod:getProperty("modulatorCustomName") == "Voice330" and self:getValue("toneSelector") == LOWER then
    self:updateStructures(LOWER, value)
  end
end

-- This method set the values of the hidden char modulators
-- to match the given name
function RolandD50Controller:onSetPatchName(mod, value)
  self.bank:getSelectedPatch():setPatchName(value)
end

function RolandD50Controller:onUpperToneName(mod, value)
  self.bank:getSelectedPatch():setUpperToneName(value)
end

function RolandD50Controller:onLowerToneName(mod, value)
  self.bank:getSelectedPatch():setLowerToneName(value)
end

function RolandD50Controller:onSaveMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Patch to file", true, false, Image())
  menu:addItem(2, "Bank to file", true, false, Image())
  menu:addItem(3, "Bank to D-50", true, false, Image())
  local ret = menu:show(0,0,0,0)
  if ret == 1 then
    local status, patch = pcall(RolandD50Patch)
    if status then
      self:v2p(patch)
      cutils.writeSyxDataToFile(patch:toStandaloneData())
    else
      log:warn(cutils.getErrorMessage(patch))
      utils.warnWindow ("Save Patch", cutils.getErrorMessage(patch))
    end
  elseif ret == 2 then
    self:saveBankToFile()
  elseif ret == 3 then
    -- This method instructs the user or synth to
    -- store the current patch
    AlertWindow.showMessageBox(AlertWindow.InfoIcon, "Information", "Hold down the \"DATA TRANSFER\" button then press \"(B.LOAD)\".\nRelease the two buttons and press \"ENTER\".\nOnce the D-50 is in waiting for data press \"OK\" to close this popup.", "OK")

    self:v2p(self.bank:getSelectedPatch())
    self:sendMidiMessages(self.bank:toSyxMessages(), 10)
  else
    return
  end
end

function RolandD50Controller:onLoadMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Patch from file", true, false, Image())
  menu:addItem(2, "Bank from file", true, false, Image())
  menu:addItem(3, "Bank from D-50", true, false, Image())
  local menuSelect = menu:show(0,0,0,0)
  if menuSelect == 1 then
    -- Load Patch
    local alertValue = AlertWindow.showYesNoCancelBox(AlertWindow.InfoIcon, "Load patch", "Load patch.\nWhat do you want to do?", "Discard bank and load patch", "Insert patch in bank", "Cancel")
    if alertValue == false then return end

    local f = utils.openFileWindow ("Open Patch", File(""), "*.syx", true)
    if f:existsAsFile() then
      local loadedData = MemoryBlock()
      f:loadFileAsData(loadedData)
      local status, patch = pcall(RolandD50StandalonePatch, loadedData)
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

    self.receiveBuffer = MemoryBlock(BANK_BUFFER_SIZE, true)
    self.receiveBankOffset = 0

    AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Information", "Perform a Bulk dump for the Roland D-50 Voice Bank by pressing the \"B.Dump\" button whie holding down \"Data Transfer\".\n\nPress OK when D-50 says \"Complete.\"", "OK", "Cancel")
    self.receiveBuffer = nil
    self.receiveBankOffset = -1
  else
    return
  end
end
