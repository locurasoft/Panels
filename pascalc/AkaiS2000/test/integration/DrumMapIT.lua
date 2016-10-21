require("akaiS2kTestUtils")
require("integration/DrumMapFunctions")
require("model/DrumMap")
require("model/SampleList")
require("controller/DrumMapController")
require("service/DrumMapService")
require("service/MidiService")
require("MockPanel")
require("message/KdataMsg")
require("json4ctrlr")
require 'lunity'
require 'lemock'
module( 'DrumMapIT', lunity )

function assertText(compName, expectedText)
  assertEqual(panel:getComponent(compName):getText(), expectedText)
end

function assertEnabled(compName)
  assertTrue(panel:getComponent(compName):isEnabled())
end

function assertCompProperty(compName, propName, value)
  assertEqual(panel:getComponent(compName):getProperty(propName), value)
end

function setup()
  regGlobal("midiService", MidiService())
  regGlobal("panel", MockPanel())
  local drumMap = DrumMap()
  local sampleList = SampleList()
  local drumMapController = DrumMapController(drumMap)
  drumMap:addListener(drumMapController, "updateDrumMap")
  regGlobal("drumMapModel", drumMap)
  regGlobal("drumMapCtrl", drumMapController)
  regGlobal("drumMapSrvc", DrumMapService(drumMap, sampleList))

end

function teardown()
  delGlobal("midiService")
  delGlobal("panel")
  delGlobal("drumMapModel")
  delGlobal("drumMapCtrl")
end

function expectFloppyInfo(numFloppies, floppyUsagePercent)
  component:setText(string.format("# Floppies to be transfered: %d", numFloppies));mc:times(1)
  if floppyUsagePercent == nil then
    modulator:setValue(mc.ANYARG, false);mc:times(1)
  else
    modulator:setValue(floppyUsagePercent, false);mc:times(1)
  end
  component:setProperty("uiSliderThumbColour", mc.ANYARG, false);mc:times(1)
end

function expectAssignmentCtrls(readyForAssignment, clear)
  if readyForAssignment then
    component:setProperty("componentDisabled", 0, false);mc:times(1)
  else
    component:setProperty("componentDisabled", 1, false);mc:times(1)
  end

  if clear then
    component:setProperty("componentDisabled", 1, false);mc:times(3)
  else
    component:setProperty("componentDisabled", 0, false);mc:times(3)
  end
end

function expectRangeControls(isPadSelected, lowKey, highKey)
  if isPadSelected then
    component:setProperty("componentDisabled", 0, false);mc:times(3)
    modulator:setValue(lowKey, false)
    modulator:setValue(highKey, false)
  else
    component:setProperty("componentDisabled", 1, false);mc:times(3)
  end
end

function newKeyGroupComponent(index)
  local comp = panel:getComponent(string.format("drumMap-%d", index))
  comp:setProperty("componentGroupName", string.format("drumMap-%d-grp", index))
  return comp
end

function assignSamples(selectedComp, ...)
  if type(selectedComp) == "number" then
    selectedComp = newKeyGroupComponent(selectedComp)
  end

  onPadSelected(selectedComp)
  for i,v in ipairs(arg) do
    onSampleDoubleClicked(File(string.format("test/data/%s", v)))
  end
end

function verifyPads(numKgs, selectedKg, kgTexts)
  for i = 1, 16 do
    local padName = string.format("drumMap-%d", i)
    if i == selectedKg then
      assertCompProperty(padName, "uiButtonColourOff", "0xff0000ff")
      assertCompProperty(padName, "uiButtonColourOn", "0xff0000ff")
    else
      assertCompProperty(padName, "uiButtonColourOff", "ff93b4ff")
      assertCompProperty(padName, "uiButtonColourOn", "ff93b4ff")
    end

    if kgTexts[i] == nil then
      assertCompProperty(padName, "componentVisibleName", "")
      assertCompProperty(padName, "componentLabelVisible", 0)
    else
      assertCompProperty(padName, "componentVisibleName", kgTexts[i])
      assertCompProperty(padName, "componentLabelVisible", 1)
    end

    if i <= numKgs then
      assertCompProperty(padName, "componentVisibility", 1)
    else
      assertCompProperty(padName, "componentVisibility", 0)
    end
  end
end

function testOnFloppyImageCleared()
  onFloppyImageCleared()

  assertText("loadFloppyImageLabel", "")
  assertText("lcdLabel", "Select a sample and a key group")
  assertEnabled("transferSamples")
end

function testOnKeyGroupNumChange()
  local numKgs = 1
  onKeyGroupNumChange(numKgs)

  assertText("uiLabelText", "")
  verifyPads(numKgs, 0, {})
  assertEqual(drumMapModel.numKgs, numKgs)
end

function testOnKeyGroupChange_MultipleKeyGroups_OneSelected()
  local selectedKg = 4
  local numKgs = 7
  onKeyGroupNumChange(numKgs)
  onPadSelected(newKeyGroupComponent(selectedKg))

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {})
  assertEqual(drumMapModel.numKgs, numKgs)
end

function testOnKeyGroupChange_MultipleKeyGroups_UnselectedPad()
  local selectedKg = 4
  local numKgs = 7
  onKeyGroupNumChange(numKgs)

  local comp = newKeyGroupComponent(selectedKg)
  onPadSelected(comp)
  onPadSelected(comp)

  assertText("uiLabelText", "")
  verifyPads(numKgs, 0, {})
  assertEqual(drumMapModel.numKgs, numKgs)
end

function testOnKeyGroupChange_MultipleKeyGroups_OneSelected_FilesLoaded()
  local selectedKg = 4
  local numKgs = 7
  local secondKg = 3

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)
  assignSamples(selectedComp, "Cat-Meow.wav", "Electric-Bass-High-Bb-Staccato.wav")

  assignSamples(secondKg, "Casio-CZ-5000-Synth-Bass-C1.wav", "Bowed-Bass-C2.wav")

  onPadSelected(selectedComp)

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMapModel.numKgs, numKgs)
end

function testOnKeyGroupClear()
  local selectedKg = 14
  local numKgs = 15
  local secondKg = 13

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)
  assignSamples(selectedComp, "Cat-Meow.wav", "Electric-Bass-High-Bb-Staccato.wav")

  assignSamples(secondKg, "Casio-CZ-5000-Synth-Bass-C1.wav", "Bowed-Bass-C2.wav")

  onPadSelected(selectedComp)

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMapModel.numKgs, numKgs)

  onKeyGroupClear()

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMapModel.numKgs, numKgs)
end

function testOnDrumMapClear()
  local selectedKg = 3
  local numKgs = 3
  local secondKg = 2

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)
  assignSamples(selectedComp, "Cat-Meow.wav", "Electric-Bass-High-Bb-Staccato.wav")

  assignSamples(secondKg, "Casio-CZ-5000-Synth-Bass-C1.wav", "Bowed-Bass-C2.wav")

  onPadSelected(selectedComp)

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMapModel.numKgs, numKgs)

  onDrumMapClear()

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {})
  assertEqual(drumMapModel.numKgs, numKgs)
end

--function testOnCreateProgram()
--end

function testOnSampleDoubleClicked()
  local numKgs = 3
  local selectedKg = 3
  
  local secondKg = 2

  onKeyGroupNumChange(numKgs)
  
  local selectedComp = newKeyGroupComponent(selectedKg)

  onPadSelected(selectedComp)
  onSampleDoubleClicked(File("test/data/Bowed-Bass-C2.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav"
  })

  onSampleDoubleClicked(File("test/data/Cat-Meow.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav"
  })

  -- Test when pads are deselected
  onPadSelected(selectedComp)
  onSampleDoubleClicked(File("test/data/Closed-Hi-Hat-1.wav"))
  verifyPads(numKgs, 0, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav"
  })

  onPadSelected(selectedComp)
  onSampleDoubleClicked(File("test/data/Closed-Hi-Hat-1.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav"
  })

  onSampleDoubleClicked(File("test/data/Closed-Hi-Hat-2.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav\nClosed-Hi-Hat-2.wav"
  })

  -- Key group full
  onSampleDoubleClicked(File("test/data/Closed-Hi-Hat-3.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav\nClosed-Hi-Hat-2.wav"
  })
end

function testOnSampleSelected()
end

--function testOnPadSelected()
--  function getKeyGroupByComponent(comp)
--    local grpName = comp:getProperty("componentGroupName")
--    return string.sub(grpName, 0, string.find(grpName, "-grp") - 1)
--  end
--
--  local kg = getKeyGroupByComponent(comp)
--  drumMapModel:setSelectedKeyGroup(kg)
--end
--
--function testOnFloppyImageSelected()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--  floppyImgPath = utils.openFileWindow("Select floppy image", File.getSpecialLocation(File.userHomeDirectory), "*.img", true)
--
--  if floppyImgPath:getFullPathName() ~= nil and floppyImgPath:getFullPathName() ~= "" then
--    panel:getComponent("loadFloppyImageLabel"):setText(floppyImgPath:getFullPathName())
--    drumMapCtrl:toggleActivation("transferSamples", drumMapModel:getLaunchButtonState())
--  end
--end
--
--function testOnTransferMethodChange()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  local FLOPPY, HXCFE, MIDI = 0, 1, 2
--
--  drumMapCtrl:toggleActivation("hxcPathGroup", value == HXCFE)
--  drumMapCtrl:toggleActivation("loadOsButton", value == HXCFE)
--  drumMapCtrl:toggleActivation("loadFloppyImageGroup", value == HXCFE)
--  drumMapCtrl:toggleActivation("setfdprmPathGroup", value == FLOPPY)
--end
--
--function testOnSetfdprmPathChange()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  setfdprmPath = utils.openFileWindow("Select setfdprm path", File.getSpecialLocation(File.userHomeDirectory), "*", true)
--  s2kDieSrvc:setFdprmPath(setfdprmPath)
--  panel:getComponent("setfdprmPathLabel"):setText(setfdprmPath:getFullPathName())
--end
--
--function testOnHxcPathChange(parameters)
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  filePatternsAllowed = "*"
--  if operatingsystem == "win" then
--    filePatternsAllowed = "*.exe"
--  end
--
--  local hxcPath = utils.openFileWindow("Select hxcfe executable", File.getSpecialLocation(File.userHomeDirectory),
--    filePatternsAllowed, true)
--  hxcSrvc:setHxcPath(hxcPath)
--  panel:getComponent("hxcPathLabel"):setText(hxcPath:getFullPathName())
--end
--
--function testOnS2kDiePathChange()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  local s2kDiePath = utils.openFileWindow("Select s2kDie folder", File.getSpecialLocation(File.userHomeDirectory), "*.php", true)
--  s2kDieSrvc:setS2kDiePath(s2kDiePath)
--  panel:getComponent("s2kDiePathLabel"):setText(s2kDiePath:getFullPathName())
--end
--
--function testOnWorkPathChange()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  workFolder = utils.getDirectoryWindow("Select work folder", File.getSpecialLocation(File.userHomeDirectory))
--  panel:getComponent("workPathLabel"):setText(workFolder:getFullPathName())
--end
--
--function testOnTransferSamples()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  if not drumMapCtrl:verifyTransferSettings() then
--    drumMapCtrl:updateStatus("There are config issues.\nPlease verify your settings...")
--    return
--  end
--
--  local logFilePath
--  local numSamplesBefore = 0
--  local expectedNumSamples = -1
--
--  local rslistFunc = function()
--    midiSrvc:sendMidiMessage(Rslist())
--  end
--
--  local midiCallbackFunc = function(data)
--    local msg = Slist(data)
--    if msg ~= nil then
--      local numSamples = msg:getNumSamples()
--      if numSamplesBefore == 0 then
--        numSamplesBefore = numSamples
--      elseif expectedNumSamples == -1 then
--        expectedNumSamples = s2kDieSrvc:getNumGeneratedSamples(logFilePath)
--      elseif numSamples == numSamplesBefore + expectedNumSamples then
--        sampleListModel:addSamples(msg)
--        processSrvc:abort()
--
--        local wavList = drumMapModel:retrieveNextFloppy()
--        if wavList == nil then
--          drumMapCtrl:updateStatus("Data transfer done.")
--        else
--          drumMapCtrl:updateStatus(string.format("Transfering 1:st floppy to Akai S2000..."))
--          executeTransfer(wavList)
--        end
--      else
--      end
--    end
--  end
--
--  local executeTransfer = function(wavList)
--    -- console(string.format("WavList : %d", table.getn(wavList)))
--    local transferProc = Process()
--      :withPath(workFolder:getFullPathName())
--      :withLaunchVariable("wavFiles", wavList)
--      :withLaunchGenerator(s2kDieSrvc:s2kDieLauncher())
--      :withLaunchGenerator(hxcSrvc:getHxcLauncher())
--      :withAbortGenerator(hxcSrvc:getHxcAborter())
--      :withMidiCallback(midiCallbackFunc)
--      :withMidiSender(rslistFunc, 1000)
--
--    logFilePath = transferProc:getLogFilePath()
--
--    local result = processSrvc:execute(transferProc)
--    if result then
--      utils.infoWindow ("Load samples", "Please select to load all from\nfloppy on the Akai S2000.")
--      drumMapCtrl:updateStatus("Transfering samples...")
--    else
--      drumMapCtrl:updateStatus("Failed to transfer data.\nPlease cancel process")
--    end
--  end
--
--
--  if floppyImgPath == nil then
--    local wavList = drumMapModel:retrieveNextFloppy()
--    if wavList == nil then
--      drumMapCtrl:updateStatus("Data transfer done.")
--    else
--      drumMapCtrl:updateStatus(string.format("Transfering 1:st floppy to Akai S2000..."))
--      executeTransfer(wavList)
--    end
--  else
--    drumMapCtrl:updateStatus(string.format("Transfering floppy to Akai S2000..."))
--    local transferProc = process()
--      :withPath(workFolder:getFullPathName())
--      :withLaunchVariable("imgPath", floppyImgPath:getFullPathName())
--      :withLaunchGenerator(hxcService:getHxcLauncher())
--      :withAbortGenerator(hxcService:getHxcAborter())
--
--    local result = processService:execute(transferProc)
--    if result then
--      utils.infoWindow ("Load samples", "Please select to load all from\nfloppy on the Akai S2000.")
--      drumMapCtrl:updateStatus("Done...")
--    else
--      drumMapCtrl:updateStatus("Failed to transfer data.\nPlease cancel process")
--    end
--  end
--end
--
--function testOnLoadOs()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  if not drumMapCtrl:verifyTransferSettings() then
--    drumMapCtrl:updateStatus("There are config issues.\nPlease verify your settings...")
--    return
--  end
--
--  local statCount = 0
--
--  local rstatFunc = function()
--    midiSrvc:sendMidiMessage(Rstat())
--  end
--
--  local statFunc = function(data)
--    LOGGER:fine("[statFunc]")
--    local statMsg = Stat(data)
--    if statMsg ~= nil then
--      if statCount > 20 then
--        statCount = statCount + 1
--      else
--        processSrvc:abort()
--        drumMapCtrl:updateStatus("Akai S2000 OS loaded.")
--        drumMapCtrl:toggleActivation("loadOsButton", true)
--      end
--    end
--  end
--
--  local transferProc = Process()
--    :withPath(workFolder:getFullPathName())
--    :withLaunchVariable("imgPath", string.format("%s%sosimage.img", workFolder:getFullPathName(), pathseparator))
--    :withLaunchGenerator(hxcSrvc:getHxcLauncher())
--    :withAbortGenerator(hxcSrvc:getHxcAborter())
--    :withMidiCallback(statFunc)
--    :withMidiSender(rstatFunc, 1000)
--
--  drumMapCtrl:toggleActivation("loadOsButton", false)
--
--  local result = processSrvc:execute(transferProc)
--  if result then
--    drumMapCtrl:updateStatus("Loading Akai S2000 OS...")
--  else
--    drumMapCtrl:updateStatus("Failed to load OS.\nPlease cancel process")
--  end
--end
--
--function testOnCancelProcess()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  drumMapCtrl:updateStatus("Select a sample and a key group")
--  processSrvc:abort()
--end
--
--function testOnRslist()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  local rslistFunc = function()
--    midiSrvc:sendMidiMessage(rslist())
--  end
--
--  local midiCallbackFunc = function(data)
--    local slist = slist(data)
--    if slist then
--      processSrvc:abort()
--      sampleListModel:addSamples(slist)
--    end
--  end
--
--  local rslistProc = process()
--    :withMidiCallback(midiCallbackFunc)
--    :withMidiSender(rslistFunc, 100)
--
--  local result = processSrvc:execute(rslistProc)
--  if result then
--    drumMapCtrl:updateStatus("Receiving sample list...")
--  else
--    drumMapCtrl:updateStatus("Failed to receive data.\nPlease cancel process")
--  end
--end
--
--function testOnSampleAssign()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  if not drumMapModel:isReadyForAssignment() then
--    updateStatus("Select a sample and a key group.")
--    return
--  end
--
--  local result = drumMapSrvc:assignSample()
--  drumMapCtrl:updateStatus(result)
--end
--
--function testOnDrumMapKeyChange()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  local customIndex = mod:getProperty("modulatorCustomIndex")
--  drumMapModel:setKeyRange(customIndex, value)
--end
--
--function testOnResetAllKeyRanges()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  drumMapModel:resetAllRanges()
--end
--
--function testOnResetPadKeyRange()
--  -- This variable stops index issues during panel bootup
--  if panel:getBootstrapState() or panel:getProgramState() then
--    return
--  end
--
--  drumMapModel:resetSelectedKeyRange()
--end

runTests{useANSI = false}
