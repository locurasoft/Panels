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
module( 'SettingsIT', lunity )

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

function setup()
  os.execute("if exist " .. tmpFolderName .. " rmdir /S /Q " .. tmpFolderName)
  os.execute("mkdir " .. tmpFolderName)
  tempUtilsDirectoryWindow = utils.getDirectoryWindow
  openedDirectoryWindows = {}
  utils.getDirectoryWindow = function(message) 
    table.insert(openedDirectoryWindows, message)
    return File(tmpFolderName)
  end
  
  tempUtilsFileWindow = utils.openFileWindow
  openedFileWindows = {}
  utils.openFileWindow = function(message) 
    table.insert(openedFileWindows, message)
    return File(tmpFolderName)
  end
  

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
  
  utils.openDirectoryWindow = tempUtilsDirectoryWindow
  utils.openFileWindow = tempUtilsFileWindow
end

function testOnFloppyImageSelected()
  settingsController:onFloppyImageSelected()
  assertText("loadFloppyImageLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnTransferMethodChange()
  local FLOPPY, HXCFE, MIDI = 0, 1, 2

  settingsController:onTransferMethodChange(FLOPPY)

  assertDisabled("hxcPathGroup")
  assertDisabled("loadOsButton")
  assertDisabled("loadFloppyImageGroup")
  assertEnabled("setfdprmPathGroup")

  settingsController:onTransferMethodChange(HXCFE)

  assertEnabled("hxcPathGroup")
  assertEnabled("loadOsButton")
  assertEnabled("loadFloppyImageGroup")
  assertDisabled("setfdprmPathGroup")

  settingsController:onTransferMethodChange(MIDI)

  assertDisabled("hxcPathGroup")
  assertDisabled("loadOsButton")
  assertDisabled("loadFloppyImageGroup")
  assertDisabled("setfdprmPathGroup")
end

function testOnSetfdprmPathChange()
  settingsController:onSetfdprmPathChange()
  assertText("setfdprmPathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnHxcPathChange()
  settingsController:onHxcPathChange()
  assertText("hxcPathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnS2kDiePathChange()
  settingsController:onS2kDiePathChange()
  assertText("s2kDiePathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnWorkPathChange()
  settingsController:onWorkPathChange()
  assertText("workPathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 0)
  assertEqual(table.getn(openedDirectoryWindows), 1)
end

function testOnFloppyImageCleared()
  settingsController:onFloppyImageCleared()
  assertText("loadFloppyImageLabel", "")
end


runTests{useANSI = false}
