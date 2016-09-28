require("akaiS2kTestUtils")
require("message/PdataMsg")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'PdataMsgTest', lunity )

function setup()
  -- code here will be run before each test
  --console("setup")
  regGlobal("midiService", MidiService())
end

function teardown()
  -- code here will be run after each test
end

function testConstructor()
  local pdata = PdataMsg()
  local data = pdata:getData()
  assertNotNil(data)
  assertEqual(data:getByte(0), 0xF0)
  assertEqual(pdata:getName(), "EMPTYPROGRAM")
  assertEqual(data:getSize(), 232)
end

runTests{useANSI = false}
