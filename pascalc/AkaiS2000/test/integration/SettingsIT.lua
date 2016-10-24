require("akaiS2kTestUtils")
require("integration/SettingsFunctions")
require("MockPanel")
require("json4ctrlr")
require("cutils")

require("model/DrumMap")
require("model/Settings")

require("controller/DrumMapController")
require("controller/SettingsController")

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
  regGlobal("OPERATING_SYSTEM", "win")
  regGlobal("PATH_SEPARATOR", "\\")
  regGlobal("EOL", "\n")

  os.execute("if exist " .. tmpFolderName .. " rmdir /S /Q " .. tmpFolderName)

  os.execute("mkdir " .. tmpFolderName)
  regGlobal("panel", MockPanel())
  regGlobal("LOGGER", Logger("GLOBAL"))

  local settings = Settings()

  regGlobal("settings", settings)

  regGlobal("settingsController", SettingsController(settings))

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

  local drumMap = DrumMap()
  regGlobal("drumMap", drumMap)
  regGlobal("drumMapController", DrumMapController(drumMap))
end

function teardown()
  delGlobal("settings")
  delGlobal("drumMap")
  delGlobal("drumMapController")
  
  utils.openDirectoryWindow = tempUtilsDirectoryWindow
  utils.openFileWindow = tempUtilsFileWindow
end

function testOnFloppyImageSelected()
  onFloppyImageSelected()
  assertText("loadFloppyImageLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnTransferMethodChange()
  local FLOPPY, HXCFE, MIDI = 0, 1, 2

  onTransferMethodChange(FLOPPY)

  assertDisabled("hxcPathGroup")
  assertDisabled("loadOsButton")
  assertDisabled("loadFloppyImageGroup")
  assertEnabled("setfdprmPathGroup")

  onTransferMethodChange(HXCFE)

  assertEnabled("hxcPathGroup")
  assertEnabled("loadOsButton")
  assertEnabled("loadFloppyImageGroup")
  assertDisabled("setfdprmPathGroup")

  onTransferMethodChange(MIDI)

  assertDisabled("hxcPathGroup")
  assertDisabled("loadOsButton")
  assertDisabled("loadFloppyImageGroup")
  assertDisabled("setfdprmPathGroup")
end

function testOnSetfdprmPathChange()
  onSetfdprmPathChange()
  assertText("setfdprmPathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnHxcPathChange()
  onHxcPathChange()
  assertText("hxcPathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnS2kDiePathChange()
  onS2kDiePathChange()
  assertText("s2kDiePathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 1)
  assertEqual(table.getn(openedDirectoryWindows), 0)
end

function testOnWorkPathChange()
  onWorkPathChange()
  assertText("workPathLabel", File(tmpFolderName):getFullPathName())
  assertEqual(table.getn(openedFileWindows), 0)
  assertEqual(table.getn(openedDirectoryWindows), 1)
end

runTests{useANSI = false}
