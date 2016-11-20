require("controller/AbstractS2kController")
require("Logger")
require("cutils")

local log = Logger("DrumMapController")

local disablePad = function(comp)
  comp:setProperty("uiButtonColourOff", "ff93b4ff", false)
  comp:setProperty("uiButtonColourOn", "ff93b4ff", false)
end

local enablePad = function(comp)
  comp:setProperty("uiButtonColourOff", "0xff0000ff", false)
  comp:setProperty("uiButtonColourOn", "0xff0000ff", false)
end

local setPadValue = function(padName, value)
  local pad = panel:getComponent(padName)

  if value == nil or value == "" then
    pad:setProperty("componentVisibleName", "", true)
    pad:setProperty("componentLabelVisible", 0, true)
  else
    pad:setProperty("componentLabelVisible", 1, true)
    pad:setProperty("componentVisibleName", value, true)
  end
end

local getKeyGroupName = function(comp)
  local grpName = comp:getProperty("componentGroupName")
  local kgIndex = string.sub(grpName, 9, string.find(grpName, "-grp") - 1)
  return string.format("KeyGroup %s", kgIndex)
end

DrumMapController = {}
DrumMapController.__index = DrumMapController

setmetatable(DrumMapController, {
  __index = AbstractS2kController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DrumMapController:_init()
  AbstractS2kController._init(self)
end

function DrumMapController:setDrumMap(drumMap)
  self.drumMap = drumMap
  self.drumMapListenerId = drumMap:addListener(self, "updateDrumMap")
end

function DrumMapController:setSampleList(sampleList)
  self.sampleList = sampleList
  sampleList:addListener(self, "updateSampleList")
end

function DrumMapController:updateDrumMap(drumMap)
  -- Avoid infinite loops
  drumMap:removeListener(self.drumMapListenerId)

  --
  -- Update pads
  --
  panel:getComponent("drumMapSelectionLabel"):setProperty("uiLabelText", "", false)

  local numPads = drumMap:getNumKeyGroups()
  self:setValueForce("numKeyGroups", numPads)

  for i = 1,16 do
    local padName = string.format("drumMap-%d", i)
    if drumMap:isSelectedKeyGroup(i) then
      local comp = panel:getComponent(padName)
      enablePad(comp)

      local kgName = getKeyGroupName(comp)
      panel:getComponent("drumMapSelectionLabel"):setProperty("uiLabelText", kgName, false)
    else
      disablePad(panel:getComponent(padName))
    end
    local samplesOfPad = drumMap:getSamplesOfKeyGroup(i)
    setPadValue(padName, samplesOfPad)

    self:toggleVisibility(padName, i <= numPads)
  end

  --
  -- Update floppy info
  --
  local numFloppies = drumMap:getNumFloppies()
  local numFloppiesText = string.format("# Floppies to be transfered: %d", numFloppies)
  panel:getComponent("numFloppiesLabel"):setText(numFloppiesText)

  local floppyUsagePercent = drumMapService:getFloppyUsagePercent(drumMap)
  local floppyUsageBar = panel:getModulatorByName("floppyUsageBar")
  floppyUsageBar:setValue(floppyUsagePercent, false)

  local color = "FF99CE65"
  if floppyUsagePercent > 90 then
    color = "FFCC3824"
  elseif floppyUsagePercent > 75 then
    color = "FFCCAA24"
  end
  floppyUsageBar:getComponent():setProperty("uiSliderThumbColour", color, false)

  --
  -- Update assignment controls
  --
  self:toggleActivation("assignSample", drumMap:isReadyForAssignment())
  self:toggleActivation("clearSample", not drumMap:isClear())
  self:toggleActivation("clearAllSamples", not drumMap:isClear())
  self:toggleActivation("transferSamples", not drumMap:isClear())

  --
  -- Update range controls
  --
  local isPadSelected = drumMap:getSelectedKeyGroup() ~= nil
  self:toggleActivation("drumMapLowKey", isPadSelected)
  self:toggleActivation("drumMapHighKey", isPadSelected)
  self:toggleActivation("defaultDrumMapButton", isPadSelected)

  if isPadSelected then
    local keyRanges = drumMap:getSelectedKeyRangeValues()
    local lowKeyMod = panel:getModulatorByName("drumMapLowKey")
    lowKeyMod:setValue(keyRanges[1], false)
    lowKeyMod:setProperty("modulatorMax", keyRanges[2], false)

    local highKeyMod = panel:getModulatorByName("drumMapHighKey")
    highKeyMod:setValue(keyRanges[2], false)
    highKeyMod:setProperty("modulatorMin", keyRanges[1], false)
  end

  panel:getComponent("wavSelector"):setProperty("uiFileListCurrentRoot",
    cutils.getUserHome(), false)
  panel:getComponent("programCreateNameLbl"):setProperty("uiLabelText", drumMap:getProgramName(), false)

  -- Register listener again
  self.drumMapListenerId = drumMap:addListener(self, "updateDrumMap")
end

function DrumMapController:transferProcessUpdate(process)
  self:toggleActivation("transferSamples", not process:isRunning())
  if process:getState() == TRANSFERING_FLOPPY then
    self:updateStatus("Transfering floppy image...")
    utils.infoWindow("Load samples", "Please select to load all from nfloppy on the\Akai S2000 and press OK when the process has finished.")
  elseif process:getState() == SAMPLES_FLOPPY_TRANSFER_DONE then
    self:updateStatus("Data transfer done.")
  elseif process:getState() == TRANSFERRING_SAMPLES_FLOPPY then
    self:updateStatus("Transfering 1:st floppy to Akai S2000...")
    utils.infoWindow("Load samples", "Please select to load all from\nfloppy on the Akai S2000.")
  end
end

function DrumMapController:transferSamples()
  self:updateStatus(string.format("Transfering samples to Akai S2000..."))

  local proc = TransferSamplesProcess()
  proc:addListener(self, "transferProcessUpdate")
  local status, err = pcall(ProcessController.execute, processController, proc)
  if not status then
    self:updateStatus("Failed to transfer data.\nPlease cancel process")
  end
end

function DrumMapController:transferFloppyImage()
  self:updateStatus(string.format("Transfering floppy image to Akai S2000..."))

  local proc = TransferFloppyProcess()
  proc:addListener(self, "transferProcessUpdate")
  local status, err = pcall(ProcessController.execute, processController, proc)
  if not status then
    self:updateStatus("Failed to transfer data.\nPlease cancel process")
  end
end

function DrumMapController:updateSampleList(sl)
  drumMapService:updateDrumMapSamples(self.drumMap, sl)
end

function DrumMapController:assignFile(file)
  if file ~= nil then
    if not drumMapService:isValidSampleFile(file) then
      self:toggleActivation("assignSample", 1)
      self:updateStatus("Please select a wav file")
      return
    end

    drumMap:setSelectedSample(file)
  end

  local status, err = pcall(DrumMapService.assignSample, drumMapService, self.drumMap)
  if status then
    self:updateStatus("Transfer samples to sampler by pressing \"Launch\"")
  else
    self:updateStatus(cutils.getErrorMessage(err))
  end
end

function DrumMapController:assignSample()
  local status, err = pcall(DrumMapService.assignSample, drumMapService, self.drumMap)
  if status then
    self:updateStatus("Transfer samples to sampler by pressing \"Launch\"")
  else
    self:updateStatus(cutils.getErrorMessage(err))
  end
end

function DrumMapController:onKeyGroupNumChange(mod, value)
  drumMap:setNumKeyGroups(value)
end

function DrumMapController:onKeyGroupClear(mod, value)
  drumMap:clearSelectedKeyGroup()

  self:updateStatus("Select a sample and a key group")
end

function DrumMapController:onDrumMapClear(mod, value)
  drumMap:resetDrumMap()

  self:updateStatus("Select a sample and a key group")
end

function DrumMapController:onCreateProgram(mod, value)
  local status, err = pcall(ProgramService.addNewProgram, programService, programList, drumMap)
  if status then
    self:updateStatus("Program created!")
    LOGGER:info(err:getPdata():getData():toHexString(1))
    midiService:sendMidiMessage(err:getPdata())
  else
    self:updateStatus(cutils.getErrorMessage(err))
  end

  local highestProg = programList:getNumPrograms()
  self:setValueForce("programSelector", highestProg)
end

function DrumMapController:onFileDoubleClicked(mod, file)
  if not file:isDirectory() then
    self:assignFile(file)
  end
end

function DrumMapController:onFileSelected(mod, file)
  if drumMapService:isValidSampleFile(file) then
    drumMap:setSelectedSample(file)
  else
    drumMap:setSelectedSample(nil)
    self:updateStatus("Please select a wav file")
  end
end

function DrumMapController:onSampleDoubleClicked(comp, event)
  self:onSampleSelected(comp, event)
  self:assignSample()
end

function DrumMapController:onSampleSelected(comp, event)
  local sampleName = comp:getComponentText():toUpperCase()
  drumMap:setSelectedSample(sampleName)
end

function DrumMapController:onPadSelected(comp, event)
  local grpName = comp:getProperty("componentGroupName")
  local kg = string.sub(grpName, 0, string.find(grpName, "-grp") - 1)
  drumMap:setSelectedKeyGroup(kg)
end

function DrumMapController:onTransferSamples(mod, value)
  if not settingsController:verifyTransferSettings() then
    self:updateStatus("There are config issues.\nPlease verify your settings...")
    return
  end

  if settings:floppyImgPathExists() then
    self:transferFloppyImage()
  else
    self:transferSamples()
  end
end

function DrumMapController:toggleLoadOsButton(process)
  self:toggleActivation("loadOsButton", not process:isRunning())
  if process:getState() == OS_LOADING then
    self:updateStatus("Loading Akai S2000 OS...")
  elseif process:getState() == OS_LOADED then
    self:updateStatus("Akai S2000 OS loaded.")
  else 
  end
end

function DrumMapController:onLoadOs(mod, value)
  if not settingsController:verifyTransferSettings() then
    self:updateStatus("There are config issues.\nPlease verify your settings...")
    return
  end

  local loadOsProc = LoadOsProcess()
  loadOsProc:addListener(self, "toggleLoadOsButton")
  local status, err = pcall(ProcessController.execute, processController, loadOsProc)
  if not status then
    log:warn(cutils.getErrorMessage(err))
    self:updateStatus("Failed to load OS.\nPlease cancel process")
  end
end

function DrumMapController:onCancelProcess(mod, value)
  self:updateStatus("Select a sample and a key group")
  local status, err = pcall(ProcessController.abort, processController)
  if not status then
    log:warn(cutils.getErrorMessage(err))
    self:updateStatus(cutils.getErrorMessage(err))
  end
end

function DrumMapController:onSampleAssign(mod, value)
  self:assignSample()
end

function DrumMapController:onDrumMapKeyChange(mod, value)
  local customIndex = mod:getProperty("modulatorCustomIndex")
  drumMap:setKeyRange(customIndex, value)
end

function DrumMapController:onResetAllKeyRanges(mod, value)
  drumMap:resetAllRanges()
end

function DrumMapController:onResetPadKeyRange(mod, value)
  drumMap:resetSelectedKeyRange()
end

function DrumMapController:onSamplesTabChanged(mod, tabIndex)
  if tabIndex == 0 then
    self.drumMap:setSampleSelectType(false)
  elseif tabIndex == 1 then
    self.drumMap:setSampleSelectType(true)
  else
    log:warn("Invalid tab selected %d!", tabIndex)
  end
end

function DrumMapController:onDrumMapProgramNameChange(label, content)
  drumMap:setProgramName(content)
end
