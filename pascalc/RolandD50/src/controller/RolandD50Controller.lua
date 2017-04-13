require("AbstractController")
require("Logger")

local log = Logger("RolandD50Controller")
local LOWER, UPPER = 0, 1

RolandD50Controller = {}
RolandD50Controller.__index = RolandD50Controller

local isAbortLoadBank = function(hasLoadedBank)
  local alertValue = false
  if hasLoadedBank then
    -- Prompt user to save bank
    alertValue = AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Overwrite bank?", "You have loaded a bank. The current action will overwrite your existing bank. Are you sure you want to continue?", "OK", "Cancel")
  else
    -- Prompt user to save patch
    alertValue = AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Overwrite patch?", "This action will overwrite your existing patch. Are you sure you want to continue?", "OK", "Cancel")
  end
  return alertValue
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
    log:fine("File save complete, Editor patch saved to disk")
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
    log:warn("File save complete, Editor patch saved to disk")
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
  self.bank = nil
end

function RolandD50Controller:hasLoadedBank()
  return VoiceBankData ~= nil
end

--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--
function RolandD50Controller:onMidiReceived(midi)
  local data = midi:getData()
  local midiSize = data:getSize()
  if midiSize == 458 then
    -------------------- process Voice patch data ----------------------------------------
    self:assignValues(data, false)
    self.bank = nil
    self:toggleActivation("Voice_PatchSelectControl", false)
  end
  ---------------------------------------------------------------------------------
  if midiSize == 36048 then
    -------------------- process Voice bank data ----------------------------------------
    self:assignBank(data)
  end
  ---------------------------------------------------------------------------------
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
  log:fine("togglePart %d", value)

  self:toggleLayerVisibility("UpperTone", value == UPPER)
  self:toggleLayerVisibility("LowerTone", value == LOWER)
end

--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function RolandD50Controller:onStructureChange(mod, value)
  local tone = "U"

  if mod:getProperty("modulatorCustomName") == "Voice138" then
    tone = "U"
  elseif mod:getProperty("modulatorCustomName") == "Voice330" then
    tone = "L"
  else
    log:warn("Wrong modulator trigger called %s", mod:getName())
    return
  end

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

  self:toggleLayerVisibility(string.format("%sP1PCM", tone), p1)
  self:toggleLayerVisibility(string.format("%sP2PCM", tone), p2)
end

-- This method assigns the selected patch to the panel modulators
function RolandD50Controller:onPatchSelect(mod, value)
  self:toggleActivation(mod:getName(), not self:hasLoadedBank())
  if not self:hasLoadedBank() then
    return
  end

  if VoiceUpdateBank == true then
    VoiceUpdateBank = false
    self:setValue(mod:getName(), self.bank:getSelectedPatchIndex())
    return
  end

  if value < 0 then
    return
  end

  if value ~= self.bank:getSelectedPatchIndex() then
    patchService:putPatch(self.bank, self:assembleValues(), self.bank:getSelectedPatchIndex())

    self.bank:setSelectedPatchIndex(value)
    self:assignValues(patchService:getPatch(self.bank, value), true)
  end
end

-- This method assigns patch data from a memory block
-- to all modulators in the panel
function RolandD50Controller:assignValues(patch, sendMidi)
  local midiSize = patch:getSize()
  for i = 0, midiSize - 1 do -- gets the voice parameter values
    local mod = panel:getModulatorWithProperty("modulatorCustomName", string.format("Voice%d", i))

    if mod ~= nil then
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

function RolandD50Controller:assignBank(bank)
  self.bank = bank
  self:assignValues(bank:getPatch(0), true)
  self:setComboBoxContents("Voice_PatchSelectControl", patchService:getNumberedPatchNamesList(bank))
  self:setValue("Voice_PatchSelectControl", 0)
  self:setActivation("Voice_PatchSelectControl", true)
end

-- This method assembles the param values from
-- all modulators and stores them in a memory block
function RolandD50Controller:assembleValues()
  local patch = Patch()
  for i = 0, Voice_singleSize - 1 do -- run through all modulators and fetch their value
    local mod = panel:getModulatorWithProperty("modulatorCustomName", string.format("Voice%d", i))
    if mod ~= nil then
      local value = mod:getValue()
      patch:setValue(i, value)
    end
  end

  patch:setUpperPartialValue(self:getValue("UpperPartial1"), self:getValue("UpperPartial2"))
  patch:setLowerPartialValue(self:getValue("LowerPartial1"), self:getValue("LowerPartial2"))

  return patch
end

-- This method set the values of the hidden char modulators
-- to match the given name
function RolandD50Controller:onSetPatchName(mod, patchName)
  local modulatorName = mod:getOwner():getModulatorName()

  if modulatorName == "Name1" then
    local pIndex = self.bank:getSelectedPatchIndex()
    
  elseif modulatorName == "VoiceName12" then
  elseif modulatorName == "VoiceName123" then
  end

  local patchSelectMod = panel:getModulatorByName("Voice_PatchSelectControl")
  local patchSelect = patchSelectMod:getComponent()
  if modulatorName == "Name1"
    and VoiceBankData ~= nil
    and patchSelect:getProperty("componentDisabled") == 0
    and Voice_SelectedPatchIndex >= 0
    and table.getn(VoicePatchNames) > 0
    and VoicePatchNames[Voice_SelectedPatchIndex + 1] ~= patchName  then
    VoicePatchNames[Voice_SelectedPatchIndex + 1] = patchName
  end
end

function RolandD50Controller:onSaveMenu(mod, value)
  local menu = PopupMenu()    -- Main Menu
  menu:addItem(1, "Patch to file", true, false, Image())
  menu:addItem(2, "Bank to file", true, false, Image())
  menu:addItem(3, "Bank to D-50", true, false, Image())
  local ret = menu:show(0,0,0,0)
  if ret == 0 then
    return
  end
  if ret == 1 then
    savePatch(self:assembleValues())
  elseif ret == 2 then
    if not self:hasLoadedBank() then
      utils.warnWindow ("No bank loaded", "You must load a bank in order to perform this action.")
      return
    end
    patchService:putPatch(self.bank, self:assembleValues(), self:getValue("Voice_PatchSelectControl"))

    saveBank(self.bank)
  elseif ret == 3 then
    -- This method instructs the user or synth to
    -- store the current patch
    if not self:hasLoadedBank() then
      AlertWindow.showMessageBox(AlertWindow.InfoIcon, "Information", "You must first load a bank as you can only store banks onto the D-50. ", "OK")
      return
    end

    AlertWindow.showMessageBox(AlertWindow.InfoIcon, "Information", "Hold down the \"DATA TRANSFER\" button then press \"(B.LOAD)\".\nRelease the two buttons and press \"ENTER\".\nOnce the D-50 is in waiting for data press \"OK\" to close this popup.", "OK")

    patchService:putPatch(self.bank, self:assembleValues(), self:getValue("Voice_PatchSelectControl"))
    midiService:sendMidiMessages(self.bank:toSyxMessages())
  end
end

function RolandD50Controller:onLoadMenu(mod, value)
  local menu = PopupMenu()    -- Main Menu
  menu:addItem(1, "Patch from file", true, false, Image())
  menu:addItem(2, "Bank from file", true, false, Image())
  menu:addItem(3, "Bank from D-50", true, false, Image())
  local menuSelect = menu:show(0,0,0,0)
  if menuSelect == 0 then
    return
  end

  if menuSelect == 1 then
    -- Load Patch
    local alertValue = false
    if self:hasLoadedBank() then
      -- Prompt user to save bank
      alertValue = AlertWindow.showYesNoCancelBox(AlertWindow.InfoIcon, "Load patch", "Load patch.\nWhat do you want to do?", "Discard bank and load patch", "Insert patch in bank", "Cancel")
    else
      -- Prompt user to save patch
      alertValue = AlertWindow.showOkCancelBox(AlertWindow.InfoIcon, "Overwrite patch?", "This action will overwrite your existing patch. Are you sure you want to continue?", "OK", "Cancel")
    end
    if alertValue == false then return end

    local f = utils.openFileWindow ("Open Patch", File(""), "*.syx", true)
    if f:existsAsFile() then
      local loadedData = MemoryBlock()
      f:loadFileAsData(loadedData)
      local status, patch = pcall(PatchService.newPatch, patchService, loadedData)
      if status then
        self:assignValues(patch, true)
        if alertValue == 2 then
          patchService:putPatch(self.bank, patch, Voice_SelectedPatchIndex)
        else
          self.bank = nil
          self:setActivation("Voice_PatchSelectControl", false)
        end
      else
        log:warn(cutils.getErrorMessage(phead))
        utils.warnWindow ("Load Patch", cutils.getErrorMessage(self.bank))
      end
    end
  elseif menuSelect == 2 then   -- Load Bank
    if isAbortLoadBank(self:hasLoadedBank()) then return end

    local f = utils.openFileWindow ("Open Bank", File(""), "*.syx", true)
    if f:existsAsFile() then
      local loadedData = MemoryBlock()
      f:loadFileAsData(loadedData)

      local status, bank = pcall(PatchService.newBank, patchService, loadedData)
      if status then
        self:assignBank(bank)
      else
        log:warn(cutils.getErrorMessage(phead))
        utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
      end
    end
  elseif menuSelect == 3 then
    -- This method instructs the synth or user
    -- to perform a single patch dump
    if isAbortLoadBank(self:hasLoadedBank()) then return end

    AlertWindow.showMessageBox(AlertWindow.InfoIcon, "Information", "Perform a Bulk dump for the Roland D-50 Voice Bank by pressing the \"B.Dump\" button whie holding down \"Data Transfer\".\n\nPress OK when D-50 says \"Complete.\"", "OK")
  end
end
