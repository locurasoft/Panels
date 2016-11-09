require("akaiS2kTestUtils")
require("MockPanel")
require("json4ctrlr")
require("cutils")

require("model/Process")
require("model/DrumMap")
require("model/SampleList")
require("model/ProgramList")
require("model/Settings")

require("controller/DrumMapController")
require("controller/DrumMapControllerAutogen")
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

require("message/PheadMsg")
require("message/KheadMsg")
require("message/RstatMsg")
require("message/KdataMsg")
require("message/SlistMsg")
require("message/RslistMsg")

require 'lunity'
require 'lemock'
module( 'ProgramIT', lunity )

local LOW_INDEX, HIGH_INDEX = 1, 2
local tmpFolderName = "ctrlrwork"

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
  globalController:onMidiReceived(newSlistMsg(0))
  writeLauncherLog(2, 4, ctrlrwork, tmpFolderName)
  globalController:onMidiReceived(newSlistMsg(2))
  globalController:onMidiReceived(newSlistMsg(4))

  local comp = panel:getComponent("programCreateNameLbl")
  initialProgName = "ProgName"
  comp:setProperty("uiLabelText", initialProgName)

  onCreateProgram()
end

function teardown()
  os.execute = tempOsExecute
  utils.infoWindow = tempUtilsInfoWindow

  tearDownIntegrationTest(tmpFolderName)
  os.execute("rmdir /S /Q " .. tmpFolderName)
end

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

function assertProgramBlock(blockName, data)
  local program = programList:getActiveProgram()

  local pdata = PdataMsg()
  local offset = pdata:getOffset(PROGRAM_BLOCK[blockName])
  local buf = MemoryBlock(data:getSize(), true)
  program.pdata.data:copyTo(buf, offset, data:getSize())
  assertEqual(buf:toHexString(1), data:toHexString(1))
end

function assertKeygroupBlock(blockName, data)
  local program = programList:getActiveProgram()
  local kg = program:getActiveKeyGroup()

  local kdata = KdataMsg()
  local offset = kdata:getOffset(KEY_GROUP_BLOCK[blockName])
  local buf = MemoryBlock(data:getSize(), true)
  kg.kdata.data:copyTo(buf, offset, data:getSize())
  assertEqual(buf:toHexString(1), data:toHexString(1))
end

function printData(prog)
  local program = programList:getActiveProgram()
	if prog then
	 console(program.pdata.data:toHexString(1))
	else
    local kg = program:getKeyGroup(kgIndex)
    console(kg.kdata.data:toHexString(1))
	end
end

function testOnProgramChange()
  onDrumMapClear()
  
  onKeyGroupNumChange(3)
  local kg1 = newKeyGroupComponent(1)
  local kg2 = newKeyGroupComponent(2)
  local kg3 = newKeyGroupComponent(3)

  onPadSelected(kg1)
  onSampleDoubleClicked("SMACKIN     ")
  local highVal = 30
  local highMod = newModulatorWithCustomIndex("drumMapHighKey", HIGH_INDEX)
  onDrumMapKeyChange(highMod, highVal)

  onPadSelected(kg2)
  onSampleDoubleClicked("PULL-GTR--G2")

  local comp = panel:getComponent("programCreateNameLbl")
  comp:setProperty("uiLabelText", "Progname 2")

  onCreateProgram()
  
  local programSelector = panel:getModulatorByName("programSelector")
  onProgramChange(programSelector, 1)

  local prLoud = panel:getModulatorByName("PRLOUD")
  local modVpan = panel:getModulatorByName("MODVPAN1")
  local lfo1Wave = panel:getModulatorByName("LFO1WAVE")
  local prName = panel:getModulatorByName("PRNAME")
  local pTuno = panel:getModulatorByName("PTUNO")
  local panDep = panel:getModulatorByName("PANDEP")
  
  onProgDefaultParamChange(prLoud, 50)
  onProgDefaultParamChange(modVpan, -25)
  onProgDefaultParamChange(lfo1Wave, 3)
  onProgStringChange(prName, "Prog1")
  onProgTuneChange(pTuno, -2000)
  onProgDefaultParamChange(panDep, 49)
    
  onProgramChange(programSelector, 2)
  
  assertModValue("PRLOUD", 0)
  assertModValue("MODVPAN1", 0)
  assertModValue("LFO1WAVE", 0)
  assertText("PRNAME", midiService:toAkaiString("Progname 2"))
  assertModValue("PTUNO", 0)
  assertModValue("PANDEP", 0)
  
  onProgramChange(programSelector, 1)
  
  assertModValue("PRLOUD", 50)
  assertModValue("MODVPAN1", -25)
  assertModValue("LFO1WAVE", 3)
  assertText("PRNAME", midiService:toAkaiString("Prog1"))
  assertModValue("PTUNO", -2000)
  assertModValue("PANDEP", 49)
  
  onProgramChange(programSelector, 2)
  
  assertModValue("PRLOUD", 0)
  assertModValue("MODVPAN1", 0)
  assertModValue("LFO1WAVE", 0)
  assertText("PRNAME", midiService:toAkaiString("Progname 2"))
  assertModValue("PTUNO", 0)
  assertModValue("PANDEP", 0)
  
  onProgramChange(programSelector, 1)
  
  assertModValue("PRLOUD", 50)
  assertModValue("MODVPAN1", -25)
  assertModValue("LFO1WAVE", 3)
  assertText("PRNAME", midiService:toAkaiString("Prog1"))
  assertModValue("PTUNO", -2000)
  assertModValue("PANDEP", 49)
end

function testOnKeyGroupChange()
  local vss1 = panel:getModulatorByName("VSS1")
  local vloud1 = panel:getModulatorByName("VLOUD1")
  local lovel2 = panel:getModulatorByName("LOVEL2")
  local vpano3 = panel:getModulatorByName("VPANO2")
  local kFreq = panel:getModulatorByName("K_FREQ")
  local vtuno1 = panel:getModulatorByName("VTUNO1")
  local kgSelector = panel:getModulatorByName("kgSelector")
  
  onVssChange(vss1, -9999)
  onKgDefaultParamChange(vloud1, 37)
  onKgDefaultParamChange(lovel2, 127)
  onKgDefaultParamChange(vpano3, -25)
  onKgDefaultParamChange(kFreq, 25)
  onKgTuneChange(vtuno1, -2000)
    
  onKeyGroupChange(kgSelector, 2)
  
  assertModValue("VSS1", 0)
  assertModValue("VLOUD1", 63)
  assertModValue("LOVEL2", 0)
  assertModValue("VPANO2", 50)
  assertModValue("K_FREQ", 0)
  assertModValue("VTUNO1", 0)
  
  onKeyGroupChange(kgSelector, 1)
  
  assertModValue("VSS1", -9999)
  assertModValue("VLOUD1", 37)
  assertModValue("LOVEL2", 127)
  assertModValue("VPANO2", -25)
  assertModValue("K_FREQ", 25)
  assertModValue("VTUNO1", -2000)
  
  onKeyGroupChange(kgSelector, 2)
  
  assertModValue("VSS1", 0)
  assertModValue("VLOUD1", 63)
  assertModValue("LOVEL2", 0)
  assertModValue("VPANO2", 50)
  assertModValue("K_FREQ", 0)
  assertModValue("VTUNO1", 0)
  
  onKeyGroupChange(kgSelector, 1)
  
  assertModValue("VSS1", -9999)
  assertModValue("VLOUD1", 37)
  assertModValue("LOVEL2", 127)
  assertModValue("VPANO2", -25)
  assertModValue("K_FREQ", 25)
  assertModValue("VTUNO1", -2000)
end

function testOnVssChange()
  local mod1 = panel:getModulatorByName("VSS1")
  local mod2 = panel:getModulatorByName("VSS2")
  local mod3 = panel:getModulatorByName("VSS3")
  local mod4 = panel:getModulatorByName("VSS4")

  onKgDefaultParamChange(mod1, -9999)
  assertEqual(table.getn(midiMessages), 1)
  assertEqual(midiMessages[1], "f0 47 00 2a 48 00 00 01 0c 00 02 00 00 00 f7")
  assertKeygroupBlock("VSS1", MemoryBlock("00 00"))

  onKgDefaultParamChange(mod1, -5555)
  assertEqual(table.getn(midiMessages), 2)
  assertEqual(midiMessages[2], "f0 47 00 2a 48 00 00 01 0c 00 02 00 0c 15 f7")
  assertKeygroupBlock("VSS1", MemoryBlock(""))

  onKgDefaultParamChange(mod2, -2222)
  assertEqual(table.getn(midiMessages), 3)
  assertEqual(midiMessages[3], "f0 47 00 2a 48 00 00 01 0e 00 02 00 01 66 f7")
  assertKeygroupBlock("VSS2", MemoryBlock("01 66"))

  onKgDefaultParamChange(mod2, 0)
  assertEqual(table.getn(midiMessages), 4)
  assertEqual(midiMessages[4], "f0 47 00 2a 48 00 00 01 0e 00 02 00 0f 70 f7")
  assertKeygroupBlock("VSS2", MemoryBlock("0f 70"))

  onKgDefaultParamChange(mod3, 1)
  assertEqual(table.getn(midiMessages), 5)
  assertEqual(midiMessages[5], "f0 47 00 2a 48 00 00 01 10 00 02 00 00 71 f7")
  assertKeygroupBlock("VSS3", MemoryBlock("00 71"))

  onKgDefaultParamChange(mod3, 2222)
  assertEqual(table.getn(midiMessages), 6)
  assertEqual(midiMessages[6], "f0 47 00 2a 48 00 00 01 10 00 02 00 0d 7b f7")
  assertKeygroupBlock("VSS3", MemoryBlock("0d 7b"))

  onKgDefaultParamChange(mod4, 5555)
  assertEqual(table.getn(midiMessages), 7)
  assertEqual(midiMessages[7], "f0 47 00 2a 48 00 00 01 12 00 02 00 02 4c f7")
  assertKeygroupBlock("VSS4", MemoryBlock("02 4c"))

  onKgDefaultParamChange(mod4, 9999)
  assertEqual(table.getn(midiMessages), 8)
  assertEqual(midiMessages[8], "f0 47 00 2a 48 00 00 01 12 00 02 00 0e 61 f7")
  assertKeygroupBlock("VSS4", MemoryBlock("0e 61"))
end

function testOnKgDefaultParamChange()
  local mod1 = panel:getModulatorByName("VLOUD1")
  local mod2 = panel:getModulatorByName("LOVEL2")
  local mod3 = panel:getModulatorByName("VPANO2")
  local mod4 = panel:getModulatorByName("K_FREQ")

  onKgDefaultParamChange(mod1, 0)
  assertEqual(table.getn(midiMessages), 1)
  assertEqual(midiMessages[1], "f0 47 00 2a 48 00 00 01 32 00 02 00 00 00 f7")
  assertKeygroupBlock("VLOUD1", MemoryBlock("00 00"))

  onKgDefaultParamChange(mod1, 127)
  assertEqual(table.getn(midiMessages), 2)
  assertEqual(midiMessages[2], "f0 47 00 2a 48 00 00 01 32 00 02 00 0f 07 f7")
  assertKeygroupBlock("VLOUD1", MemoryBlock("0f 07"))

  onKgDefaultParamChange(mod2, 0)
  assertEqual(table.getn(midiMessages), 3)
  assertEqual(midiMessages[3], "f0 47 00 2a 48 00 00 01 46 00 02 00 00 00 f7")
  assertKeygroupBlock("LOVEL2", MemoryBlock("00 00"))

  onKgDefaultParamChange(mod2, 127)
  assertEqual(table.getn(midiMessages), 4)
  assertEqual(midiMessages[4], "f0 47 00 2a 48 00 00 01 46 00 02 00 0f 07 f7")
  assertKeygroupBlock("LOVEL2", MemoryBlock("0f 07"))

  onKgDefaultParamChange(mod3, -50)
  assertEqual(table.getn(midiMessages), 5)
  assertEqual(midiMessages[5], "f0 47 00 2a 48 00 00 01 4c 00 02 00 00 00 f7")
  assertKeygroupBlock("VPANO2", MemoryBlock("00 00"))

  onKgDefaultParamChange(mod3, 50)
  assertEqual(table.getn(midiMessages), 6)
  assertEqual(midiMessages[6], "f0 47 00 2a 48 00 00 01 4c 00 02 00 04 06 f7")
  assertKeygroupBlock("VPANO2", MemoryBlock("04 06"))

  onKgDefaultParamChange(mod4, -50)
  assertEqual(table.getn(midiMessages), 7)
  assertEqual(midiMessages[7], "f0 47 00 2a 48 00 00 01 08 00 02 00 00 00 f7")
  assertKeygroupBlock("K_FREQ", MemoryBlock("00 00"))

  onKgDefaultParamChange(mod4, 50)
  assertEqual(table.getn(midiMessages), 8)
  assertEqual(midiMessages[8], "f0 47 00 2a 48 00 00 01 08 00 02 00 04 06 f7")
  assertKeygroupBlock("K_FREQ", MemoryBlock("04 06"))
end

function testOnProgDefaultParamChange()
  local mod1 = panel:getModulatorByName("B_PTCHD")
  local mod2 = panel:getModulatorByName("PANRAT")
  local mod3 = panel:getModulatorByName("MWLDEP")
  local mod4 = panel:getModulatorByName("MODVPAN1")

  printData(true)
  onProgDefaultParamChange(mod1, 0)
  assertEqual(table.getn(midiMessages), 1)
  assertEqual(midiMessages[1], "f0 47 00 28 48 00 00 21 00 49 00 02 00 00 00 f7")
  assertProgramBlock("B_PTCHD", MemoryBlock("00 00"))
  printData(true)

  printData(true)
  onProgDefaultParamChange(mod1, 24)
  assertEqual(table.getn(midiMessages), 2)
  assertEqual(midiMessages[2], "f0 47 00 28 48 00 00 21 00 49 00 02 00 08 01 f7")
  assertProgramBlock("B_PTCHD", MemoryBlock("08 01"))
  printData(true)

  onProgDefaultParamChange(mod2, 0)
  assertEqual(table.getn(midiMessages), 3)
  assertEqual(midiMessages[3], "f0 47 00 28 48 00 00 21 00 1d 00 02 00 00 00 f7")
  assertProgramBlock("PANRAT", MemoryBlock("00 00"))

  onProgDefaultParamChange(mod2, 99)
  assertEqual(table.getn(midiMessages), 4)
  assertEqual(midiMessages[4], "f0 47 00 28 48 00 00 21 00 1d 00 02 00 03 06 f7")
  assertProgramBlock("PANRAT", MemoryBlock("03 06"))

  onProgDefaultParamChange(mod3, 0)
  assertEqual(table.getn(midiMessages), 5)
  assertEqual(midiMessages[5], "f0 47 00 28 48 00 00 21 00 24 00 02 00 00 00 f7")
  assertProgramBlock("MWLDEP", MemoryBlock("00 00"))

  onProgDefaultParamChange(mod3, 99)
  assertEqual(table.getn(midiMessages), 6)
  assertEqual(midiMessages[6], "f0 47 00 28 48 00 00 21 00 24 00 02 00 03 06 f7")
  assertProgramBlock("MWLDEP", MemoryBlock("03 06"))

  onProgDefaultParamChange(mod4, -50)
  assertEqual(table.getn(midiMessages), 7)
  assertEqual(midiMessages[7], "f0 47 00 28 48 00 00 21 00 59 00 02 00 00 00 f7")
  assertProgramBlock("MODVPAN1", MemoryBlock("00 00"))

  onProgDefaultParamChange(mod4, 50)
  assertEqual(table.getn(midiMessages), 8)
  assertEqual(midiMessages[8], "f0 47 00 28 48 00 00 21 00 59 00 02 00 04 06 f7")
  assertProgramBlock("MODVPAN1", MemoryBlock("04 06"))
end

function testOnKgTuneChange()
  local mod1 = panel:getModulatorByName("VTUNO1")
  local mod2 = panel:getModulatorByName("VTUNO2")
  local mod3 = panel:getModulatorByName("VTUNO3")
  local mod4 = panel:getModulatorByName("VTUNO4")

  onKgTuneChange(mod1, -5000)
  assertEqual(table.getn(midiMessages), 1)
  assertEqual(midiMessages[1], "f0 47 00 2a 48 00 00 01 30 00 04 00 00 00 0e 0c f7")
  assertKeygroupBlock("VTUNO1", MemoryBlock("00 00 0e 0c"))

  onKgTuneChange(mod2, -3333)
  assertEqual(table.getn(midiMessages), 2)
  assertEqual(midiMessages[2], "f0 47 00 2a 48 00 00 01 48 00 04 00 0c 0a 0e 0d f7")
  assertKeygroupBlock("VTUNO2", MemoryBlock("0c 0a 0e 0d"))

  onKgTuneChange(mod3, -1111)
  assertEqual(table.getn(midiMessages), 3)
  assertEqual(midiMessages[3], "f0 47 00 2a 48 00 00 01 60 00 04 00 04 0e 04 0f f7")
  assertKeygroupBlock("VTUNO3", MemoryBlock("04 0e 04 0f"))

  onKgTuneChange(mod4, 0)
  assertEqual(table.getn(midiMessages), 4)
  assertEqual(midiMessages[4], "f0 47 00 2a 48 00 00 01 78 00 04 00 00 00 00 00 f7")
  assertKeygroupBlock("VTUNO4", MemoryBlock("00 00 00 00"))

  onKgTuneChange(mod1, 1111)
  assertEqual(table.getn(midiMessages), 5)
  assertEqual(midiMessages[5], "f0 47 00 2a 48 00 00 01 30 00 04 00 0c 01 0b 00 f7")
  assertKeygroupBlock("VTUNO1", MemoryBlock("0c 01 0b 00"))

  onKgTuneChange(mod2, 2222)
  assertEqual(table.getn(midiMessages), 6)
  assertEqual(midiMessages[6], "f0 47 00 2a 48 00 00 01 48 00 04 00 08 03 06 01 f7")
  assertKeygroupBlock("VTUNO2", MemoryBlock("08 03 06 01"))

  onKgTuneChange(mod3, 3333)
  assertEqual(table.getn(midiMessages), 7)
  assertEqual(midiMessages[7], "f0 47 00 2a 48 00 00 01 60 00 04 00 04 05 01 02 f7")
  assertKeygroupBlock("VTUNO3", MemoryBlock("04 05 01 02"))

  onKgTuneChange(mod4, 4444)
  assertEqual(table.getn(midiMessages), 8)
  assertEqual(midiMessages[8], "f0 47 00 2a 48 00 00 01 78 00 04 00 00 07 0c 02 f7")
  assertKeygroupBlock("VTUNO4", MemoryBlock("00 07 0c 02"))

  onKgTuneChange(mod1, 5000)
  assertEqual(table.getn(midiMessages), 9)
  assertEqual(midiMessages[9], "f0 47 00 2a 48 00 00 01 30 00 04 00 00 00 02 03 f7")
  assertKeygroupBlock("VTUNO1", MemoryBlock("00 00 02 03"))
end

function testOnProgTuneChange()
  local modName = "PTUNO"
  local mod = panel:getModulatorByName(modName)

  onProgTuneChange(mod, -5000)
  assertEqual(table.getn(midiMessages), 1)
  assertEqual(midiMessages[1], "f0 47 00 28 48 00 00 21 00 41 00 04 00 00 00 0e 0c f7")
  assertProgramBlock("PTUNO", MemoryBlock("00 00 0e 0c"))

  onProgTuneChange(mod, -4444)
  assertEqual(table.getn(midiMessages), 2)
  assertEqual(midiMessages[2], "f0 47 00 28 48 00 00 21 00 41 00 04 00 00 09 03 0d f7")
  assertProgramBlock("PTUNO", MemoryBlock("00 09 03 0d"))

  onProgTuneChange(mod, -3333)
  assertEqual(table.getn(midiMessages), 3)
  assertEqual(midiMessages[3], "f0 47 00 28 48 00 00 21 00 41 00 04 00 0c 0a 0e 0d f7")
  assertProgramBlock("PTUNO", MemoryBlock("0c 0a 0e 0d"))

  onProgTuneChange(mod, -2222)
  assertEqual(table.getn(midiMessages), 4)
  assertEqual(midiMessages[4], "f0 47 00 28 48 00 00 21 00 41 00 04 00 08 0c 09 0e f7")
  assertProgramBlock("PTUNO", MemoryBlock("08 0c 09 0e"))

  onProgTuneChange(mod, -1111)
  assertEqual(table.getn(midiMessages), 5)
  assertEqual(midiMessages[5], "f0 47 00 28 48 00 00 21 00 41 00 04 00 04 0e 04 0f f7")
  assertProgramBlock("PTUNO", MemoryBlock("04 0e 04 0f"))

  onProgTuneChange(mod, 0)
  assertEqual(table.getn(midiMessages), 6)
  assertEqual(midiMessages[6], "f0 47 00 28 48 00 00 21 00 41 00 04 00 00 00 00 00 f7")
  assertProgramBlock("PTUNO", MemoryBlock("00 00 00 00"))

  onProgTuneChange(mod, 2222)
  assertEqual(table.getn(midiMessages), 7)
  assertEqual(midiMessages[7], "f0 47 00 28 48 00 00 21 00 41 00 04 00 08 03 06 01 f7")
  assertProgramBlock("PTUNO", MemoryBlock("08 03 06 01"))

  onProgTuneChange(mod, 4444)
  assertEqual(table.getn(midiMessages), 8)
  assertEqual(midiMessages[8], "f0 47 00 28 48 00 00 21 00 41 00 04 00 00 07 0c 02 f7")
  assertProgramBlock("PTUNO", MemoryBlock("00 07 0c 02"))

  onProgTuneChange(mod, 5000)
  assertEqual(table.getn(midiMessages), 9)
  assertEqual(midiMessages[9], "f0 47 00 28 48 00 00 21 00 41 00 04 00 00 00 02 03 f7")
  assertProgramBlock("PTUNO", MemoryBlock("00 00 02 03"))
end
--
----function testOnKgStringChange()
----end

function testOnProgStringChange()
  local akaiString = "PROG NAME"
  local modName = "PRNAME"
  local mod = panel:getModulatorByName(modName)
  onProgStringChange(mod, akaiString)

  assertText(modName, midiService:toAkaiString(initialProgName))
  assertEqual(table.getn(midiMessages), 1)
  assertEqual(midiMessages[1], "f0 47 00 28 48 00 00 21 00 03 00 0c 00 1a 1c 19 11 0a 18 0b 17 0f 0a 0a 0a f7")
  assertProgramBlock("PRNAME", MemoryBlock("1a 1c 19 11 0a 18 0b 17 0f 0a 0a 0a"))
end

runTests{useANSI = false}
