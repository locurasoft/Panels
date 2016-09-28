require("akaiS2kTestUtils")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'MidiServiceTest', lunity )

function setup()
  -- code here will be run before each test
  --console("setup")
end

function teardown()
  -- code here will be run after each test
end

function test1_constructor()
  local midiService = MidiService()
  assertEqual(type(midiService), "table")
end

runTests{useANSI = false}
