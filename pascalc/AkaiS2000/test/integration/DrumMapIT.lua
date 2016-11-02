require("akaiS2kTestUtils")
require("integration/DrumMapFunctions")
require("integration/ProgramFunctions")
require("MockPanel")
require("json4ctrlr")
require("cutils")

require("model/Process")
require("model/DrumMap")
require("model/SampleList")
require("model/ProgramList")
require("model/Settings")

require("controller/DrumMapController")
require("controller/SettingsController")
require("controller/SampleListController")
require("controller/ProcessController")
require("controller/ProgramController")

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

function testOnFloppyImageCleared()
  onFloppyImageCleared()

  assertText("loadFloppyImageLabel", "")
  assertText("lcdLabel", "Select a sample and a key group")
  assertEnabled("transferSamples")
end

function testOnKeyGroupNumChange()
  local numKgs = 1
  onKeyGroupNumChange(numKgs)

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, 0, {})
  assertEqual(drumMap.numKgs, numKgs)
end

function testOnKeyGroupChange_MultipleKeyGroups_OneSelected()
  local selectedKg = 4
  local numKgs = 7
  onKeyGroupNumChange(numKgs)
  onPadSelected(newKeyGroupComponent(selectedKg))

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, selectedKg, {})
  assertEqual(drumMap.numKgs, numKgs)
end

function testOnKeyGroupChange_MultipleKeyGroups_UnselectedPad()
  local selectedKg = 4
  local numKgs = 7
  onKeyGroupNumChange(numKgs)

  local comp = newKeyGroupComponent(selectedKg)
  onPadSelected(comp)
  onPadSelected(comp)

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, 0, {})
  assertEqual(drumMap.numKgs, numKgs)
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

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMap.numKgs, numKgs)
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

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMap.numKgs, numKgs)

  onKeyGroupClear()

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, selectedKg, {
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMap.numKgs, numKgs)
end

function testOnDrumMapClear()
  local selectedKg = 5
  local numKgs = 6
  local secondKg = 2

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)
  assignSamples(selectedComp, "Cat-Meow.wav", "Electric-Bass-High-Bb-Staccato.wav")

  assignSamples(secondKg, "Casio-CZ-5000-Synth-Bass-C1.wav", "Bowed-Bass-C2.wav")

  onPadSelected(selectedComp)

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMap.numKgs, numKgs)

  onDrumMapClear()

  assertCompProperty("drumMapSelectionLabel", "")
  verifyPads(numKgs, selectedKg, {})
  assertEqual(drumMap.numKgs, numKgs)
end

function testOnCreateProgram()
  local numKgs = 2

  onKeyGroupNumChange(numKgs)
  local kg1 = newKeyGroupComponent(1)
  local kg2 = newKeyGroupComponent(2)

  onPadSelected(kg1)
  onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
  onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
  local highVal = 25
  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)
  onDrumMapKeyChange(highMod, highVal)

  onPadSelected(kg2)
  onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))

  onTransferSamples()
  midiService:dispatchMidi(newSlistMsg(0))
  writeLauncherLog(2, 4, ctrlrwork, tmpFolderName)
  midiService:dispatchMidi(newSlistMsg(2))
  midiService:dispatchMidi(newSlistMsg(4))

  verifyPads(numKgs, 2, {
    [1] = "PULL-GTR--G2\nDAMP-GBSN--L\nDAMP-GBSN--R",
    [2] = "DAMP-GBSN--L\nDAMP-GBSN--R"
  })

  local comp = panel:getComponent("programCreateNameLbl")
  local progName = "ProgName"
  comp:setProperty("uiLabelText", progName)

  onCreateProgram()

  assertText("PRNAME", toAkaiString(progName))
  assertText("zone1Selector", "PULL-GTR--G2")
  assertModValue("VPANO1", 0)
  assertModValue("VLOUD1", 63)
  
  assertText("zone2Selector", "DAMP-GBSN--L")
  assertModValue("VPANO2", -50)
  assertModValue("VLOUD2", 63)
  
  assertText("zone3Selector", "DAMP-GBSN--R")
  assertModValue("VPANO3", 50)
  assertModValue("VLOUD3", 63)
  
  assertModValue("LONOTE", 0)
  assertModValue("HINOTE", 25)
  
  assertCompMax("programSelector", 1)
  assertModValue("programSelector", 1)
  
  assertCompMax("kgSelector", 2)
  assertModValue("kgSelector", 1)

  assertEqual(programList:getNumPrograms(), 1)

  local program = programList:getProgram(1)
  
  assertEqual(program:getName(), toAkaiString(progName))
  assertEqual(program:getProgramNumber(), 0)
  assertEqual(program:getActiveKeyGroupIndex(), 1)
  assertEqual(program:getNumKeyGroups(), 2)
  
  local kg1Result = program:getKeyGroup(1)
  assertEqual(kg1Result:numZones(), 3)
  assertEqual(kg1Result:getParamValue("LONOTE"), 0)
  assertEqual(kg1Result:getParamValue("HINOTE"), 25)
  
  local kg2Result = program:getKeyGroup(2)
  assertEqual(kg2Result:numZones(), 2)
  assertEqual(kg2Result:getParamValue("LONOTE"), 1)
  assertEqual(kg2Result:getParamValue("HINOTE"), 1)
end

function testOnFileDoubleClicked()
  local numKgs = 3
  local selectedKg = 3

  local secondKg = 1

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)

  onPadSelected(selectedComp)
  onFileDoubleClicked(File("test/data/Bowed-Bass-C2.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav"
  })

  onFileDoubleClicked(File("test/data/Cat-Meow.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav"
  })

  -- Test when pads are deselected
  onPadSelected(selectedComp)
  onFileDoubleClicked(File("test/data/Closed-Hi-Hat-1.wav"))
  verifyPads(numKgs, 0, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav"
  })

  onPadSelected(selectedComp)
  onFileDoubleClicked(File("test/data/Closed-Hi-Hat-1.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav"
  })

  onFileDoubleClicked(File("test/data/Closed-Hi-Hat-2.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav\nClosed-Hi-Hat-2.wav"
  })

  -- Key group full
  onFileDoubleClicked(File("test/data/Closed-Hi-Hat-3.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Bowed-Bass-C2.wav\nCat-Meow.wav\nClosed-Hi-Hat-1.wav\nClosed-Hi-Hat-2.wav"
  })
end

function testOnSampleSelected()
  local numKgs = 16
  local selectedKg = 15

  onKeyGroupNumChange(numKgs)

  onFileSelected(File("test/data/Cat-Meow.wav"))
  assertDisabled("assignSample")

  onFileSelected(File("test/data/Invalid.txt"))
  assertDisabled("assignSample")
  assertText("lcdLabel", "Please select a wav file")

  onPadSelected(newKeyGroupComponent(selectedKg))
  onFileSelected(File("test/data/Cat-Meow.wav"))
  assertEnabled("assignSample")
end

function testOnPadSelected()
  local numKgs = 15
  local selectedKg = 8

  onKeyGroupNumChange(numKgs)

  onPadSelected(newKeyGroupComponent(selectedKg))
  assertDisabled("assignSample")

  onFileSelected(File("test/data/Cat-Meow.wav"))
  assertEnabled("assignSample")
end

function testOnTransferSamples_FloppyImgPath()
  local numKgs = 1
  local selectedKg = 1

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)

  onPadSelected(selectedComp)
  onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
  onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
  })

  settings:setFloppyImgPath(File("test/data/SL1041.img"))

  onTransferSamples()

  assertFalse(processActive)

  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
  })

  assertTmpFile("scriptLauncher.bat", settings:getHxcPath())
  assertTmpFile("scriptLauncher.bat", "-uselayout:AKAIS3000_HD")
  assertTmpFile("scriptLauncher.bat", "-finput:" .. settings:getFloppyImgPath())
  assertTmpFile("scriptLauncher.bat", "-usb:")
end

function testOnTransferSamples_NextFloppy()
  local numKgs = 1
  local selectedKg = 1

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)

  onPadSelected(selectedComp)
  onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
  onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
  })

  drumMap:insertToCurrentFloppy(File("test/data/PULL-GTR--G2.wav"))
  drumMap:insertToCurrentFloppy(File("test/data/DAMP-GBSN-A5.wav"))

  onTransferSamples()

  assertTrue(processActive)
  midiService:dispatchMidi(newSlistMsg(0))

  midiService:dispatchMidi(newSlistMsg(1))

  writeLauncherLog(2, 4, ctrlrwork, tmpFolderName)

  midiService:dispatchMidi(newSlistMsg(2))
  midiService:dispatchMidi(newSlistMsg(2))
  midiService:dispatchMidi(newSlistMsg(2))

  midiService:dispatchMidi(newSlistMsg(4))

  assertFalse(processActive)

  local namesString = "DAMP-GBSN--L\nDAMP-GBSN--R\nPULL-GTR--G2\nSMACKIN     "
  assertCompProperty("noSamplesLabel", "componentVisibility", 0)
  assertCompProperty("noSamplesLabel-1", "componentVisibility", 0)
  assertCompProperty("samplerFileList", "componentVisibility", 1)
  assertCompProperty("samplerFileList-1", "componentVisibility", 1)
  assertCompProperty("samplerFileList", "uiListBoxContent", namesString)
  assertCompProperty("samplerFileList-1", "uiListBoxContent", namesString)
  assertCompProperty("zone1Selector", "uiComboContent", namesString)
  assertCompProperty("zone2Selector", "uiComboContent", namesString)
  assertCompProperty("zone3Selector", "uiComboContent", namesString)
  assertCompProperty("zone4Selector", "uiComboContent", namesString)

  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "PULL-GTR--G2\nDAMP-GBSN--L\nDAMP-GBSN--R"
  })

  assertText("lcdLabel", "Data transfer done.")
  assertTrue(drumMap:hasLoadedAllSamples())
end

function testOnLoadOs()
  onLoadOs()

  assertTrue(processActive)
  assertDisabled("loadOsButton")

  midiService:dispatchMidi(MemoryBlock("F0 47 00 01 48 00 11 6E 07 30 06 00 00 00 08 00 32 3E 07 00 F7"))

  assertFalse(processActive)
  assertText("lcdLabel", "Akai S2000 OS loaded.")
  assertEnabled("loadOsButton")
end

function testOnCancelProcess()

  processController:abort()

  assertText("lcdLabel", "No active process to abort!")
  assertEqual(table.getn(executedOsCommands), 0)
  assertEqual(processListenerCalls, 0)

  local transferProc = Process()
    :withPath(settings:getWorkFolder())
    :withAbortGenerator(hxcService:getHxcAborter())
    :build()

  executedOsCommands = {}
  processListenerCalls = 0

  processController.curr_transfer_proc = transferProc

  processController:abort()

  assertEqual(table.getn(executedOsCommands), 1)
  assertEqual(processListenerCalls, 1)
  assertFalse(processActive)

  assertTmpFile("scriptAborter.bat", "for /f \"tokens=2 delims=,\" %%a in ('tasklist /v /fo csv ^| findstr /i \"hxcfe\"') do set \"$PID=%%a\"\r\ntaskkill /F /PID %$PID%\r\n\r\nexit\r\n")

end

function testOnRslist()
  local numKgs = 1
  local selectedKg = 1

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)

  onPadSelected(selectedComp)
  onFileDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
  onFileDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
  })

  onRslist()

  assertTrue(processActive)
  assertText("lcdLabel", "Receiving sample list...")

  local namesString = "DAMP GBSN A2\nDAMP GBSN A3\nDAMP GBSN C5\nDAMP GBSN E3\nDAMP GBSN E4\nDAMP GTR C5 \nDAMP GTR D3 \nDAMP GTR E4 \nDAMP GTR G2 \nDAMP-GBSN--L\nDAMP-GBSN--R\nGBSN 335 A2 \nGBSN 335 A3 \nGBSN 335 A4 \nGBSN 335 E2 \nGBSN 335 E3 \nGBSN 335 E4 \nGBSN 335 E5 \nGBSN 335 PIK\nGBSN HARMONC\nMUTE GTR C5 \nMUTE GTR D3 \nMUTE GTR E4 \nMUTE GTR G2 \nPULL GTR D3 \nPULL GTR E4 \nPULL-GTR--G2\nSMACKIN     "
  midiService:dispatchMidi(newSlistMsg(28))

  assertFalse(processActive)

  assertCompProperty("noSamplesLabel", "componentVisibility", 0)
  assertCompProperty("noSamplesLabel-1", "componentVisibility", 0)
  assertCompProperty("samplerFileList", "componentVisibility", 1)
  assertCompProperty("samplerFileList-1", "componentVisibility", 1)
  assertCompProperty("samplerFileList", "uiListBoxContent", namesString)
  assertCompProperty("samplerFileList-1", "uiListBoxContent", namesString)
  assertCompProperty("zone1Selector", "uiComboContent", namesString)
  assertCompProperty("zone2Selector", "uiComboContent", namesString)
  assertCompProperty("zone3Selector", "uiComboContent", namesString)
  assertCompProperty("zone4Selector", "uiComboContent", namesString)
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "PULL-GTR--G2\nDAMP-GBSN--L\nDAMP-GBSN--R"
  })
  assertTrue(drumMap:hasLoadedAllSamples())

end

function testOnSampleAssign()
  local numKgs = 10
  local selectedKg = 7

  onKeyGroupNumChange(numKgs)

  onPadSelected(newKeyGroupComponent(selectedKg))

  onSampleAssign()
  assertText("lcdLabel", "Select a sample and a key group.")

  onFileSelected(File("test/data/Cat-Meow.wav"))

  onSampleAssign()

  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav"
  })
end

function testOnDrumMapKeyChange()
  local numKgs = 14
  local selectedKg = 12

  onKeyGroupNumChange(numKgs)

  assertDisabled("drumMapLowKey")
  assertDisabled("drumMapHighKey")

  onPadSelected(newKeyGroupComponent(selectedKg))

  assertEnabled("drumMapLowKey")
  assertEnabled("drumMapHighKey")

  assertModValue("drumMapLowKey", selectedKg - 1)
  assertModValue("drumMapHighKey", selectedKg - 1)
  --  assertModProperty("drumMapLowKey", "modulatorMin", 0)
  assertModProperty("drumMapLowKey", "modulatorMax", selectedKg - 1)
  assertModProperty("drumMapHighKey", "modulatorMin", selectedKg - 1)
  --  assertModProperty("drumMapHighKey", "modulatorMax", selectedKg - 1)

  local lowMod = newModulatorWithCustomIndex("drumMapLowKey", LOW_INDEX)
  local lowVal = 1
  local highVal = 25
  onDrumMapKeyChange(lowMod, lowVal)

  assertEnabled("drumMapLowKey")
  assertEnabled("drumMapHighKey")

  assertModValue("drumMapLowKey", lowVal)
  assertModValue("drumMapHighKey", selectedKg - 1)

  --  assertModProperty("drumMapLowKey", "modulatorMin", 0)
  assertModProperty("drumMapLowKey", "modulatorMax", selectedKg - 1)
  assertModProperty("drumMapHighKey", "modulatorMin", lowVal)
  --  assertModProperty("drumMapHighKey", "modulatorMax", selectedKg - 1)

  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)
  onDrumMapKeyChange(highMod, highVal)

  assertEnabled("drumMapLowKey")
  assertEnabled("drumMapHighKey")

  assertModValue("drumMapLowKey", lowVal)
  assertModValue("drumMapHighKey", highVal)

  --  assertModProperty("drumMapLowKey", "modulatorMin", 0)
  assertModProperty("drumMapLowKey", "modulatorMax", highVal)
  assertModProperty("drumMapHighKey", "modulatorMin", lowVal)
  --  assertModProperty("drumMapHighKey", "modulatorMax", selectedKg - 1)
end

function testOnResetAllKeyRanges()
  local numKgs = 7
  local selectedKg = 4
  local secondKg = 5
  local thirdKg = 6
  local LOW_INDEX, HIGH_INDEX = 1, 2

  local lowVal = 1
  local highVal = 25
  local lowVal2 = 4
  local highVal2 = 16

  local lowMod = newModulatorWithCustomIndex("drumMapLowKey", LOW_INDEX)
  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)

  local selectedComp = newKeyGroupComponent(selectedKg)
  local secondComp = newKeyGroupComponent(secondKg)
  local thirdComp = newKeyGroupComponent(thirdKg)

  onKeyGroupNumChange(numKgs)

  -- Try with one kg

  onPadSelected(selectedComp)
  onDrumMapKeyChange(lowMod, lowVal)
  onDrumMapKeyChange(highMod, highVal)

  assertModValue("drumMapLowKey", lowVal)
  assertModValue("drumMapHighKey", highVal)

  onResetAllKeyRanges()

  assertModValue("drumMapLowKey", selectedKg - 1)
  assertModValue("drumMapHighKey", selectedKg - 1)

  -- Try with three kgs

  onDrumMapKeyChange(lowMod, lowVal)
  onDrumMapKeyChange(highMod, highVal)

  assertModValue("drumMapLowKey", lowVal)
  assertModValue("drumMapHighKey", highVal)

  onPadSelected(secondComp)

  assertModValue("drumMapLowKey", secondKg - 1)
  assertModValue("drumMapHighKey", secondKg - 1)

  onDrumMapKeyChange(lowMod, lowVal2)
  onDrumMapKeyChange(highMod, highVal2)

  assertModValue("drumMapLowKey", lowVal2)
  assertModValue("drumMapHighKey", highVal2)

  onPadSelected(thirdComp)

  assertModValue("drumMapLowKey", thirdKg - 1)
  assertModValue("drumMapHighKey", thirdKg - 1)

  onDrumMapKeyChange(lowMod, lowVal2)
  onDrumMapKeyChange(highMod, highVal2)

  assertModValue("drumMapLowKey", lowVal2)
  assertModValue("drumMapHighKey", highVal2)

  onResetAllKeyRanges()

  assertModValue("drumMapLowKey", thirdKg - 1)
  assertModValue("drumMapHighKey", thirdKg - 1)

  onPadSelected(secondComp)
  assertModValue("drumMapLowKey", secondKg - 1)
  assertModValue("drumMapHighKey", secondKg - 1)

  onPadSelected(selectedComp)
  assertModValue("drumMapLowKey", selectedKg - 1)
  assertModValue("drumMapHighKey", selectedKg - 1)
end

function testOnResetPadKeyRange()
  local numKgs = 8
  local selectedKg = 5
  local secondKg = 6
  local LOW_INDEX, HIGH_INDEX = 1, 2

  local lowVal = 1
  local highVal = 25
  local lowVal2 = 4
  local highVal2 = 16

  local lowMod = newModulatorWithCustomIndex("drumMapLowKey", LOW_INDEX)
  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)

  local selectedComp = newKeyGroupComponent(selectedKg)
  local secondComp = newKeyGroupComponent(secondKg)

  onKeyGroupNumChange(numKgs)

  onPadSelected(selectedComp)
  onDrumMapKeyChange(lowMod, lowVal)
  onDrumMapKeyChange(highMod, highVal)

  assertModValue("drumMapLowKey", lowVal)
  assertModValue("drumMapHighKey", highVal)

  onPadSelected(secondComp)

  assertModValue("drumMapLowKey", secondKg - 1)
  assertModValue("drumMapHighKey", secondKg - 1)

  onDrumMapKeyChange(lowMod, lowVal2)
  onDrumMapKeyChange(highMod, highVal2)

  assertModValue("drumMapLowKey", lowVal2)
  assertModValue("drumMapHighKey", highVal2)

  onPadSelected(selectedComp)

  onResetPadKeyRange()

  assertModValue("drumMapLowKey", selectedKg - 1)
  assertModValue("drumMapHighKey", selectedKg - 1)

  onPadSelected(secondComp)
  assertModValue("drumMapLowKey", lowVal2)
  assertModValue("drumMapHighKey", highVal2)
end

runTests{useANSI = false}
