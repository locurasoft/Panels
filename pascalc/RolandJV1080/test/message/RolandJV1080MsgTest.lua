require("ctrlrTestUtils")
require("Logger")
require("message/RolandJV1080DataRequestMsg")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'RolandJV1080MsgTest', lunity )

local log = Logger("RolandJV1080MsgTest")

function setup()
  _G["midiService"] = MidiService()
end

function testRolandJV1080DataRequestMsgConstructor()
  local tested = RolandJV1080DataRequestMsg(0, 0x55)
  log:warn("Result: %s", tested:toString())
end

runTests{useANSI = false}
