require("akaiS2kTestUtils")
require("message/PdataMsg")
require("message/RpdataMsg")
require("message/RkdataMsg")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'AkaiS2000SyxMsgTest', lunity )

function setup()
  regGlobal("midiService", MidiService())
end

function testPdataConstructor_withoutBytes()
  local pdata = PdataMsg()
  local data = pdata:getData()
  assertNotNil(data)
  assertEqual(data:getByte(0), 0xF0)
  assertEqual(pdata:getName(), "EMPTYPROGRAM")
  assertEqual(data:getSize(), 292)
end

function testPdataProgramNumber()
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
  assertEqual(pdata:getProgramNumber(), 127)
  
  pdata:setProgramNumber(256)
  assertEqual(pdata:getProgramNumber(), 127)
  
  pdata:setProgramNumber(-1)
  assertEqual(pdata:getProgramNumber(), 0)
  
  pdata:setProgramNumber(1000)
  assertEqual(pdata:getProgramNumber(), 127)
end

function testPdataName()
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

function testPdataNumKeyGroups()
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

function testRpdata()
  local tested = RpdataMsg(1)
  local data = tested.data
  assertNotNil(data)
  assertEqual(data:getByte(0), 0xF0)
  assertEqual(data:getByte(5), 1)
  assertEqual(data:getByte(6), 0)
  assertEqual(data:getSize(), 8)

  local tested = RpdataMsg(25)
  local data = tested.data
  assertNotNil(data)
  assertEqual(data:getByte(0), 0xF0)
  assertEqual(data:getByte(5), 25)
  assertEqual(data:getByte(6), 0)
  assertEqual(data:getSize(), 8)
end

function testRkdata()
  local tested = RkdataMsg(1, 1)
  local data = tested.data
  assertNotNil(data)
  assertEqual(data:getByte(0), 0xF0)
  assertEqual(data:getByte(5), 1)
  assertEqual(data:getByte(6), 0)
  assertEqual(data:getByte(7), 1)
  assertEqual(data:getSize(), 9)
end

runTests{useANSI = false}
