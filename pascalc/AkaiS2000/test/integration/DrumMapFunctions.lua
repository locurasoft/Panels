function onFloppyImageCleared()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  floppyImgPath = nil
  panel:getComponent("loadFloppyImageLabel"):setText("")

  local launchButtonState = drumMap:getLaunchButtonState()

  drumMapController:toggleActivation("transferSamples", launchButtonState ~= "")

  if launchButtonState  ~= "" then
    drumMapController:updateStatus(launchButtonState)
  end
end

function onKeyGroupNumChange(value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMap:setNumKeyGroups(value)
end

function onKeyGroupClear()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMap:clearSelectedKeyGroup()

  drumMapController:updateStatus("Select a sample and a key group")
end

function onDrumMapClear()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMap:resetDrumMap()

  drumMapController:updateStatus("Select a sample and a key group")
end

function onCreateProgram()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local programName = panel:getComponent("programCreateNameLbl"):getProperty("uiLabelText")

  if programName == nil or programName == "" then
    drumMapController:updateStatus("Please provide program name...")
    return
  end

  if programList:hasProgram(programName) then
    drumMapController:updateStatus("Program already exists...")
    return
  end

  if not drumMap:hasLoadedAllSamples() then
    drumMapController:updateStatus("You cannot create a program with unloaded samples...")
    return
  end

  local keyGroups = drumMap:getKeyGroups()
  local program = programService:newProgram(programName, keyGroups)
  programList:addProgram(program)
  local highestProg = programList:getNumPrograms()
  panel:getModulatorByName("programSelector"):setValue(highestProg, true)

end

function onFileDoubleClicked(file)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapController:assignFile(file)
end

function onFileSelected(file)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if drumMapService:isValidSampleFile(file) then
    drumMap:setSelectedSample(file)
  else
    drumMap:setSelectedSample(nil)
    drumMapController:updateStatus("Please select a wav file")
  end
end

function onSampleDoubleClicked(sampleName)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapController:assignSample(sampleName)
end

function onSampleSelected(sampleName)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMap:setSelectedSample(sampleName)
end


function onPadSelected(comp)
  function getKeyGroupByComponent(comp)
    local grpName = comp:getProperty("componentGroupName")
    return string.sub(grpName, 0, string.find(grpName, "-grp") - 1)
  end

  local kg = getKeyGroupByComponent(comp)
  drumMap:setSelectedKeyGroup(kg)
end

function onTransferSamples()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if not settingsController:verifyTransferSettings() then
    drumMapController:updateStatus("There are config issues.\nPlease verify your settings...")
    return
  end

  if settings:floppyImgPathExists() then
    drumMapController:transferFloppyImage()
  else
    drumMapController:transferSamples()
  end
end

function onLoadOs()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if not settingsController:verifyTransferSettings() then
    drumMapController:updateStatus("There are config issues.\nPlease verify your settings...")
    return
  end

  drumMapController:loadOs()
end

function onCancelProcess()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapController:updateStatus("Select a sample and a key group")
  processController:abort()
end

function onRslist()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapController:requestSampleList()
end

function onSampleAssign()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapController:assignSample()
end

function onDrumMapKeyChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local customIndex = mod:getProperty("modulatorCustomIndex")
  drumMap:setKeyRange(customIndex, value)
end

function onResetAllKeyRanges()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMap:resetAllRanges()
end

function onResetPadKeyRange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMap:resetSelectedKeyRange()
end

