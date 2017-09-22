require("AbstractController")
require("Logger")
require("model/StandalonePatch")
require("model/Patch")
require("model/Bank")
require("message/AllProgDumpRequest")
require("message/SingleProgDumpRequest")
require("cutils")

local log = Logger("EnsoniqEsq1Controller")

EnsoniqEsq1Controller = {}
EnsoniqEsq1Controller.__index = EnsoniqEsq1Controller

local getPatchStart = function (patchNum)
  return SINGLE_DATA_SIZE * patchNum + HEADER_SIZE
end

-- This method saves the current patch to file
local savePatch = function(patch)
  local f = utils.saveFileWindow ("Save patch", File(""), "*.syx", true)
  if f:isValid() == false then
    return
  end
  f:create()
  if f:existsAsFile() then
    -- Check if the file exists
    if f:existsAsFile() == false then
      -- If file does not exist, then create it
      if f:create() == false then
        -- If file cannot be created, then fail here
        utils.warnWindow ("\n\nSorry, the Editor failed to\nsave the patch to disk!", "The file does not exist.")
        return
      end
    end
    -- If we reached this point, we have a valid file we can try to write to
    if f:replaceWithData (patch:toStandaloneData()) == false then
      utils.warnWindow ("File write", "Sorry, the Editor failed to\nwrite the data to file!")
    end
  end
end

-- This method saves the current bank to file
local saveBank = function(bank)
  local f = utils.saveFileWindow ("Save Bank", File(""), "*.syx", true)
  if f:isValid() == false then
    return
  end

  if f:existsAsFile() then
    f:deleteFile()
  end

  f:create()
  if f:existsAsFile() then
    local dataToWrite = bank:toStandaloneData()
    if f:replaceWithData (dataToWrite) == false then
      utils.warnWindow ("File write", "Sorry, the Editor failed to\nwrite the data to file!")
    end
  end
end

setmetatable(EnsoniqEsq1Controller, {
  __index = AbstractController, -- this is what makes the inheritance work
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
  AbstractController._init(self)
  self.bank = Bank()
  self.receiveBuffer = nil
  self.receiveBankOffset = -1
end

---
-- @function [parent=#EnsoniqEsq1Controller] p2v
--
-- This method assigns modulators from a patch
-- to all modulators in the panel
function EnsoniqEsq1Controller:p2v(patch, midi)
  -- gets the voice parameter values
  for i = 1,132 do
    local name = string.format("Voice%d", i)
    local mod = self:getModulatorByCustomName(name)
    if mod ~= nil then
      self:setValueByCustomName(name, patch:getValue(i))
    end
  end
  self:setText("Name1", patch:getPatchName())
end

---
-- @function [parent=#EnsoniqEsq1Controller] v2p
--
-- This method assembles the param values from
-- all modulators and stores them in a patch
function EnsoniqEsq1Controller:v2p(patch)
  -- run through all modulators and fetch their value
  for i = 1, 132 do
    local mod = self:getModulatorByCustomName(string.format("Voice%d", i))
    if mod ~= nil then
      patch:setValue(i, mod:getValue())
    end
  end

  patch:setPatchName(self:getText("Name1"))
end

---
-- @function [parent=#EnsoniqEsq1Controller] assignBank
--
-- This method stores the param values from all modulators
-- and stores them in a specified patch location of a bank
function EnsoniqEsq1Controller:assignBank(bank)
  self.bank = bank
  self.bank:setSelectedPatchIndex(0)
  self:p2v(bank:getSelectedPatch(), true)

  self:setValue("patchSelect", bank:getSelectedPatchIndex())
  self:toggleActivation("patchSelect", true)
end

---
-- @function [parent=#EnsoniqEsq1Controller] onMidiReceived
--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   http://ctrlr.org/api/class_ctrlr_midi_message.html
function EnsoniqEsq1Controller:onMidiReceived(midi)
  local midiSize = midi:getData():getSize()
  if midiSize == BANK_BUFFER_SIZE then
    local status, bank = pcall(Bank, midi:getData())
    if status then
      self:assignBank(bank)
    else
      log:warn(cutils.getErrorMessage(bank))
      utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
    end
  elseif midiSize == PATCH_BUFFER_SIZE then
    local status, patch = pcall(StandalonePatch, midi:getData())
    if status then
      self:p2v(patch, true)
    else
      log:warn(cutils.getErrorMessage(patch))
      utils.warnWindow ("Load Patch", cutils.getErrorMessage(patch))
    end
  end
end

---
-- @function [parent=#EnsoniqEsq1Controller] onLogLevelChanged
--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function EnsoniqEsq1Controller:onLogLevelChanged(mod, value)
  log:setLevel(value)
end

---
-- @function [parent=#EnsoniqEsq1Controller] onPatchSelect
--
-- This method assigns the selected patch to the panel modulators
function EnsoniqEsq1Controller:onPatchSelect(mod, value)
  if self.bank:isSelectedPatch(value) then
    return
  end

  self:v2p(self.bank:getSelectedPatch())

  self.bank:setSelectedPatchIndex(value)
  self:p2v(self.bank:getSelectedPatch(), true)
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
    local patch = self.bank:getSelectedPatch()
    savePatch(self:v2p(patch))
  elseif ret == 2 then
    self:v2p(self.bank:getSelectedPatch())
    saveBank(self.bank)
  elseif ret == 3 then
    local patch = self.bank:getSelectedPatch()
    self:v2p(patch)
    self:sendMidiMessage(patch:toSyxMsg())
  elseif ret == 4 then
    self:sendMidiMessage(self.bank:toSyxMessage())
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
    -- Prompt user to save bank
    if not AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Overwrite bank?", "You have loaded a bank. The current action will overwrite your existing bank. Are you sure you want to continue?", "OK", "Cancel") then
      return
    end

    local f = utils.openFileWindow ("Open Bank", File(""), "*.syx", true)
    if f:existsAsFile() then
      local loadedData = MemoryBlock()
      f:loadFileAsData(loadedData)

      local status, bank = pcall(Bank, loadedData)
      if status then
        self:assignBank(bank)
      else
        log:warn(cutils.getErrorMessage(bank))
        utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
      end
    end
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

---
-- @function [parent=#EnsoniqEsq1Controller] sendMidiMessage
--
function EnsoniqEsq1Controller:sendMidiMessage(syxMsg)
  panel:sendMidiMessageNow(syxMsg:toMidiMessage())
end

---
-- @function [parent=#EnsoniqEsq1Controller] sendMidiMessages
--
function EnsoniqEsq1Controller:sendMidiMessages(msgs)
  for k, nextMsg in pairs(msgs) do
    self:sendMidiMessage(nextMsg)
  end
end
