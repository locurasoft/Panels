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

function testConstructor_withoutBytes()
  local pdata = PdataMsg()
  local data = pdata:getData()
  assertNotNil(data)
  assertEqual(data:getByte(0), 0xF0)
  assertEqual(pdata:getName(), "EMPTYPROGRAM")
  assertEqual(data:getSize(), 232)
end

function testConstructor_withBytes()
  
end

function testProgramNumber()
  local pdata = PdataMsg()
  local pn = 0
  pdata:setProgramNumber(pn)
  assertEqual(pdata:getProgramNumber(), pn)
  
  pn = 1
  pdata:setProgramNumber(pn)
  assertEqual(pdata:getProgramNumber(), pn)
  
  pn = 2
  pdata:setProgramNumber(pn)
  assertEqual(pdata:getProgramNumber(), pn)
  
  pn = 25
  pdata:setProgramNumber(pn)
  assertEqual(pdata:getProgramNumber(), pn)
  
  pdata:setMaxProgramNumber()
  assertEqual(pdata:getProgramNumber(), 255)
  
  pdata:setProgramNumber(256)
  assertEqual(pdata:getProgramNumber(), 255)
  
  pdata:setProgramNumber(-1)
  assertEqual(pdata:getProgramNumber(), 0)
  
  pdata:setProgramNumber(1000)
  assertEqual(pdata:getProgramNumber(), 255)
end

function testName()
  local pdata = PdataMsg()
  local name = "Test"
  pdata:setName(name)
  assertEqual(pdata:getName(), "TEST        ")
  
  name = "TestTestTestTest"
  pdata:setName(name)
  assertEqual(pdata:getName(), "TESTTESTTEST")
  
  name = "Test-1"
  pdata:setName(name)
  assertEqual(pdata:getName(), "TEST-1      ")
  
  name = "abcdefghijkl"
  pdata:setName(name)
  assertEqual(pdata:getName(), "ABCDEFGHIJKL")
  
  name = "abcdefghijklmnop"
  pdata:setName(name)
  assertEqual(pdata:getName(), "ABCDEFGHIJKL")
  
  name = "abcdefgh"
  pdata:setName(name)
  assertEqual(pdata:getName(), "ABCDEFGH    ")	
end

function testNumKeyGroups()
  local pdata = PdataMsg()
  
  local kgs = 0
  pdata:setNumKeyGroups(kgs)
  assertEqual(pdata:getPdataValue("GROUPS"), kgs)
  
  kgs = 1
  pdata:setNumKeyGroups(kgs)
  assertEqual(pdata:getPdataValue("GROUPS"), kgs)
  
  kgs = 2
  pdata:setNumKeyGroups(kgs)
  assertEqual(pdata:getPdataValue("GROUPS"), kgs)
  
  kgs = 4
  pdata:setNumKeyGroups(kgs)
  assertEqual(pdata:getPdataValue("GROUPS"), kgs)
  
  kgs = 15
  pdata:setNumKeyGroups(kgs)
  assertEqual(pdata:getPdataValue("GROUPS"), kgs)
  
  kgs = 16
  pdata:setNumKeyGroups(kgs)
  assertEqual(pdata:getPdataValue("GROUPS"), kgs)
end

runTests{useANSI = false}
