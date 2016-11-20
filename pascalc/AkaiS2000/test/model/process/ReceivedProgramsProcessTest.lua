require("akaiS2kTestUtils")
require("MockPanel")
require("MockMidiMessage")
require("Queue")
require("json4ctrlr")
require("cutils")

require("model/process/ReceiveProgramsProcess")
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
require("message/RplistMsg")
require("message/PlistMsg")

require 'lunity'
require 'lemock'
module( 'ReceivedProgramsProcessTest', lunity )

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
end

function teardown()
  os.execute = tempOsExecute
  utils.infoWindow = tempUtilsInfoWindow
  
  tearDownIntegrationTest(tmpFolderName)
  os.execute("rmdir /S /Q " .. tmpFolderName)
end

local progNames = {
  "DAMP GBSN A2",
  "DAMP GBSN A3",
  "DAMP GBSN C5",
  "DAMP GBSN E3",
  "DAMP GBSN E4",
  "DAMP GTR C5 ",
  "DAMP GTR D3 ",
  "DAMP GTR E4 ",
  "DAMP GTR G2 ",
  "DAMP-GBSN--L",
  "DAMP-GBSN--R",
  "GBSN 335 A2 ",
  "GBSN 335 A3 ",
  "GBSN 335 A4 ",
  "GBSN 335 E2 ",
  "GBSN 335 E3 ",
  "GBSN 335 E4 ",
  "GBSN 335 E5 ",
  "GBSN 335 PIK",
  "GBSN HARMONC",
  "MUTE GTR C5 ",
  "MUTE GTR D3 ",
  "MUTE GTR E4 ",
  "MUTE GTR G2 ",
  "PULL GTR D3 ",
  "PULL GTR E4 ",
  "PULL-GTR--G2",
  "SMACKIN     "
}

function newPlistMsg(numProgs)
  local bytes = string.format("F0 47 00 03 48 %.2X 00", numProgs)
  for i = 1, numProgs do
    local nibbles = midiService:toAkaiStringNibbles(progNames[i])
    bytes = string.format("%s %s", bytes, nibbles:toHexString(1))
  end
  return MemoryBlock(string.format("%s %s", bytes, "F7"))
end

function testExecute()
  local tested = ReceivedProgramsProcess()
  tested:execute()
  
  assertEqual(tested.requestQueue:getSize(), 0)
  
  local namesString = "DAMP GBSN A2"
  globalController:onMidiReceived(MockMidiMessage(newPlistMsg(2)))

  assertEqual(tested.requestQueue:getSize(), 1)

  globalController:onMidiReceived(MockMidiMessage(MemoryBlock("F0 47 00 07 48 14 00 01 00 0C 09 06 06 01 01 03 01 0C 00 0D 01 09 01 08 01 0A 00 0C 00 0B 00 0D 01 0D 01 02 00 03 01 00 00 0F 01 01 00 08 01 0F 07 00 00 00 00 03 06 00 00 0A 05 02 03 00 00 00 00 00 01 00 00 02 03 00 00 07 03 00 00 02 03 09 00 00 00 00 00 02 00 00 00 01 00 07 00 03 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 0A 00 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 05 00 00 00 00 02 00 00 00 00 00 06 00 08 00 01 00 06 00 03 00 06 00 06 00 06 00 05 00 03 00 0A 00 0A 00 05 00 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0C 03 00 00 00 00 00 00 00 00 0E 01 02 03 0E 01 0C 03 00 00 00 00 00 00 00 00 00 00 00 00 09 01 00 00 0F 0F 0F 0F 0D 01 03 01 08 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 00 00 0F 07 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 00 00 00 00 0D 01 0B 01 0F 01 0B 00 0C 01 0F 00 0A 00 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7")))

  assertEqual(tested.requestQueue:getSize(), 7)
  
end

runTests{useANSI = false}
