function onFloppyImageCleared()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  floppyImgPath = nil
  panel:getComponent("loadFloppyImageLabel"):setText("")

  local launchButtonState = drumMapModel:getLaunchButtonState()

  drumMapCtrl:toggleActivation("transferSamples", launchButtonState ~= "")

  if launchButtonState  ~= "" then
    drumMapCtrl:updateStatus(launchButtonState)
  end
end

function onKeyGroupNumChange(value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapModel:setNumKeyGroups(value)
end

function onKeyGroupClear()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapModel:clearSelectedKeyGroup()

  drumMapCtrl:updateStatus("Select a sample and a key group")
end

function onDrumMapClear()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapModel:resetDrumMap()

  drumMapCtrl:updateStatus("Select a sample and a key group")
end

function onCreateProgram()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local programName = panel:getComponent("programCreateNameLbl"):getProperty("uiLabelText")

  if programName == nil or programName == "" then
    LOGGER:info("Please provide program name...")
    return
  end

  if programListModel:hasProgram(programName) then
    LOGGER:info("Program already exists...")
    return
  end

  if not drumMapModel:hasLoadedAllSamples() then
    LOGGER:info("You cannot create a program with unloaded samples...")
    return
  end

  local keyGroups = drumMapModel:getKeyGroups()
  local program = programSrvc:newProgram(programName, keyGroups)
  LOGGER:fine("Adding program '%s', # progs: %d", program:getName(), programListModel:getNumPrograms())
  programListModel:addProgram(program)
  local highestProg = programListModel:getNumPrograms()
  LOGGER:fine("Selecting prog # %d", highestProg)
  panel:getModulatorByName("programSelector"):setValue(highestProg, true)

end

function onSampleDoubleClicked(file)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if not drumMapSrvc:isValidSampleFile(file) then
    drumMapCtrl:toggleActivation("assignSample", 1)
    drumMapCtrl:updateStatus("Please select a wav file")
    return
  end

  drumMapModel:setSelectedSample(file)

  if not drumMapModel:isReadyForAssignment() then
    drumMapCtrl:updateStatus("Select a sample and a key group.")
    return
  end

  local result = drumMapSrvc:assignSample()
  drumMapCtrl:updateStatus(result)
end

function onSampleSelected(file)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if drumMapSrvc:isValidSampleFile(file) then
    drumMapModel:setSelectedSample(file)
  else
    drumMapModel:setSelectedSample(nil)
    drumMapCtrl:updateStatus("Please select a wav file")
  end
end

function onPadSelected(comp)
  function getKeyGroupByComponent(comp)
    local grpName = comp:getProperty("componentGroupName")
    return string.sub(grpName, 0, string.find(grpName, "-grp") - 1)
  end

  local kg = getKeyGroupByComponent(comp)
  drumMapModel:setSelectedKeyGroup(kg)
end

function onFloppyImageSelected()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end
  floppyImgPath = utils.openFileWindow("Select floppy image", File.getSpecialLocation(File.userHomeDirectory), "*.img", true)

  if floppyImgPath:getFullPathName() ~= nil and floppyImgPath:getFullPathName() ~= "" then
    panel:getComponent("loadFloppyImageLabel"):setText(floppyImgPath:getFullPathName())
    drumMapCtrl:toggleActivation("transferSamples", drumMapModel:getLaunchButtonState())
  end
end

function onTransferMethodChange(value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local FLOPPY, HXCFE, MIDI = 0, 1, 2

  drumMapCtrl:toggleActivation("hxcPathGroup", value == HXCFE)
  drumMapCtrl:toggleActivation("loadOsButton", value == HXCFE)
  drumMapCtrl:toggleActivation("loadFloppyImageGroup", value == HXCFE)
  drumMapCtrl:toggleActivation("setfdprmPathGroup", value == FLOPPY)
end

function onSetfdprmPathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  setfdprmPath = utils.openFileWindow("Select setfdprm path", File.getSpecialLocation(File.userHomeDirectory), "*", true)
  s2kDieSrvc:setFdprmPath(setfdprmPath)
  panel:getComponent("setfdprmPathLabel"):setText(setfdprmPath:getFullPathName())
end

function onHxcPathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  filePatternsAllowed = "*"
  if operatingsystem == "win" then
    filePatternsAllowed = "*.exe"
  end

  local hxcPath = utils.openFileWindow("Select hxcfe executable", File.getSpecialLocation(File.userHomeDirectory),
    filePatternsAllowed, true)
  hxcSrvc:setHxcPath(hxcPath)
  panel:getComponent("hxcPathLabel"):setText(hxcPath:getFullPathName())
end

function onS2kDiePathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local s2kDiePath = utils.openFileWindow("Select s2kDie folder", File.getSpecialLocation(File.userHomeDirectory), "*.php", true)
  s2kDieSrvc:setS2kDiePath(s2kDiePath)
  panel:getComponent("s2kDiePathLabel"):setText(s2kDiePath:getFullPathName())
end

function onWorkPathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  workFolder = utils.getDirectoryWindow("Select work folder", File.getSpecialLocation(File.userHomeDirectory))
  panel:getComponent("workPathLabel"):setText(workFolder:getFullPathName())
end

function onTransferSamples()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if not drumMapCtrl:verifyTransferSettings() then
    drumMapCtrl:updateStatus("There are config issues.\nPlease verify your settings...")
    return
  end

  local logFilePath
  local numSamplesBefore = 0
  local expectedNumSamples = -1

  local rslistFunc = function()
    midiSrvc:sendMidiMessage(Rslist())
  end

  local midiCallbackFunc = function(data)
    local msg = Slist(data)
    if msg ~= nil then
      local numSamples = msg:getNumSamples()
      if numSamplesBefore == 0 then
        numSamplesBefore = numSamples
      elseif expectedNumSamples == -1 then
        expectedNumSamples = s2kDieSrvc:getNumGeneratedSamples(logFilePath)
      elseif numSamples == numSamplesBefore + expectedNumSamples then
        sampleListModel:addSamples(msg)
        processSrvc:abort()

        local wavList = drumMapModel:retrieveNextFloppy()
        if wavList == nil then
          drumMapCtrl:updateStatus("Data transfer done.")
        else
          drumMapCtrl:updateStatus(string.format("Transfering 1:st floppy to Akai S2000..."))
          executeTransfer(wavList)
        end
      else
      end
    end
  end

  local executeTransfer = function(wavList)
    -- console(string.format("WavList : %d", table.getn(wavList)))
    local transferProc = Process()
      :withPath(workFolder:getFullPathName())
      :withLaunchVariable("wavFiles", wavList)
      :withLaunchGenerator(s2kDieSrvc:s2kDieLauncher())
      :withLaunchGenerator(hxcSrvc:getHxcLauncher())
      :withAbortGenerator(hxcSrvc:getHxcAborter())
      :withMidiCallback(midiCallbackFunc)
      :withMidiSender(rslistFunc, 1000)

    logFilePath = transferProc:getLogFilePath()

    local result = processSrvc:execute(transferProc)
    if result then
      utils.infoWindow ("Load samples", "Please select to load all from\nfloppy on the Akai S2000.")
      drumMapCtrl:updateStatus("Transfering samples...")
    else
      drumMapCtrl:updateStatus("Failed to transfer data.\nPlease cancel process")
    end
  end


  if floppyImgPath == nil then
    local wavList = drumMapModel:retrieveNextFloppy()
    if wavList == nil then
      drumMapCtrl:updateStatus("Data transfer done.")
    else
      drumMapCtrl:updateStatus(string.format("Transfering 1:st floppy to Akai S2000..."))
      executeTransfer(wavList)
    end
  else
    drumMapCtrl:updateStatus(string.format("Transfering floppy to Akai S2000..."))
    local transferProc = process()
      :withPath(workFolder:getFullPathName())
      :withLaunchVariable("imgPath", floppyImgPath:getFullPathName())
      :withLaunchGenerator(hxcService:getHxcLauncher())
      :withAbortGenerator(hxcService:getHxcAborter())

    local result = processService:execute(transferProc)
    if result then
      utils.infoWindow ("Load samples", "Please select to load all from\nfloppy on the Akai S2000.")
      drumMapCtrl:updateStatus("Done...")
    else
      drumMapCtrl:updateStatus("Failed to transfer data.\nPlease cancel process")
    end
  end
end

function onLoadOs()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if not drumMapCtrl:verifyTransferSettings() then
    drumMapCtrl:updateStatus("There are config issues.\nPlease verify your settings...")
    return
  end

  local statCount = 0

  local rstatFunc = function()
    midiSrvc:sendMidiMessage(Rstat())
  end

  local statFunc = function(data)
    LOGGER:fine("[statFunc]")
    local statMsg = Stat(data)
    if statMsg ~= nil then
      if statCount > 20 then
        statCount = statCount + 1
      else
        processSrvc:abort()
        drumMapCtrl:updateStatus("Akai S2000 OS loaded.")
        drumMapCtrl:toggleActivation("loadOsButton", true)
      end
    end
  end

  local transferProc = Process()
    :withPath(workFolder:getFullPathName())
    :withLaunchVariable("imgPath", string.format("%s%sosimage.img", workFolder:getFullPathName(), pathseparator))
    :withLaunchGenerator(hxcSrvc:getHxcLauncher())
    :withAbortGenerator(hxcSrvc:getHxcAborter())
    :withMidiCallback(statFunc)
    :withMidiSender(rstatFunc, 1000)

  drumMapCtrl:toggleActivation("loadOsButton", false)

  local result = processSrvc:execute(transferProc)
  if result then
    drumMapCtrl:updateStatus("Loading Akai S2000 OS...")
  else
    drumMapCtrl:updateStatus("Failed to load OS.\nPlease cancel process")
  end
end

function onCancelProcess()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapCtrl:updateStatus("Select a sample and a key group")
  processSrvc:abort()
end

function onRslist()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local rslistFunc = function()
    midiSrvc:sendMidiMessage(rslist())
  end

  local midiCallbackFunc = function(data)
    local slist = slist(data)
    if slist then
      processSrvc:abort()
      sampleListModel:addSamples(slist)
    end
  end

  local rslistProc = process()
    :withMidiCallback(midiCallbackFunc)
    :withMidiSender(rslistFunc, 100)

  local result = processSrvc:execute(rslistProc)
  if result then
    drumMapCtrl:updateStatus("Receiving sample list...")
  else
    drumMapCtrl:updateStatus("Failed to receive data.\nPlease cancel process")
  end
end

function onSampleAssign()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if not drumMapModel:isReadyForAssignment() then
    updateStatus("Select a sample and a key group.")
    return
  end

  local result = drumMapSrvc:assignSample()
  drumMapCtrl:updateStatus(result)
end

function onDrumMapKeyChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local customIndex = mod:getProperty("modulatorCustomIndex")
  drumMapModel:setKeyRange(customIndex, value)
end

function onResetAllKeyRanges()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapModel:resetAllRanges()
end

function onResetPadKeyRange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  drumMapModel:resetSelectedKeyRange()
end

