require("akaiS2kTestUtils")
require("MockPanel")
require("json4ctrlr")
require("cutils")

require("model/Process")
require("model/DrumMap")
require("model/SampleList")
require("model/ProgramList")
require("model/Settings")

require("controller/GlobalController")
require("controller/GlobalControllerAutogen")
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

require("message/StatMsg")
require("message/RstatMsg")
require("message/KdataMsg")
require("message/SlistMsg")
require("message/RslistMsg")

require 'lunity'
require 'lemock'
module( 'GlobalControllerTest', lunity )

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

--  tempOsExecute = os.execute
--  executedOsCommands = {}
--  os.execute = function(cmd) table.insert(executedOsCommands, cmd) end
--
--  tempUtilsInfoWindow = utils.infoWindow
--  openedInfoWindows = {}
--  utils.infoWindow = function(title, message) table.insert(openedInfoWindows, message) end

  ctrlrwork = File(tmpFolderName)

  setupIntegrationTest(tmpFolderName, processListener, midiListener)
end

function teardown()
--  os.execute = tempOsExecute
--  utils.infoWindow = tempUtilsInfoWindow
  
  tearDownIntegrationTest(tmpFolderName)
  os.execute("rmdir /S /Q " .. tmpFolderName)
end

function testOnTest1()
	local tested = GlobalController()
	tested:onTest1()
end

--function test2()
--  function f()
----    assert(1 == 1, "Hello world!")
--    return "APA"
--  end
--	local status, err = pcall(f)
--	if status then
--    console("aaaa " ..err)
--  else
--    console(err:gsub(".*:%d+:%s*", ""))
--  end
--end

runTests{useANSI = false}
