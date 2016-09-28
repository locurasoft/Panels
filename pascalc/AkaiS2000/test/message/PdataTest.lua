require("akaiS2kTest")
require("src/message/Pdata")
require("src/service/MidiService")
module( 'TEST_RUNTIME', lunity )

function setup()
  -- code here will be run before each test
  console("setup")
  regGlobal("midiSrvc", MidiService())
  console(string.format("MidiService: %s", type(_G.midiSrvc)))
end

function teardown()
  -- code here will be run after each test
end

function test1_constructor()
  local pdata = Pdata()
  local data = pdata:getData()
  assertFalse(data == nil)
  assertEqual(data:getByte(0), 0xF0)
  console(pdata:getName())
  console(pdata:toString())
  assertEqual(data:getByte(0), 0xF0)
end

runTests{useANSI = false}
