require("ctrlrTestUtils")
require("Logger")
require("MockPanel")
require("controller/onPanelBeforeLoad")
require 'lunity'
require 'lemock'
module( 'RolandJV1080ControllerTest', lunity )

local log = Logger("RolandJV1080ControllerTest")

function setup()
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)

  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
  end
  --regGlobal("panel", MockPanel("Roland-JV1080.panel", midiListener))
--  onPanelBeforeLoad()
end

function teardown()
  delGlobal("midiService")
end

function testTemp()
	local t1 = { 1, 2, 3, 4, 5, 9 }
	local t2 = { 6, 7, 8 }
	table.insert(t1, 6, t2)
	for k, v in pairs(t1) do
	 console(string.format("%d = %d", k, v))
	end
end

runTests{useANSI = false}
