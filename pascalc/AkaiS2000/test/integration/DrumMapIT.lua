require("akaiS2kTestUtils")
require("integration/DrumMapFunctions")
require("MockPanel")
require("json4ctrlr")
require("cutils")

require("model/Process")
require("model/DrumMap")
require("model/SampleList")
require("model/Settings")

require("controller/DrumMapController")
require("controller/SettingsController")
require("controller/SampleListController")

require("service/S2kDieService")
require("service/HxcService")
require("service/DrumMapService")
require("service/ProcessService")
require("service/MidiService")

require("message/StatMsg")
require("message/RstatMsg")
require("message/KdataMsg")
require("message/SlistMsg")
require("message/RslistMsg")

require 'lunity'
require 'lemock'
module( 'DrumMapIT', lunity )

local tmpFolderName = "ctrlrwork"
local samplesData = {
  "0E 0B 17 1A 27 11 0C 1D 18 27 27 16", -- DAMP-GBSN--L
  "0E 0B 17 1A 27 11 0C 1D 18 27 27 1C",  -- DAMP-GBSN--R
  "1A 1F 16 16 27 11 1E 1C 27 27 11 02", -- PULL-GTR--G2 
  "1D 17 0B 0D 15 13 18 0A 0A 0A 0A 0A", -- SMACKIN     
  "17 1F 1E 0F 0A 11 1E 1C 0A 11 02 0A", -- MUTE GTR G2 
  "17 1F 1E 0F 0A 11 1E 1C 0A 0E 03 0A", -- MUTE GTR D3 
  "17 1F 1E 0F 0A 11 1E 1C 0A 0F 04 0A", -- MUTE GTR E4 
  "0E 0B 17 1A 0A 11 1E 1C 0A 11 02 0A", -- DAMP GTR G2 
  "0E 0B 17 1A 0A 11 1E 1C 0A 0E 03 0A", -- DAMP GTR D3 
  "0E 0B 17 1A 0A 11 1E 1C 0A 0F 04 0A", -- DAMP GTR E4 
  "17 1F 1E 0F 0A 11 1E 1C 0A 0D 05 0A", -- MUTE GTR C5 
  "0E 0B 17 1A 0A 11 1E 1C 0A 0D 05 0A", -- DAMP GTR C5 
  "1A 1F 16 16 0A 11 1E 1C 0A 0E 03 0A", -- PULL GTR D3 
  "1A 1F 16 16 0A 11 1E 1C 0A 0F 04 0A", -- PULL GTR E4 
  "11 0C 1D 18 0A 03 03 05 0A 0F 02 0A", -- GBSN 335 E2 
  "11 0C 1D 18 0A 03 03 05 0A 0B 02 0A", -- GBSN 335 A2 
  "11 0C 1D 18 0A 03 03 05 0A 0F 03 0A", -- GBSN 335 E3 
  "11 0C 1D 18 0A 03 03 05 0A 0B 03 0A", -- GBSN 335 A3 
  "11 0C 1D 18 0A 03 03 05 0A 0F 04 0A", -- GBSN 335 E4 
  "11 0C 1D 18 0A 03 03 05 0A 0B 04 0A", -- GBSN 335 A4 
  "11 0C 1D 18 0A 03 03 05 0A 0F 05 0A", -- GBSN 335 E5 
  "11 0C 1D 18 0A 03 03 05 0A 1A 13 15", -- GBSN 335 PIK
  "11 0C 1D 18 0A 12 0B 1C 17 19 18 0D", -- GBSN HARMONC
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0F 04", -- DAMP GBSN E4
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0D 05", -- DAMP GBSN C5
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0B 02", -- DAMP GBSN A2
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0F 03", -- DAMP GBSN E3
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0B 03", -- DAMP GBSN A3
}

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

function assertModMin(modName, value)
  fail("Not implemented")
  assertEqual(panel:getModulatorByName(modName):getValue(), value)
end

function assertModMax(modName, value)
  fail("Not implemented")
  assertEqual(panel:getModulatorByName(modName):getValue(), value)
end

function assertTmpFile(filename, expectedContents)
  local contents = cutils.getFileContents(cutils.toFilePath(tmpFolderName, filename))
  local start, fin = string.find(contents, expectedContents, 1, true)
  assertEqual(fin - start + 1, string.len(expectedContents))
end

function setup()
  regGlobal("OPERATING_SYSTEM", "win")
  regGlobal("PATH_SEPARATOR", "\\")
  regGlobal("EOL", "\n")

  os.execute("if exist " .. tmpFolderName .. " rmdir /S /Q " .. tmpFolderName)

  os.execute("mkdir " .. tmpFolderName)
  regGlobal("panel", MockPanel())
  regGlobal("LOGGER", Logger("GLOBAL"))

  local settings = Settings()
  settings:setWorkFolder(File("ctrlrwork"))
  settings:setS2kDiePath(File("c:\\ctrlr\\s2kdie\\s2kdie.php"))
  settings:setHxcPath(File("hxc.exe"))
  settings:setTransferMethod(1)

  local drumMap = DrumMap()
  local sampleList = SampleList()

  regGlobal("settings", settings)
  regGlobal("drumMap", drumMap)
  regGlobal("sampleList", sampleList)

  regGlobal("drumMapController", DrumMapController(drumMap))
  regGlobal("settingsController", SettingsController(settings))
  regGlobal("sampleListController", SampleListController(sampleList))

  tempOsExecute = os.execute
  executedOsCommands = {}
  os.execute = function(cmd) table.insert(executedOsCommands, cmd) end

  tempUtilsInfoWindow = utils.infoWindow
  openedInfoWindows = {}
  utils.infoWindow = function(title, message) table.insert(openedInfoWindows, message) end

  processListenerCalls = 0
  processActive = false
  local processListener = function(active)
    processActive = active
    processListenerCalls = processListenerCalls + 1
  end
  regGlobal("processService", ProcessService(processListener))
  regGlobal("drumMapService", DrumMapService(drumMap, sampleList))
  regGlobal("midiService", MidiService())
  regGlobal("s2kDieService", S2kDieService(settings))
  regGlobal("hxcService", HxcService(settings))
end

function teardown()
  delGlobal("midiService")
  delGlobal("panel")
  delGlobal("drumMap")
  delGlobal("settings")
  delGlobal("drumMapController")
  delGlobal("drumMapService")
  delGlobal("processService")
  os.execute = tempOsExecute
  os.execute("rmdir /S /Q " .. tmpFolderName)

  utils.infoWindow = tempUtilsInfoWindow
  
end

function newSlistMsg(numSamples)
  local bytes = string.format("F0 47 00 05 48 %.2X 00", numSamples)
  for i = 1, numSamples do
    bytes = string.format("%s %s", bytes, samplesData[i])
  end
  return MemoryBlock(string.format("%s %s", bytes, "F7"))
end

function newKeyGroupComponent(index)
  local comp = panel:getComponent(string.format("drumMap-%d", index))
  comp:setProperty("componentGroupName", string.format("drumMap-%d-grp", index))
  return comp
end

function newModulatorWithCustomIndex(name, customIndex)
  local mod = panel:getModulator(name)
  mod:setProperty("modulatorCustomIndex", string.format("%d", customIndex))
  return mod
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
  assertEqual(drumMap.numKgs, numKgs)
end

function testOnKeyGroupChange_MultipleKeyGroups_OneSelected()
  local selectedKg = 4
  local numKgs = 7
  onKeyGroupNumChange(numKgs)
  onPadSelected(newKeyGroupComponent(selectedKg))

  assertText("uiLabelText", "")
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

  assertText("uiLabelText", "")
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

  assertText("uiLabelText", "")
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

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMap.numKgs, numKgs)

  onKeyGroupClear()

  assertText("uiLabelText", "")
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

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav\nElectric-Bass-High-..",
    [secondKg] = "Casio-CZ-5000-Synth..\nBowed-Bass-C2.wav",
  })
  assertEqual(drumMap.numKgs, numKgs)

  onDrumMapClear()

  assertText("uiLabelText", "")
  verifyPads(numKgs, selectedKg, {})
  assertEqual(drumMap.numKgs, numKgs)
end

--function testOnCreateProgram()
--end

function testOnSampleDoubleClicked()
  local numKgs = 3
  local selectedKg = 3

  local secondKg = 1

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
  local numKgs = 16
  local selectedKg = 15

  onKeyGroupNumChange(numKgs)

  onSampleSelected(File("test/data/Cat-Meow.wav"))
  assertDisabled("assignSample")

  onSampleSelected(File("test/data/Invalid.txt"))
  assertDisabled("assignSample")
  assertText("lcdLabel", "Please select a wav file")

  onPadSelected(newKeyGroupComponent(selectedKg))
  onSampleSelected(File("test/data/Cat-Meow.wav"))
  assertEnabled("assignSample")
end

function testOnPadSelected()
  local numKgs = 15
  local selectedKg = 8

  onKeyGroupNumChange(numKgs)

  onPadSelected(newKeyGroupComponent(selectedKg))
  assertDisabled("assignSample")

  onSampleSelected(File("test/data/Cat-Meow.wav"))
  assertEnabled("assignSample")
end

function testOnTransferSamples_FloppyImgPath()
  local numKgs = 1
  local selectedKg = 1

  onKeyGroupNumChange(numKgs)

  local selectedComp = newKeyGroupComponent(selectedKg)

  onPadSelected(selectedComp)
  onSampleDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
  onSampleDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
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
  onSampleDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
  onSampleDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "PULL-GTR--G2.wav\nDAMP-GBSN-A5.wav"
  })

  drumMap:insertToCurrentFloppy(File("test/data/PULL-GTR--G2.wav"))
  drumMap:insertToCurrentFloppy(File("test/data/DAMP-GBSN-A5.wav"))

  onTransferSamples()

  assertTrue(processActive)
  midiService:dispatchMidi(newSlistMsg(0))

  midiService:dispatchMidi(newSlistMsg(1))

  cutils.writeToFile(tmpFolderName .. PATH_SEPARATOR .. "scriptLauncher.bat.log", "C:\ctrlr\Panels\pascalc\AkaiS2000>cp C:\ctrlr\Panels\pascalc\AkaiS2000\test\data\PULL-GTR-G2.wav C:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork\PULL-GTR-G2.wav\r\nC:\ctrlr\Panels\pascalc\AkaiS2000>cp C:\ctrlr\Panels\pascalc\AkaiS2000\test\data\DAMP-GBSN.wav C:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork\DAMP-GBSN.wav\r\nC:\ctrlr\Panels\pascalc\AkaiS2000>cd C:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork\r\nC:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork>php c:\ctrlr\s2kdie\s2kdie.php C:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork\script-40947.s2k\r\n\r\nAKAI S2000/S3000/S900 Disk Image Editor v1.1.2\r\n(? for help.)\r\n\r\nFloppy read/writes disabled, setfdprm not found.\r\n\r\nCommand selected: BLANK S2000\r\nImage in memory blanked.\r\nCommand selected: VOL script-40947.s2k\r\nSCRIPT-40947\r\nCommand selected: WLOAD PULL-GTR-G2.wav\r\nStereo WAV imported as akai samples.\r\nCommand selected: WLOAD DAMP-GBSN.wav\r\nStereo WAV imported as akai samples.\r\nCommand selected: SAVE C:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork\floppy-40947.img\r\nImage saved.\r\nCommand selected: DIR\r\n\r\n      S2000 Volume: SCRIPT-40947\r\n\r\n      Filename       Type        Bytes\r\n  [0] PULL-GTR-G-L   <UNKNOWN>   98034\r\n  [1] PULL-GTR-G-R   <UNKNOWN>   98034\r\n  [2] DAMP-GBSN.-L   <UNKNOWN>   37362\r\n  [3] DAMP-GBSN.-R   <UNKNOWN>   37362\r\n\r\n      1318 unused sectors.  (1349632 bytes free)\r\n\r\nCommand selected: \r\n\r\n\r\nC:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork>cd C:\ctrlr\Panels\pascalc\AkaiS2000\r\nC:\ctrlr\Panels\pascalc\AkaiS2000>C:\ctrlr\Panels\pascalc\AkaiS2000\hxc.exe -uselayout:AKAIS3000_HD -finput:C:\ctrlr\Panels\pascalc\AkaiS2000\ctrlrwork\floppy-40947.img -usb:\r\nC:\ctrlr\Panels\pascalc\AkaiS2000>exit\r\n")

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

  processService:abort()

  assertText("lcdLabel", "No active process to abort!")
  assertEqual(table.getn(executedOsCommands), 0)
  assertEqual(processListenerCalls, 0)

  local transferProc = Process()
    :withPath(settings:getWorkFolder())
    :withAbortGenerator(hxcService:getHxcAborter())
    :build()

  executedOsCommands = {}
  processListenerCalls = 0

  processService.curr_transfer_proc = transferProc

  processService:abort()

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
  onSampleDoubleClicked(File("test/data/PULL-GTR--G2.wav"))
  onSampleDoubleClicked(File("test/data/DAMP-GBSN-A5.wav"))
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

end

function testOnSampleAssign()
  local numKgs = 10
  local selectedKg = 7

  onKeyGroupNumChange(numKgs)

  onPadSelected(newKeyGroupComponent(selectedKg))

  onSampleAssign()
  assertText("lcdLabel", "Select a sample and a key group.")

  onSampleSelected(File("test/data/Cat-Meow.wav"))

  onSampleAssign()

  verifyPads(numKgs, selectedKg, {
    [selectedKg] = "Cat-Meow.wav"
  })
end

function testOnDrumMapKeyChange()
  local numKgs = 14
  local selectedKg = 12
  local LOW_INDEX, HIGH_INDEX = 1, 2

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
