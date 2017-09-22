require("AbstractController")
require("Logger")
require("model/Bank")
require("model/Patch")
require("model/StandalonePatch")
require("cutils")

local log = Logger("EmuProteus2Controller")


EmuProteus2Controller = {}
EmuProteus2Controller.__index = EmuProteus2Controller

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

local GetPresetNumber = function(presetData)
  local ll = presetData:getByte(5)
  local mm = presetData:getByte(6)
  return ll + (mm * 128)
end


setmetatable(EmuProteus2Controller, {
  __index = AbstractController, -- this is what makes the inheritance work
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
  AbstractController._init(self)
  self.bank = Bank()
  self.receiveBuffer = nil
  self.receiveBankOffset = -1
end

---
-- @function [parent=#EmuProteus2Controller] p2v
--
-- This method assigns modulators from a patch
-- to all modulators in the panel
function EmuProteus2Controller:p2v(patch, sendMidi)
  for i = 0, SINGLE_DATA_SIZE do -- gets the voice parameter values
    local mod = self:getModulatorByCustomName(string.format("Voice%d", i))
    if mod ~= nil then
      mod:setValue(patch:getValue(i), false)
    end

  end
  self:setText("Name1", patch:getPatchName())
end

---
-- @function [parent=#EmuProteus2Controller] v2p
--
-- This method assembles the param values from
-- all modulators and stores them in a patch
function EmuProteus2Controller:v2p(patch)
  -- run through all modulators and fetch their value
  for i = 0, SINGLE_DATA_SIZE do
    local mod = self:getModulatorByCustomName(string.format("Voice%d", i))
    if mod ~= nil then
      patch:setValue(i, mod:getValue())
    end
  end

  patch:setPatchName(self:getText("Name1"))
end

---
-- @function [parent=#EmuProteus2Controller] assignBank
--
-- This method stores the param values from all modulators
-- and stores them in a specified patch location of a bank
function EmuProteus2Controller:assignBank(bank)
  self.bank = bank
  self.bank:setSelectedPatchIndex(0)
  self:p2v(bank:getSelectedPatch(), true)

  self:setValue("patchSelect", bank:getSelectedPatchIndex())
  self:toggleActivation("patchSelect", true)
end

---
-- @function [parent=#EmuProteus2Controller] onMidiReceived
--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   http://ctrlr.org/api/class_ctrlr_midi_message.html
function EmuProteus2Controller:onMidiReceived(midi)
  local midiSize = midi:getData():getSize()
  if midiSize == BANK_BUFFER_SIZE then
    local status, bank = pcall(Bank, midi:getData())
    if status then
      self:assignBank(bank)
    else
      log:warn(cutils.getErrorMessage(bank))
      utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
    end
  elseif midiSize == SINGLE_DATA_SIZE then
    local status, patch = pcall(StandalonePatch, midi:getData())
    if status then
      self:p2v(patch, true)
    else
      log:warn(cutils.getErrorMessage(patch))
      utils.warnWindow ("Load Patch", cutils.getErrorMessage(patch))
    end
  end
end

function EmuProteus2Controller:loadVoiceFromFile(file)
  if file:existsAsFile() then
    local data = MemoryBlock()
    file:loadFileAsData(data)
    local patch = nil
    if data:getSize() == 16960 then
      local status, bank = pcall(Bank, data)
      if not status then
        log:warn(cutils.getErrorMessage(patch))
        utils.warnWindow ("Load Patch", cutils.getErrorMessage(patch))
        return
      end
      patch = bank:getSelectedPatch()
    elseif data:getSize() == 265 then
      local status, tmp = pcall(StandalonePatch, data)
      if not status then
        log:warn(cutils.getErrorMessage(tmp))
        utils.warnWindow ("Load Patch", cutils.getErrorMessage(tmp))
        return
      end
      patch = tmp
    else
      error("The loaded file does not contain a Behringer Modulizer patch")
      return
    end

    -- Assign values
    self:p2v(patch, true)
  end
end

function EmuProteus2Controller:onLoadVoice(mod, value)
  local file = utils.openFileWindow ("Open Patch", File(""), "*.syx", true)
  self:loadVoiceFromFile(file)
end

function EmuProteus2Controller:onSaveVoice(mod, value)
  local f = utils.saveFileWindow ("Save patch", File(""), "*.syx", true)
  if f:isValid() == false then
    return
  end
  f:create()
  if f:existsAsFile() then
    -- Fetch values

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
    if f:replaceWithData (data) == false then
      utils.warnWindow ("File write", "Sorry, the Editor failed to\nwrite the data to file!")
    end
    console ("File save complete, Editor patch saved to disk")
  end
end

---
-- @function [parent=#EnsoniqEsq1Controller] onSaveMenu
--
function EmuProteus2Controller:onSaveMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Patch to file", true, false, Image())
  menu:addItem(2, "Bank to file", true, false, Image())
  menu:addItem(3, "Bank to Proteus/2", true, false, Image())
  local ret = menu:show(0,0,0,0)
  if ret == 0 then
    return
  end
  if ret == 1 then
    local status, patch = pcall(Patch)
    if status then
      savePatch(self:v2p(patch))
    else
      log:warn(cutils.getErrorMessage(patch))
      utils.warnWindow ("Save Patch", cutils.getErrorMessage(patch))
    end
  elseif ret == 2 then
    self:v2p(self.bank:getSelectedPatch())
    saveBank(self.bank)
  elseif ret == 3 then
    -- This method instructs the user or synth to
    -- store the current patch
    self:v2p(self.bank:getSelectedPatch())
    self:sendMidiMessages(self.bank:toSyxMessages())
  end
end

function EmuProteus2Controller:onLoadMenu(mod, value)
  local menu = PopupMenu()    -- Main Menu
  menu:addItem(1, "Patch from file", true, false, Image())
  menu:addItem(2, "Bank from file", true, false, Image())
  menu:addItem(3, "Bank from Proteus/2", true, false, Image())
  local ret = menu:show(0,0,0,0)
  local patchSelectMod = panel:getModulatorByName("Voice_PatchSelectControl")
  local patchSelectComp = patchSelectMod:getComponent()
  if ret == 1 then
    -- Load Patch
    local alertValue = AlertWindow.showYesNoCancelBox(AlertWindow.InfoIcon, "Load patch", "Load patch.\nWhat do you want to do?", "Discard bank and load patch", "Insert patch in bank", "Cancel")
    if alertValue == false then return end

    local f = utils.openFileWindow ("Open Patch", File(""), "*.syx", true)
    self:loadVoiceFromFile(f)
  -- Load Bank
  elseif ret == 2 then
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
  elseif ret == 3 then
    Voice_ReceivePatch()
  end
end


---
-- @function [parent=#EmuProteus2Controller] sendMidiMessage
--
function EmuProteus2Controller:sendMidiMessage(syxMsg)
  panel:sendMidiMessageNow(syxMsg:toMidiMessage())
end

---
-- @function [parent=#EmuProteus2Controller] sendMidiMessages
--
function EmuProteus2Controller:sendMidiMessages(msgs)
  for k, nextMsg in pairs(msgs) do
    self:sendMidiMessage(nextMsg)
  end
end
