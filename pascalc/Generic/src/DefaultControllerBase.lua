require("AbstractController")
require("Logger")

local log = Logger("DefaultControllerBase")

DefaultControllerBase = {}
DefaultControllerBase.__index = DefaultControllerBase

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
end

---
-- @function [parent=#DefaultControllerBase] p2v
--
-- This method assigns modulators from a patch
-- to all modulators in the panel
function DefaultControllerBase:p2v(patch, sendMidi)
  for i = 0, self.voiceSize do -- gets the voice parameter values
    local mod = self:getModulatorByCustomName(string.format("Voice%d", i))
    if mod ~= nil then
      mod:setValue(patch:getValue(i), false)
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

function DefaultControllerBase:loadData(data)
  local patch = nil
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
    patch = bank:getSelectedPatch()
  elseif midiSize == self.voiceSize then
    local status, tmp = pcall(self.standAlonePatchPointer, data)
    if not status then
      log:warn(cutils.getErrorMessage(tmp))
      utils.warnWindow ("Load Patch", cutils.getErrorMessage(tmp))
      return
    end
    patch = tmp
  else
    error("The loaded file does not contain valid sysex data")
    return
  end

  -- Assign values
  self:p2v(patch, true)
end

---
-- @function [parent=#DefaultControllerBase] onMidiReceived
--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   http://ctrlr.org/api/class_ctrlr_midi_message.html
function DefaultControllerBase:onMidiReceived(midi)
  self:loadData(midi:getData())
end

function DefaultControllerBase:loadVoiceFromFile(file)
  if file:existsAsFile() then
    local data = MemoryBlock()
    file:loadFileAsData(data)
    self:loadData(data)
  end
end

---
-- @function [parent=#DefaultControllerBase] sendMidiMessage
--
function DefaultControllerBase:sendMidiMessage(syxMsg)
  panel:sendMidiMessageNow(syxMsg:toMidiMessage())
end

---
-- @function [parent=#DefaultControllerBase] sendMidiMessages
--
function DefaultControllerBase:sendMidiMessages(msgs)
  for k, nextMsg in pairs(msgs) do
    self:sendMidiMessage(nextMsg)
  end
end
