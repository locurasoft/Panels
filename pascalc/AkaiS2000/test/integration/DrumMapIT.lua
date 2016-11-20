require("akaiS2kTestUtils")
require("MockPanel")
require("MockMidiMessage")
require("json4ctrlr")
require("cutils")

require("model/process/Process")
require("model/process/LoadOsProcess")
require("model/DrumMap")
require("model/SampleList")
require("model/ProgramList")
require("model/Settings")

require("controller/DrumMapController")
require("controller/DrumMapControllerAutogen")
require("controller/GlobalController")
require("controller/SettingsController")
require("controller/SettingsControllerAutogen")
require("controller/SampleListController")
require("controller/ProcessController")
require("controller/ProgramController")
require("controller/ProgramControllerAutogen")

require("service/ProgramService")
require("service/S2kDieService")
require("service/HxcService")
require("service/DrumMapService")
require("service/MidiService")

require("message/StatMsg")
require("message/RstatMsg")
require("message/KdataMsg")
require("message/SlistMsg")
require("message/RslistMsg")

require 'lunity'
require 'lemock'
module( 'DrumMapIT', lunity )

local LOW_INDEX, HIGH_INDEX = 1, 2
local tmpFolderName = "ctrlrwork"

function assertText(compName, expectedText)
  assertEqual(panel:getComponent(compName):getText(), expectedText)
end

function assertEnabled(compName)
  assertTrue(panel:getComponent(compName):isEnabled())
end

function assertDisabled(compName)
  assertFalse(panel:getComponent(compName):isEnabled())
end

function assertCompProperty(compName, propName, value)
  assertEqual(panel:getComponent(compName):getProperty(propName), value)
end

function assertModProperty(modName, propName, value)
  assertEqual(panel:getModulatorByName(modName):getProperty(propName), value)
end

function assertModValue(modName, value)
  assertEqual(panel:getModulatorByName(modName):getValue(), value)
end

function assertCompMin(compName, value)
  assertCompProperty(compName, "uiSliderMin", value)
end

function assertCompMax(compName, value)
  assertCompProperty(compName, "uiSliderMax", value)
end

function assertTmpFile(filename, expectedContents)
  local contents = cutils.getFileContents(cutils.toFilePath(tmpFolderName, filename))
  local start, fin = string.find(contents, expectedContents, 1, true)
  assertEqual(fin - start + 1, string.len(expectedContents))
end

function setup()
  os.execute("if exist " .. tmpFolderName .. " rmdir /S /Q " .. tmpFolderName)
  os.execute("mkdir " .. tmpFolderName)

  processListenerCalls = 0
  processActive = false
  local processListener = function(active)
    processActive = active
    processListenerCalls = processListenerCalls + 1
  end
  
  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
  end

  tempOsExecute = os.execute
  executedOsCommands = {}
  os.execute = function(cmd) table.insert(executedOsCommands, cmd) end

  tempUtilsInfoWindow = utils.infoWindow
  openedInfoWindows = {}
  utils.infoWindow = function(title, message) table.insert(openedInfoWindows, message) end

  ctrlrwork = File(tmpFolderName)

  setupIntegrationTest(tmpFolderName, processListener, midiListener)
end

function teardown()
  os.execute = tempOsExecute
  utils.infoWindow = tempUtilsInfoWindow
  
  tearDownIntegrationTest(tmpFolderName)
  os.execute("rmdir /S /Q " .. tmpFolderName)
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

--function testOnKeyGroupNumChange()
--  local numKgs = 1
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, 0, {})
--  assertEqual(drumMap.numKgs, numKgs)
--end
--
--function testOnKeyGroupChange_MultipleKeyGroups_OneSelected()
--  local selectedKg = 4
--  local numKgs = 7
--  drumMapController:onKeyGroupNumChange(numKgs)
--  drumMapController:onPadSelected(newKeyGroupComponent(selectedKg))
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, selectedKg, {})
--  assertEqual(drumMap.numKgs, numKgs)
--end
--
--function testOnKeyGroupChange_MultipleKeyGroups_UnselectedPad()
--  local selectedKg = 4
--  local numKgs = 7
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local comp = newKeyGroupComponent(selectedKg)
--  onPadSelected(comp)
--  onPadSelected(comp)
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, 0, {})
--  assertEqual(drumMap.numKgs, numKgs)
--end
--
--function testOnKeyGroupChange_MultipleKeyGroups_OneSelected_FilesLoaded()
--  local selectedKg = 4
--  local numKgs = 7
--  local secondKg = 3
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--  assignSamples(selectedComp, "Cat-Meow.wav", "Electric-Bass-High-Bb-Staccato.wav")
--
--  assignSamples(secondKg, "Casio-CZ-5000-Synth-Bass-C1.wav", "Bowed-Bass-C2.wav")
--
--  drumMapController:onPadSelected(selectedComp)
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
--    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
--  })
--  assertEqual(drumMap.numKgs, numKgs)
--end
--
--function testOnKeyGroupClear()
--  local selectedKg = 14
--  local numKgs = 15
--  local secondKg = 13
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--  assignSamples(selectedComp, "Cat-Meow.wav", "Electric-Bass-High-Bb-Staccato.wav")
--
--  assignSamples(secondKg, "Casio-CZ-5000-Synth-Bass-C1.wav", "Bowed-Bass-C2.wav")
--
--  drumMapController:onPadSelected(selectedComp)
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
--    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
--  })
--  assertEqual(drumMap.numKgs, numKgs)
--
--  drumMapController:onKeyGroupClear()
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, selectedKg, {
--    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
--  })
--  assertEqual(drumMap.numKgs, numKgs)
--end
--
--function testOnDrumMapClear()
--  local selectedKg = 5
--  local numKgs = 6
--  local secondKg = 2
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--  assignSamples(selectedComp, "Cat-Meow.wav", "Electric-Bass-High-Bb-Staccato.wav")
--
--  assignSamples(secondKg, "Casio-CZ-5000-Synth-Bass-C1.wav", "Bowed-Bass-C2.wav")
--
--  drumMapController:onPadSelected(selectedComp)
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
--    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
--  })
--  assertEqual(drumMap.numKgs, numKgs)
--
--  drumMapController:onDrumMapClear()
--
--  assertCompProperty("drumMapSelectionLabel", "")
--  verifyPads(numKgs, selectedKg, {})
--  assertEqual(drumMap.numKgs, numKgs)
--end
--
--function testOnCreateProgram()
--  local numKgs = 2
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--  local kg1 = newKeyGroupComponent(1)
--  local kg2 = newKeyGroupComponent(2)
--
--  drumMapController:onPadSelected(kg1)
--  drumMapController:onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
--  drumMapController:onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
--  local highVal = 25
--  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)
--  drumMapController:onDrumMapKeyChange(highMod, highVal)
--
--  drumMapController:onPadSelected(kg2)
--  drumMapController:onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
--
--  drumMapController:onTransferSamples()
--  globalController:onMidiReceived(newSlistMsg(0))
--  writeLauncherLog(2, 4, ctrlrwork, tmpFolderName)
--  globalController:onMidiReceived(newSlistMsg(2))
--  globalController:onMidiReceived(newSlistMsg(4))
--
--  verifyPads(numKgs, 2, {
--    [1] = "PULL-GTR--G2\nDAMP-GBSN--L\nDAMP-GBSN--R",
--    [2] = "DAMP-GBSN--L\nDAMP-GBSN--R"
--  })
--
--  local comp = panel:getComponent("programCreateNameLbl")
--  local progName = "ProgName"
--  comp:setProperty("uiLabelText", progName)
--
--  drumMapController:onCreateProgram()
--
--  assertText("PRNAME", midiService:toAkaiString(progName))
--  assertText("SNAME1", "PULL-GTR--G2")
--  assertModValue("VPANO1", 0)
--  assertModValue("VLOUD1", 63)
--  
--  assertText("SNAME2", "DAMP-GBSN--L")
--  assertModValue("VPANO2", -50)
--  assertModValue("VLOUD2", 63)
--  
--  assertText("SNAME3", "DAMP-GBSN--R")
--  assertModValue("VPANO3", 50)
--  assertModValue("VLOUD3", 63)
--  
--  assertModValue("LONOTE", 0)
--  assertModValue("HINOTE", 25)
--  
--  assertCompMax("programSelector", 1)
--  assertModValue("programSelector", 1)
--  
--  assertCompMax("kgSelector", 2)
--  assertModValue("kgSelector", 1)
--
--  assertEqual(programList:getNumPrograms(), 1)
--
--  local program = programList:getProgram(1)
--  
--  assertEqual(program:getName(), midiService:toAkaiString(progName))
--  assertEqual(program:getProgramNumber(), 0)
--  assertEqual(program:getActiveKeyGroupIndex(), 1)
--  assertEqual(program:getNumKeyGroups(), 2)
--  
--  local kg1Result = program:getKeyGroup(1)
--  assertEqual(kg1Result:numZones(), 3)
--  assertEqual(kg1Result:getParamValue("LONOTE"), 0)
--  assertEqual(kg1Result:getParamValue("HINOTE"), 25)
--  
--  local kg2Result = program:getKeyGroup(2)
--  assertEqual(kg2Result:numZones(), 2)
--  assertEqual(kg2Result:getParamValue("LONOTE"), 1)
--  assertEqual(kg2Result:getParamValue("HINOTE"), 1)
--end
--
--function testOnFileDoubleClicked()
--  local numKgs = 3
--  local selectedKg = 3
--
--  local secondKg = 1
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onFileDoubleClicked(File("test/data/Bowed-Bass-C2.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Bowed-Bass-C2.wav"
--  })
--
--  drumMapController:onFileDoubleClicked(File("test/data/Cat-Meow.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav"
--  })
--
--  -- Test when pads are deselected
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onFileDoubleClicked(File("test/data/Closed-Hi-Hat-1.wav"))
--  verifyPads(numKgs, 0, {
--    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav"
--  })
--
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onFileDoubleClicked(File("test/data/Closed-Hi-Hat-1.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav"
--  })
--
--  drumMapController:onFileDoubleClicked(File("test/data/Closed-Hi-Hat-2.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav\nClosed-Hi-Hat-2.wav"
--  })
--
--  -- Key group full
--  drumMapController:onFileDoubleClicked(File("test/data/Closed-Hi-Hat-3.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav\nClosed-Hi-Hat-2.wav"
--  })
--end
--
--function testOnSampleSelected()
--  local numKgs = 16
--  local selectedKg = 15
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  drumMapController:onFileSelected(File("test/data/Cat-Meow.wav"))
--  assertDisabled("assignSample")
--
--  drumMapController:onFileSelected(File("test/data/Invalid.txt"))
--  assertDisabled("assignSample")
--  assertText("lcdLabel", "Please select a wav file")
--
--  drumMapController:onPadSelected(newKeyGroupComponent(selectedKg))
--  drumMapController:onFileSelected(File("test/data/Cat-Meow.wav"))
--  assertEnabled("assignSample")
--end
--
--function testOnPadSelected()
--  local numKgs = 15
--  local selectedKg = 8
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  drumMapController:onPadSelected(newKeyGroupComponent(selectedKg))
--  assertDisabled("assignSample")
--
--  drumMapController:onFileSelected(File("test/data/Cat-Meow.wav"))
--  assertEnabled("assignSample")
--end
--
--function testOnTransferSamples_FloppyImgPath()
--  local numKgs = 1
--  local selectedKg = 1
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
--  drumMapController:onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
--  })
--
--  settings:setFloppyImgPath(File("test/data/SL1041.img"))
--
--  drumMapController:onTransferSamples()
--
--  assertFalse(processActive)
--
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
--  })
--
--  assertTmpFile("scriptLauncher.bat", settings:getHxcPath())
--  assertTmpFile("scriptLauncher.bat", "-uselayout:AKAIS3000_HD")
--  assertTmpFile("scriptLauncher.bat", "-finput:" .. settings:getFloppyImgPath())
--  assertTmpFile("scriptLauncher.bat", "-usb:")
--end
--
--function testOnTransferSamples_NextFloppy()
--  local numKgs = 1
--  local selectedKg = 1
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
--  drumMapController:onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
--  })
--
--  drumMap:insertToCurrentFloppy(File("test/data/PULL-GTR--G2.wav"))
--  drumMap:insertToCurrentFloppy(File("test/data/DAMP-GBSN-A5.wav"))
--
--  drumMapController:onTransferSamples()
--
--  assertTrue(processActive)
--  globalController:onMidiReceived(newSlistMsg(0))
--
--  globalController:onMidiReceived(newSlistMsg(1))
--
--  writeLauncherLog(2, 4, ctrlrwork, tmpFolderName)
--
--  globalController:onMidiReceived(newSlistMsg(2))
--  globalController:onMidiReceived(newSlistMsg(2))
--  globalController:onMidiReceived(newSlistMsg(2))
--
--  globalController:onMidiReceived(newSlistMsg(4))
--
--  assertFalse(processActive)
--
--  local namesString = "DAMP-GBSN--L\nDAMP-GBSN--R\nPULL-GTR--G2\nSMACKIN     "
--  assertCompProperty("noSamplesLabel", "componentVisibility", 0)
--  assertCompProperty("noSamplesLabel-1", "componentVisibility", 0)
--  assertCompProperty("samplerFileList", "componentVisibility", 1)
--  assertCompProperty("samplerFileList", "uiListBoxContent", namesString)
--  assertCompProperty("samplerSampleList", "componentVisibility", 1)
--  assertCompProperty("samplerSampleList", "uiListBoxContent", namesString)
--  assertCompProperty("SNAME1", "uiComboContent", namesString)
--  assertCompProperty("SNAME2", "uiComboContent", namesString)
--  assertCompProperty("SNAME3", "uiComboContent", namesString)
--  assertCompProperty("SNAME4", "uiComboContent", namesString)
--
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "PULL-GTR--G2\nDAMP-GBSN--L\nDAMP-GBSN--R"
--  })
--
--  assertText("lcdLabel", "Data transfer done.")
--  assertTrue(drumMap:hasLoadedAllSamples())
--end

function testOnLoadOs()
  drumMapController:onLoadOs()

  assertDisabled("loadOsButton")
  assertText("lcdLabel", "Loading Akai S2000 OS...")

  for i = 1, 21 do
    globalController:onMidiReceived(MockMidiMessage(MemoryBlock("F0 47 00 01 48 00 11 6E 07 30 06 00 00 00 08 00 32 3E 07 00 F7")))
  end

  assertText("lcdLabel", "Akai S2000 OS loaded.")
  assertEnabled("loadOsButton")
end

function testOnCancelProcess()

  assertNil(processController.currProc)
  processController:abort()
  assertNil(processController.currProc)

  assertText("lcdLabel", "No active process to abort!")

  local transferProc = Process()
    :withAbortGenerator(hxcService:getHxcAborter())

  processController.currProc = transferProc

  processController:abort()

  assertNil(processController.currProc)

  assertTmpFile("scriptAborter.bat", "for /f \"tokens=2 delims=,\" %%a in ('tasklist /v /fo csv ^| findstr /i \"hxcfe\"') do set \"$PID=%%a\"\r\ntaskkill /F /PID %$PID%\r\n\r\nexit\r\n")
end

--function testOnRslist()
--  local numKgs = 1
--  local selectedKg = 1
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
--  drumMapController:onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
--  })
--
--  drumMapController:onRslist()
--
--  assertTrue(processActive)
--  assertText("lcdLabel", "Receiving sample list...")
--
--  local namesString = "DAMP GBSN A2\nDAMP GBSN A3\nDAMP GBSN C5\nDAMP GBSN E3\nDAMP GBSN E4\nDAMP GTR C5 \nDAMP GTR D3 \nDAMP GTR E4 \nDAMP GTR G2 \nDAMP-GBSN--L\nDAMP-GBSN--R\nGBSN 335 A2 \nGBSN 335 A3 \nGBSN 335 A4 \nGBSN 335 E2 \nGBSN 335 E3 \nGBSN 335 E4 \nGBSN 335 E5 \nGBSN 335 PIK\nGBSN HARMONC\nMUTE GTR C5 \nMUTE GTR D3 \nMUTE GTR E4 \nMUTE GTR G2 \nPULL GTR D3 \nPULL GTR E4 \nPULL-GTR--G2\nSMACKIN     "
--  globalController:onMidiReceived(newSlistMsg(28))
--
--  assertFalse(processActive)
--
--  assertCompProperty("noSamplesLabel", "componentVisibility", 0)
--  assertCompProperty("noSamplesLabel-1", "componentVisibility", 0)
--  assertCompProperty("samplerFileList", "componentVisibility", 1)
--  assertCompProperty("samplerFileList", "uiListBoxContent", namesString)
--  assertCompProperty("SNAME1", "uiComboContent", namesString)
--  assertCompProperty("SNAME2", "uiComboContent", namesString)
--  assertCompProperty("SNAME3", "uiComboContent", namesString)
--  assertCompProperty("SNAME4", "uiComboContent", namesString)
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "PULL-GTR--G2\nDAMP-GBSN--L\nDAMP-GBSN--R"
--  })
--  assertTrue(drumMap:hasLoadedAllSamples())
--
--end
--
--function testOnSampleAssign()
--  local numKgs = 10
--  local selectedKg = 7
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  drumMapController:onPadSelected(newKeyGroupComponent(selectedKg))
--
--  drumMapController:onSampleAssign()
--  assertText("lcdLabel", "Select a sample and a key group.")
--
--  drumMapController:onFileSelected(File("test/data/Cat-Meow.wav"))
--
--  drumMapController:onSampleAssign()
--
--  verifyPads(numKgs, selectedKg, {
--    [selectedKg] = "Cat-Meow.wav"
--  })
--end
--
--function testOnDrumMapKeyChange()
--  local numKgs = 14
--  local selectedKg = 12
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  assertDisabled("drumMapLowKey")
--  assertDisabled("drumMapHighKey")
--
--  drumMapController:onPadSelected(newKeyGroupComponent(selectedKg))
--
--  assertEnabled("drumMapLowKey")
--  assertEnabled("drumMapHighKey")
--
--  assertModValue("drumMapLowKey", selectedKg - 1)
--  assertModValue("drumMapHighKey", selectedKg - 1)
--  --  assertModProperty("drumMapLowKey", "modulatorMin", 0)
--  assertModProperty("drumMapLowKey", "modulatorMax", selectedKg - 1)
--  assertModProperty("drumMapHighKey", "modulatorMin", selectedKg - 1)
--  --  assertModProperty("drumMapHighKey", "modulatorMax", selectedKg - 1)
--
--  local lowMod = newModulatorWithCustomIndex("drumMapLowKey", LOW_INDEX)
--  local lowVal = 1
--  local highVal = 25
--  drumMapController:onDrumMapKeyChange(lowMod, lowVal)
--
--  assertEnabled("drumMapLowKey")
--  assertEnabled("drumMapHighKey")
--
--  assertModValue("drumMapLowKey", lowVal)
--  assertModValue("drumMapHighKey", selectedKg - 1)
--
--  --  assertModProperty("drumMapLowKey", "modulatorMin", 0)
--  assertModProperty("drumMapLowKey", "modulatorMax", selectedKg - 1)
--  assertModProperty("drumMapHighKey", "modulatorMin", lowVal)
--  --  assertModProperty("drumMapHighKey", "modulatorMax", selectedKg - 1)
--
--  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)
--  drumMapController:onDrumMapKeyChange(highMod, highVal)
--
--  assertEnabled("drumMapLowKey")
--  assertEnabled("drumMapHighKey")
--
--  assertModValue("drumMapLowKey", lowVal)
--  assertModValue("drumMapHighKey", highVal)
--
--  --  assertModProperty("drumMapLowKey", "modulatorMin", 0)
--  assertModProperty("drumMapLowKey", "modulatorMax", highVal)
--  assertModProperty("drumMapHighKey", "modulatorMin", lowVal)
--  --  assertModProperty("drumMapHighKey", "modulatorMax", selectedKg - 1)
--end
--
--function testOnResetAllKeyRanges()
--  local numKgs = 7
--  local selectedKg = 4
--  local secondKg = 5
--  local thirdKg = 6
--  local LOW_INDEX, HIGH_INDEX = 1, 2
--
--  local lowVal = 1
--  local highVal = 25
--  local lowVal2 = 4
--  local highVal2 = 16
--
--  local lowMod = newModulatorWithCustomIndex("drumMapLowKey", LOW_INDEX)
--  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--  local secondComp = newKeyGroupComponent(secondKg)
--  local thirdComp = newKeyGroupComponent(thirdKg)
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  -- Try with one kg
--
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onDrumMapKeyChange(lowMod, lowVal)
--  drumMapController:onDrumMapKeyChange(highMod, highVal)
--
--  assertModValue("drumMapLowKey", lowVal)
--  assertModValue("drumMapHighKey", highVal)
--
--  drumMapController:onResetAllKeyRanges()
--
--  assertModValue("drumMapLowKey", selectedKg - 1)
--  assertModValue("drumMapHighKey", selectedKg - 1)
--
--  -- Try with three kgs
--
--  drumMapController:onDrumMapKeyChange(lowMod, lowVal)
--  drumMapController:onDrumMapKeyChange(highMod, highVal)
--
--  assertModValue("drumMapLowKey", lowVal)
--  assertModValue("drumMapHighKey", highVal)
--
--  drumMapController:onPadSelected(secondComp)
--
--  assertModValue("drumMapLowKey", secondKg - 1)
--  assertModValue("drumMapHighKey", secondKg - 1)
--
--  drumMapController:onDrumMapKeyChange(lowMod, lowVal2)
--  drumMapController:onDrumMapKeyChange(highMod, highVal2)
--
--  assertModValue("drumMapLowKey", lowVal2)
--  assertModValue("drumMapHighKey", highVal2)
--
--  drumMapController:onPadSelected(thirdComp)
--
--  assertModValue("drumMapLowKey", thirdKg - 1)
--  assertModValue("drumMapHighKey", thirdKg - 1)
--
--  drumMapController:onDrumMapKeyChange(lowMod, lowVal2)
--  drumMapController:onDrumMapKeyChange(highMod, highVal2)
--
--  assertModValue("drumMapLowKey", lowVal2)
--  assertModValue("drumMapHighKey", highVal2)
--
--  drumMapController:onResetAllKeyRanges()
--
--  assertModValue("drumMapLowKey", thirdKg - 1)
--  assertModValue("drumMapHighKey", thirdKg - 1)
--
--  drumMapController:onPadSelected(secondComp)
--  assertModValue("drumMapLowKey", secondKg - 1)
--  assertModValue("drumMapHighKey", secondKg - 1)
--
--  drumMapController:onPadSelected(selectedComp)
--  assertModValue("drumMapLowKey", selectedKg - 1)
--  assertModValue("drumMapHighKey", selectedKg - 1)
--end
--
--function testOnResetPadKeyRange()
--  local numKgs = 8
--  local selectedKg = 5
--  local secondKg = 6
--  local LOW_INDEX, HIGH_INDEX = 1, 2
--
--  local lowVal = 1
--  local highVal = 25
--  local lowVal2 = 4
--  local highVal2 = 16
--
--  local lowMod = newModulatorWithCustomIndex("drumMapLowKey", LOW_INDEX)
--  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)
--
--  local selectedComp = newKeyGroupComponent(selectedKg)
--  local secondComp = newKeyGroupComponent(secondKg)
--
--  drumMapController:onKeyGroupNumChange(numKgs)
--
--  drumMapController:onPadSelected(selectedComp)
--  drumMapController:onDrumMapKeyChange(lowMod, lowVal)
--  drumMapController:onDrumMapKeyChange(highMod, highVal)
--
--  assertModValue("drumMapLowKey", lowVal)
--  assertModValue("drumMapHighKey", highVal)
--
--  drumMapController:onPadSelected(secondComp)
--
--  assertModValue("drumMapLowKey", secondKg - 1)
--  assertModValue("drumMapHighKey", secondKg - 1)
--
--  drumMapController:onDrumMapKeyChange(lowMod, lowVal2)
--  drumMapController:onDrumMapKeyChange(highMod, highVal2)
--
--  assertModValue("drumMapLowKey", lowVal2)
--  assertModValue("drumMapHighKey", highVal2)
--
--  drumMapController:onPadSelected(selectedComp)
--
--  drumMapController:onResetPadKeyRange()
--
--  assertModValue("drumMapLowKey", selectedKg - 1)
--  assertModValue("drumMapHighKey", selectedKg - 1)
--
--  drumMapController:onPadSelected(secondComp)
--  assertModValue("drumMapLowKey", lowVal2)
--  assertModValue("drumMapHighKey", highVal2)
--end

runTests{useANSI = false}
