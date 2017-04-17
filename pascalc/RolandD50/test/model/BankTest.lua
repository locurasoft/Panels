require("ctrlrTestUtils")
require("model/Bank")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'BankTest', lunity )

function setup()
  mc = lemock.controller()
  
  midiServiceMock = mc:mock()
  regGlobal("midiService", MidiService())
end

function teardown()
  delGlobal("midiService")
end

function testConstructorWithoutData()
  local tested = Bank()
  assertEqual(tested:getSelectedPatchIndex(), 0)
  assertEqual(tested.data:getSize(), 64 * Voice_singleSize)
  
  local p = tested:getSelectedPatch()
  assertNotNil(p)
  
  assertEqual(p:getPatchName(), "NEW PATCH         ")
  assertEqual(p.patchOffset, 0)
  
  tested:setSelectedPatchIndex(35)
  
  p = tested:getSelectedPatch()
  assertNotNil(p)
  assertEqual(p:getPatchName(), "NEW PATCH         ")
  
  assertEqual(p.patchOffset, 35 * Voice_singleSize)
end

runTests{useANSI = false}
