require("AbstractController")
require("Logger")
require("cutils")

---
-- @field [parent=#DefaultControllerBase] log
--
local log = Logger("DefaultControllerBase")

DefaultControllerBase = {}
DefaultControllerBase.__index = DefaultControllerBase

setmetatable(DefaultControllerBase, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#DefaultControllerBase] _init
--
function DefaultControllerBase:_init(voiceSize, bankSize, standAlonePatchPointer, bankPointer)
  AbstractController._init(self)
  self.bank = bankPointer()
  self.bankPointer = bankPointer
  self.standAlonePatchPointer = standAlonePatchPointer
  self.receiveBuffer = nil
  self.receiveBankOffset = -1
  self.voiceSize = voiceSize
  self.bankSize = bankSize
  self.midiFunction = loadData
end

---
-- @function [parent=#DefaultControllerBase] p2v
--
-- This method assigns modulators from a patch
-- to all modulators in the panel
function DefaultControllerBase:p2v(patch, mute)
  mute = mute or false
  for i = 0, self.voiceSize do -- gets the voice parameter values
    local mod = self:getModulatorByCustomName(string.format("Voice%d", i))
    if mod ~= nil then
      mod:setValue(patch:getValue(i), false, mute)
    end

  end
  self:setText("Name1", patch:getPatchName())
end

---
-- @function [parent=#DefaultControllerBase] v2p
--
-- This method assembles the param values from
-- all modulators and stores them in a patch
function DefaultControllerBase:v2p(patch)
  -- run through all modulators and fetch their value
  for i = 0, self.voiceSize do
    local mod = self:getModulatorByCustomName(string.format("Voice%d", i))
    if mod ~= nil then
      patch:setValue(i, mod:getValue())
    end
  end

  patch:setPatchName(self:getText("Name1"))
end

---
-- @function [parent=#DefaultControllerBase] assignBank
--
-- This method stores the param values from all modulators
-- and stores them in a specified patch location of a bank
function DefaultControllerBase:assignBank(bank)
  self.bank = bank
  self.bank:setSelectedPatchIndex(0)
  self:p2v(bank:getSelectedPatch(), true)

  self:setValue("patchSelect", bank:getSelectedPatchIndex())
  self:toggleActivation("patchSelect", true)
end

---
-- @function [parent=#DefaultControllerBase] loadData
--
function DefaultControllerBase:loadData(data, mute)
  mute = mute or false
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
    self:p2v(patch, mute)
  else
    error(string.format("The loaded file does not contain valid sysex data: %s", data:toHexString(1)))
    return
  end
end

---
-- @function [parent=#DefaultControllerBase] requestDump
--
function DefaultControllerBase:requestDump(requestMessages)
  local midiMessageTimerIndex = 1002
  local prevMidiReceivedFunc = self.midiFunction
  local receivedMidiData = {}

  local onMidiMessageTimeout = function()
    -- Stop timer
    timer:stopTimer(midiMessageTimerIndex)
    self.midiFunction = prevMidiReceivedFunc

    AlertWindow.showMessageBox(AlertWindow.WarningIcon, "MIDI Timeout", "No MIDI response from synth received", "OK")
  end

  local midiReceived = function(myData)
    timer:stopTimer(midiMessageTimerIndex)
    table.insert(receivedMidiData, myData)

    if table.getn(requestMessages) > 0 then
      self:sendMidiMessage(table.remove(requestMessages, 1))
      timer:setCallback(midiMessageTimerIndex, onMidiMessageTimeout)
      timer:startTimer(midiMessageTimerIndex, 1000)
    else
      self.midiFunction = prevMidiReceivedFunc
      local data = cutils.mergeArrayOfMemBlocks(receivedMidiData)
      self:loadData(data, true)
    end
  end

  self.midiFunction = midiReceived
  self:sendMidiMessage(table.remove(requestMessages, 1))
  timer:setCallback(midiMessageTimerIndex, onMidiMessageTimeout)
  timer:startTimer(midiMessageTimerIndex, 1000)
end

---
-- @function [parent=#DefaultControllerBase] onMidiReceived
--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   http://ctrlr.org/api/class_ctrlr_midi_message.html
function DefaultControllerBase:onMidiReceived(midi)
  local data = midi:getData()
  if data:getByte(0) == 0xF0 and self.midiFunction ~= nil then
    self.midiFunction(data)
  end
end

---
-- @function [parent=#DefaultControllerBase] loadVoiceFromFile
--
function DefaultControllerBase:loadVoiceFromFile(file)
  if file:existsAsFile() then
    local data = MemoryBlock()
    file:loadFileAsData(data)
    self:loadData(data)
  end
end

---
-- @function [parent=#DefaultControllerBase] onLogLevelChanged
--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function DefaultControllerBase:onLogLevelChanged(mod, value)
  log:setLevel(value)
end

---
-- @function [parent=#DefaultControllerBase] onPatchSelect
--
-- This method assigns the selected patch to the panel modulators
function DefaultControllerBase:onPatchSelect(mod, value)
  if self.bank:isSelectedPatch(value) then
    return
  end

  self:setStatus("Loading patch...")

  --  if self.bank:hasPatchAt(value) then
  self:v2p(self.bank:getSelectedPatch())

  self.bank:setSelectedPatchIndex(value)
  self:p2v(self.bank:getSelectedPatch(), true)
  --  else
  --  end
end

---
-- @function [parent=#DefaultControllerBase] setStatus
--
function DefaultControllerBase:setStatus(status)
  self:setText("Name1", status)
end

---
-- @function [parent=#DefaultControllerBase] getStatus
--
function DefaultControllerBase:getStatus()
  return self:getText("Name1")
end

---
-- @function [parent=#DefaultControllerBase] saveBankToFile
--
-- Saves the current bank to file
function DefaultControllerBase:saveBankToFile()
  self:v2p(self.bank:getSelectedPatch())
  cutils.writeSyxDataToFile(self.bank:toStandaloneData(), utils.saveFileWindow ("Save bank", File(""), "*.syx", true))
end

---
-- @function [parent=#DefaultControllerBase] writeBankToSynth
--
-- Saves the current bank to file
function DefaultControllerBase:writeBankToSynth(interval)
  self:v2p(self.bank:getSelectedPatch())
  self:sendMidiMessages(self.bank:toSyxMessages(), interval)
end

---
-- @function [parent=#DefaultControllerBase] savePatchToFile
--
-- Saves the current bank to file
function DefaultControllerBase:savePatchToFile()
  local patch = self.bank:getSelectedPatch()
  self:v2p(patch)
  cutils.writeSyxDataToFile(patch:toStandaloneData(), utils.saveFileWindow ("Save patch", File(""), "*.syx", true))
end

---
-- @function [parent=#DefaultControllerBase] writePatchToSynth
--
-- Saves the current bank to file
function DefaultControllerBase:writePatchToSynth()
  local patch = self.bank:getSelectedPatch()
  self:v2p(patch)
  self:sendMidiMessage(patch:toSyxMsg())
end

---
-- @function [parent=#DefaultControllerBase] loadBankFromFile
--
function DefaultControllerBase:loadBankFromFile()
  -- Prompt user to save bank
  if not AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Overwrite bank?", "You have loaded a bank. The current action will overwrite your existing bank. Are you sure you want to continue?", "OK", "Cancel") then
    return
  end

  local file = utils.openFileWindow ("Open Bank", File(""), "*.syx", true)
  if file:existsAsFile() then
    local data = MemoryBlock()
    file:loadFileAsData(data)
    self:loadData(data)
  end
end
