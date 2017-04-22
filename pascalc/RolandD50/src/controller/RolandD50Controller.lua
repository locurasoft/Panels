require("AbstractController")
require("Logger")
require("cutils")

local log = Logger("RolandD50Controller")
local UPPER, LOWER = 0, 1
local BANK_BUFFER_SIZE = 36048

RolandD50Controller = {}
RolandD50Controller.__index = RolandD50Controller

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

setmetatable(RolandD50Controller, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RolandD50Controller:_init()
  AbstractController._init(self)
  self.bank = Bank()
  self.receiveBuffer = nil
  self.receiveBankOffset = -1
end

function RolandD50Controller:assignBank(bank)
  self.bank = bank
  self.bank:setSelectedPatchIndex(0)
  self:p2v(bank:getSelectedPatch(), true)

  self:setValue("Voice_PatchSelectControl", bank:getSelectedPatchIndex())
  self:toggleActivation("Voice_PatchSelectControl", true)
end

-- This method assigns patch data from a memory block
-- to all modulators in the panel
function RolandD50Controller:p2v(patch, sendMidi)
  -- gets the voice parameter values
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
    midiService:sendMidiMessage(patch:toSyxMsg())
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

  self:toggleLayerVisibility(string.format("UP1PCM", tone), p1 and tone == UPPER)
  self:toggleLayerVisibility(string.format("UP2PCM", tone), p2 and tone == UPPER)
  self:toggleLayerVisibility(string.format("LP1PCM", tone), p1 and tone == LOWER)
  self:toggleLayerVisibility(string.format("LP2PCM", tone), p2 and tone == LOWER)
end

--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--
function RolandD50Controller:onMidiReceived(midi)
  local data = midi:getData()
  local midiSize = data:getSize()
  log:warn("onMidiReceived %d + %d = %d", midiSize, self.receiveBankOffset, midiSize + self.receiveBankOffset)
  if self.receiveBuffer ~= nil then
    self.receiveBuffer:copyFrom(data, self.receiveBankOffset, midiSize)
    self.receiveBankOffset = self.receiveBankOffset + midiSize

    if self.receiveBankOffset == BANK_BUFFER_SIZE then
      local status, bank = pcall(Bank, self.receiveBuffer)
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
  --  if midiSize == 458 then
  --    -------------------- process Voice patch data ----------------------------------------
  --    local status, patch = pcall(StandalonePatch, data)
  --    if status then
  --      self:p2v(patch, false)
  --    else
  --      log:warn(cutils.getErrorMessage(patch))
  --      utils.warnWindow ("Load Patch", cutils.getErrorMessage(patch))
  --    end
  --  elseif midiSize == BANK_BUFFER_SIZE then
  --    -------------------- process Voice bank data ----------------------------------------
  --    local status, bank = pcall(Bank, data)
  --    if status then
  --      self:assignBank(bank)
  --    else
  --      log:warn(cutils.getErrorMessage(bank))
  --      utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
  --    end
  --  end
end

--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function RolandD50Controller:onLogLevelChanged(mod, value)
  log:setLevel(value)
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
  if mod:getProperty("modulatorCustomName") == "Voice138" then
    self:updateStructures(UPPER, value)
  elseif mod:getProperty("modulatorCustomName") == "Voice330" then
    self:updateStructures(LOWER, value)
  else
    log:warn("Wrong modulator trigger called %s", mod:getName())
  end
end

-- This method assigns the selected patch to the panel modulators
function RolandD50Controller:onPatchSelect(mod, value)
  if self.bank:isSelectedPatch(value) then
    return
  end

  self:v2p(self.bank:getSelectedPatch())

  self.bank:setSelectedPatchIndex(value)
  self:p2v(self.bank:getSelectedPatch(), true)
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
    AlertWindow.showMessageBox(AlertWindow.InfoIcon, "Information", "Hold down the \"DATA TRANSFER\" button then press \"(B.LOAD)\".\nRelease the two buttons and press \"ENTER\".\nOnce the D-50 is in waiting for data press \"OK\" to close this popup.", "OK")

    self:v2p(self.bank:getSelectedPatch())
    midiService:sendMidiMessages(self.bank:toSyxMessages())
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

    self.receiveBuffer = MemoryBlock(BANK_BUFFER_SIZE, true)
    self.receiveBankOffset = 0

    AlertWindow.showMessageBox(AlertWindow.InfoIcon, "Information", "Perform a Bulk dump for the Roland D-50 Voice Bank by pressing the \"B.Dump\" button whie holding down \"Data Transfer\".\n\nPress OK when D-50 says \"Complete.\"", "OK")
  else
    return
  end
end
