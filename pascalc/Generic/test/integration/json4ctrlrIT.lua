require("akaiS2kTestUtils")
require("model/DrumMap")
require("service/MidiService")
require("message/KdataMsg")
require("json4ctrlr")
require 'lunity'
require 'lemock'
module( 'json4ctrlrIT', lunity )

function setup()
  underTest = Dispatcher()
  mc = lemock.controller()
  listener = mc:mock()
  listener2 = mc:mock()
  
  regGlobal("midiService", MidiService())
end

function teardown()
  delGlobal("midiService")
end

function testStoreJson()
  local drumMap = DrumMap()
  drumMap:setNumKeyGroups(1)
  drumMap:setSelectedKeyGroup(1)
  drumMap:addSampleToSelectedKeyGroup("mySample")
  drumMap:addSampleToSelectedKeyGroup("mySample2")
  
  drumMap:setNumKeyGroups(2)
  drumMap:setSelectedKeyGroup(2)
  drumMap:addFileToSelectedKeyGroup(File("testFile1.wav"))
  drumMap:addSampleToSelectedKeyGroup("mySample3")
  
  local result = cson.encode(drumMap)
  assertNotNil(string.find(result, "\"numKgs\":2"))
  assertNotNil(string.find(result, "\"sampleName\":\"mySample\""))
  assertNotNil(string.find(result, "\"sampleName\":\"mySample2\""))
  assertNotNil(string.find(result, "\"sampleName\":\"mySample3\""))
  assertNotNil(string.find(result, "\"sampleLoaded\":false"))
  assertNotNil(string.find(result, "\"fullPathName\""))
  assertNotNil(string.find(result, "\"nativeName\""))
  assertNotNil(string.find(result, "\"sampleLoaded\":true"))
end

function testLoadJson()
  local json = "{\"numKgs\":2,\"floppyList\":[],\"LUA_CLASS_NAME\":\"DrumMap\",\"listeners\":[],\"keyRanges\":[[0,0],[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9],[10,10],[11,11],[12,12],[13,13],[14,14],[15,15]],\"keyGroups\":[{\"zones\":[{\"sampleLoaded\":true,\"sampleName\":\"mySample\",\"LUA_CLASS_NAME\":\"Zone\"},{\"sampleLoaded\":true,\"sampleName\":\"mySample2\",\"LUA_CLASS_NAME\":\"Zone\"}],\"LUA_CLASS_NAME\":\"KeyGroup\",\"listeners\":[],\"updating\":false,\"kdata\":{\"data\":{\"nativeName\":\"MemoryBlock\",\"hexString\":\"f0 47 00 09 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 f7\"},\"LUA_CLASS_NAME\":\"KdataMsg\"}},{\"zones\":[{\"sampleLoaded\":false,\"file\":{\"nativeName\":\"File\",\"fullPathName\":\"C:\ctrlr\Panels\pascalc\AkaiS2000\testFile1.wav\"},\"LUA_CLASS_NAME\":\"Zone\",\"fileName\":\"testFile1.wav\"},{\"sampleLoaded\":true,\"sampleName\":\"mySample3\",\"LUA_CLASS_NAME\":\"Zone\"}],\"LUA_CLASS_NAME\":\"KeyGroup\",\"listeners\":[],\"updating\":false,\"kdata\":{\"data\":{\"nativeName\":\"MemoryBlock\",\"hexString\":\"f0 47 00 09 00 00 00 00 00 00 00 00 00 00 00 01 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 f7\"},\"LUA_CLASS_NAME\":\"KdataMsg\"}}],\"currentFloppyUsage\":0,\"selectedKg\":2}"
  local result = cson.decode(json)
end

runTests{useANSI = false}