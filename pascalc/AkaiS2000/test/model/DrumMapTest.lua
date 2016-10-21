require("akaiS2kTestUtils")
require("model/DrumMap")
require("model/KeyGroup")
require("message/KdataMsg")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'DrumMapTest', lunity )

function setup()
  mc = lemock.controller()
  listenerMock = mc:mock()
  listener2Mock = mc:mock()
  keyGroupMock = mc:mock()
  
  midiServiceMock = mc:mock()
  regGlobal("midiService", MidiService())
end

function teardown()
  delGlobal("midiService")
end

function testConstructor()
  local tested = DrumMap()
  assertEqual(table.getn(tested.keyRanges), 16)

  local item = tested.keyRanges[1]
  assertEqual(type(item), "table")
  assertEqual(item[1], 0)
  assertEqual(item[2], 0)

  item = tested.keyRanges[8]
  assertEqual(type(item), "table")
  assertEqual(item[1], 7)
  assertEqual(item[2], 7)

  item = tested.keyRanges[13]
  assertEqual(type(item), "table")
  assertEqual(item[1], 12)
  assertEqual(item[2], 12)

  item = tested.keyRanges[16]
  assertEqual(type(item), "table")
  assertEqual(item[1], 15)
  assertEqual(item[2], 15)
end

function testSetSelectedSample()
  local tested = DrumMap()
  listenerMock:notify(tested);mc:times(2)
  listener2Mock:notify(tested);mc:times(1)
  
  mc:replay()

  tested:setSelectedSample("sample1")
  assertEqual(tested.selectedSample, "sample1")

  tested:addListener(listenerMock, "notify")
  tested:setSelectedSample("sample2")
  assertEqual(tested.selectedSample, "sample2")

  tested:addListener(listener2Mock, "notify")
  tested:setSelectedSample("sample3")
  assertEqual(tested.selectedSample, "sample3")
  
  mc:verify()
end

function testSetSelectedKeyGroup()
  local tested = DrumMap()
  listenerMock:notify(tested);mc:times(2)
  listener2Mock:notify(tested);mc:times(1)
  
  mc:replay()

  -- Test using integer
  tested:setSelectedKeyGroup(1)
  assertEqual(tested:isSelectedKeyGroup(1), true)
  assertEqual(tested:isSelectedKeyGroup("drumMap-1"), true)
  assertEqual(tested:isSelectedKeyGroup(2), false)
  assertEqual(tested:isSelectedKeyGroup("drumMap-2"), false)

  -- De-select pad
  tested:setSelectedKeyGroup(1)
  assertEqual(tested:getSelectedKeyGroup(), nil)

  tested:setSelectedKeyGroup(1)
  tested:setSelectedKeyGroup("drumMap-1")
  assertEqual(tested:getSelectedKeyGroup(), nil)

  tested:setSelectedKeyGroup("drumMap-1")
  tested:setSelectedKeyGroup("drumMap-1")
  assertEqual(tested:getSelectedKeyGroup(), nil)

  tested:setSelectedKeyGroup(2)
  assertEqual(tested:getSelectedKeyGroup(), 2)
  tested:setSelectedKeyGroup("drumMap-3")
  assertEqual(tested:getSelectedKeyGroup(), 3)

  tested:addListener(listenerMock, "notify")
  tested:setSelectedKeyGroup(15)
  assertEqual(tested:getSelectedKeyGroup(), 15)
  assertEqual(tested:isSelectedKeyGroup(15), true)
  assertEqual(tested:isSelectedKeyGroup("drumMap-1"), false)

  tested:addListener(listener2Mock, "notify")
  tested:setSelectedKeyGroup("drumMap-10")
  assertEqual(tested:getSelectedKeyGroup(), 10)
  assertEqual(tested:isSelectedKeyGroup(1), false)
  assertEqual(tested:isSelectedKeyGroup("drumMap-10"), true)
  
  mc:verify()
end

function testIsReadyForAssignment()
  local tested = DrumMap()
  assertFalse(tested:isReadyForAssignment())

  tested:setSelectedKeyGroup("drumMap-10")
  assertFalse(tested:isReadyForAssignment())

  tested:setSelectedSample("sample3")
  assertTrue(tested:isReadyForAssignment())

  tested:setSelectedKeyGroup("drumMap-11")
  assertTrue(tested:isReadyForAssignment())

  tested:setSelectedKeyGroup("drumMap-11")
  assertFalse(tested:isReadyForAssignment())
end

function testFloppyUsage()
  local tested = DrumMap()
  listenerMock:notify(tested);mc:times(2)
  listener2Mock:notify(tested);mc:times(1)
  
  mc:replay()

  tested:setCurrentFloppyUsage(100)
  assertEqual(tested:getCurrentFloppyUsage(), 100)

  tested:addListener(listenerMock, "notify")
  tested:setCurrentFloppyUsage(0)
  assertEqual(tested:getCurrentFloppyUsage(), 0)

  tested:addListener(listener2Mock, "notify")
  tested:setCurrentFloppyUsage(1000000)
  assertEqual(tested:getCurrentFloppyUsage(), 1000000)
  
  mc:verify()
end

function testFloppy()
  local tested = DrumMap()

  assertEqual(tested:getNumFloppies(), 0)

  local result1 = tested:addNewFloppy()
  assertEqual(tested:getNumFloppies(), 1)
  assertEqual(tested:getFloppy(1), result1)

  assertEqual(tested:retrieveNextFloppy(), result1)
  assertEqual(tested:getNumFloppies(), 0)

  local result2 = tested:addNewFloppy()
  assertEqual(tested:getNumFloppies(), 1)
  assertEqual(tested:getFloppy(1), result2)

  local result3 = tested:addNewFloppy()
  assertEqual(tested:getNumFloppies(), 2)
  assertEqual(tested:getFloppy(2), result3)

  local result4 = tested:addNewFloppy()
  assertEqual(tested:getNumFloppies(), 3)
  assertEqual(tested:getFloppy(3), result4)

  assertEqual(tested:retrieveNextFloppy(), result4)
  assertEqual(tested:getNumFloppies(), 2)

  assertEqual(tested:retrieveNextFloppy(), result3)
  assertEqual(tested:getNumFloppies(), 1)

  assertEqual(tested:retrieveNextFloppy(), result2)
  assertEqual(tested:getNumFloppies(), 0)
end

function testSetNumKeyGroups()
  local tested = DrumMap()
  listenerMock:notify(tested);mc:times(2)
  listener2Mock:notify(tested);mc:times(1)

--  midiService:toNibbles(0);mc:returns(MemoryBlock("1"));mc:anytimes()
--  midiService:toNibbles(7);mc:returns(MemoryBlock("8"));mc:anytimes()
--  midiService:toNibbles(15);mc:returns(MemoryBlock("16"));mc:anytimes()
  
  mc:replay()

  tested:setNumKeyGroups(1)
  assertEqual(tested:getNumKeyGroups(), 1)
  local item = tested:getKeyGroups()[1]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 0)
  assertEqual(item:getParamValue("HINOTE"), 0)

  tested:addListener(listenerMock, "notify")
  tested:setNumKeyGroups(16)
  assertEqual(tested:getNumKeyGroups(), 16)
  item = tested:getKeyGroups()[16]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 15)
  assertEqual(item:getParamValue("HINOTE"), 15)

  item = tested:getKeyGroups()[8]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 7)
  assertEqual(item:getParamValue("HINOTE"), 7)
  
  item = tested:getKeyGroups()[4]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 3)
  assertEqual(item:getParamValue("HINOTE"), 3)
  
  item = tested:getKeyGroups()[1]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 0)
  assertEqual(item:getParamValue("HINOTE"), 0)


  tested:addListener(listener2Mock, "notify")
  tested:setNumKeyGroups(8)
  assertEqual(tested:getNumKeyGroups(), 8)
  item = tested:getKeyGroups()[8]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 7)
  assertEqual(item:getParamValue("HINOTE"), 7)
  
  item = tested:getKeyGroups()[4]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 3)
  assertEqual(item:getParamValue("HINOTE"), 3)
  
  item = tested:getKeyGroups()[1]
  assertEqual(item[LUA_CONTRUCTOR_NAME], "KeyGroup")
  assertEqual(item:getParamValue("LONOTE"), 0)
  assertEqual(item:getParamValue("HINOTE"), 0)
  
  mc:verify()
end

function testAddToSelectedkeyGroup()
  local tested = DrumMap()
  listenerMock:notify(tested);mc:times(4)
  listener2Mock:notify(tested);mc:times(3)

  mc:replay()
  
  tested:setNumKeyGroups(2)
  tested:setSelectedKeyGroup(1)
  local kg1 = tested:getKeyGroups()[1]
  assertEqual(kg1:numZones(), 0)
  local kg2 = tested:getKeyGroups()[2]
  assertEqual(kg2:numZones(), 0)
  
  assertEqual(tested:getSamplesOfKeyGroup(1), "")
  assertEqual(tested:getSamplesOfKeyGroup(2), "")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 0)
  
  tested:addSampleToSelectedKeyGroup("sample1")
  assertEqual(kg1:numZones(), 1)
  assertEqual(kg2:numZones(), 0)
  assertEqual(tested:getSamplesOfKeyGroup(1), "sample1")
  assertEqual(tested:getSamplesOfKeyGroup(2), "")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 1)
  
  tested:addSampleToSelectedKeyGroup("sample2")
  assertEqual(kg1:numZones(), 2)
  assertEqual(kg2:numZones(), 0)
  assertEqual(tested:getSamplesOfKeyGroup(1), "sample1\nsample2")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 2)
  
  tested:addFileToSelectedKeyGroup(File("testFile1.wav"))
  assertEqual(kg1:numZones(), 3)
  assertEqual(kg2:numZones(), 0)
  assertEqual(tested:getSamplesOfKeyGroup(1), "sample1\nsample2\ntestFile1.wav")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 3)

  tested:addSampleToSelectedKeyGroup("sample4")
  assertEqual(kg1:numZones(), 4)
  assertEqual(kg2:numZones(), 0)
  assertEqual(tested:getSamplesOfKeyGroup(1), "sample1\nsample2\ntestFile1.wav\nsample4")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 4)
  
  tested:clearSelectedKeyGroup()
  assertEqual(kg1:numZones(), 0)
  assertEqual(kg2:numZones(), 0)
  assertEqual(tested:getSamplesOfKeyGroup(1), "")
  assertEqual(tested:getSamplesOfKeyGroup(2), "")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 0)

  tested:setSelectedKeyGroup(2)
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 0)
  
  tested:addSampleToSelectedKeyGroup("sampleLongLongLongLongLongLongName")
  assertEqual(kg1:numZones(), 0)
  assertEqual(kg2:numZones(), 1)
  assertEqual(tested:getSamplesOfKeyGroup(2), "sampleLongLongLongL..")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 1)
  
  tested:addFileToSelectedKeyGroup(File("testFile2.wav"))
  assertEqual(kg1:numZones(), 0)
  assertEqual(kg2:numZones(), 2)
  assertEqual(tested:getSamplesOfKeyGroup(2), "sampleLongLongLongL..\ntestFile2.wav")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 2)
  
  tested:addSampleToSelectedKeyGroup("sample3")
  assertEqual(kg1:numZones(), 0)
  assertEqual(kg2:numZones(), 3)
  assertEqual(tested:getSamplesOfKeyGroup(2), "sampleLongLongLongL..\ntestFile2.wav\nsample3")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 3)

  tested:setSelectedKeyGroup(1)
  tested:addSampleToSelectedKeyGroup("sample1")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 1)
  assertEqual(kg1:numZones(), 1)
  assertEqual(kg2:numZones(), 3)
  assertEqual(tested:getSamplesOfKeyGroup(1), "sample1")
  assertEqual(tested:getSamplesOfKeyGroup(2), "sampleLongLongLongL..\ntestFile2.wav\nsample3")

  tested:setSelectedKeyGroup(2)
  tested:addListener(listenerMock, "notify")
  tested:addSampleToSelectedKeyGroup("sample4")
  assertEqual(kg1:numZones(), 1)
  assertEqual(kg2:numZones(), 4)
  assertEqual(tested:getSamplesOfKeyGroup(2), "sampleLongLongLongL..\ntestFile2.wav\nsample3\nsample4")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 4)

  tested:addListener(listener2Mock, "notify")
  tested:clearSelectedKeyGroup()
  assertEqual(kg1:numZones(), 1)
  assertEqual(kg2:numZones(), 0)
  assertEqual(tested:getSamplesOfKeyGroup(1), "sample1")
  assertEqual(tested:getSamplesOfKeyGroup(2), "")
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 0)
  
  tested:setSelectedKeyGroup(1)
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 1)
  tested:setSelectedKeyGroup(1) -- Deselect group
  assertEqual(tested:getNumSamplesOnSelectedKeyGroup(), 0)
  
  mc:verify()	
end

function testKeyRange()
	local tested = DrumMap()
--  listenerMock:notify(tested);mc:times(4)
--  listener2Mock:notify(tested);mc:times(3)

  mc:replay()
  
  tested:setNumKeyGroups(2)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {0, 0})
  
  tested:setSelectedKeyGroup(1)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {0, 0})
  tested:setKeyRange(1, 1)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {1, 0})
  tested:setKeyRange(2, 2)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {1, 2})
  
  tested:setSelectedKeyGroup(2)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {1, 1})
  tested:setKeyRange(1, 23)
  tested:setKeyRange(2, 4)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {23, 4})
  tested:resetSelectedKeyRange()
  assertTableEquals(tested:getSelectedKeyRangeValues(), {1, 1})


  tested:setSelectedKeyGroup(1)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {1, 2})
  
  tested:setSelectedKeyGroup(2)
  tested:setKeyRange(1, 23)
  tested:setKeyRange(2, 4)
  tested:resetAllRanges()
  
  tested:setSelectedKeyGroup(1)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {0, 0})
  tested:setSelectedKeyGroup(2)
  assertTableEquals(tested:getSelectedKeyRangeValues(), {1, 1})
  
  mc:verify()

end

function testReplaceKeyGroupZoneWithSample_monoSample()
  local sampleName = "sampleName"
  local zoneIndex = 1

  local tested = DrumMap()

  listenerMock:notify(tested);mc:times(1)
  keyGroupMock:replaceWithMonoSample(zoneIndex, sampleName)

  tested:addListener(listenerMock, "notify")
  table.insert(tested.keyGroups, keyGroupMock)
  
  mc:replay()

  tested:replaceKeyGroupZoneWithSample(1, zoneIndex, sampleName)
	
	mc:verify()
end

function testReplaceKeyGroupZoneWithSample_stereoSample()
  local sampleNames = { "sampleNameLeft", "sampleNameRight" }
  local zoneIndex = 1

  local tested = DrumMap()

  listenerMock:notify(tested);mc:times(1)
  keyGroupMock:replaceZoneWithStereoSample(zoneIndex, sampleNames[1], sampleNames[2])

  tested:addListener(listenerMock, "notify")
  table.insert(tested.keyGroups, keyGroupMock)
  
  mc:replay()

  tested:replaceKeyGroupZoneWithSample(1, zoneIndex, sampleNames)
  
  mc:verify()
end

function testHasLoadedAllSamples()
  local tested = DrumMap()
--  listenerMock:notify(tested);mc:times(4)
--  listener2Mock:notify(tested);mc:times(3)

  mc:replay()
  
  tested:setNumKeyGroups(2)
  tested:setSelectedKeyGroup(1)
  
  tested:addSampleToSelectedKeyGroup("sample1")
  assertTrue(tested:hasLoadedAllSamples())
  
  tested:addFileToSelectedKeyGroup(File("testFile2.wav"))
  assertFalse(tested:hasLoadedAllSamples())
  
  tested:clearSelectedKeyGroup()
  assertTrue(tested:hasLoadedAllSamples())

  tested:addSampleToSelectedKeyGroup("sample1")
  assertTrue(tested:hasLoadedAllSamples())

  tested:setSelectedKeyGroup(2)
  
  tested:addSampleToSelectedKeyGroup("sample1")
  assertTrue(tested:hasLoadedAllSamples())
  
  tested:addFileToSelectedKeyGroup(File("testFile2.wav"))
  assertFalse(tested:hasLoadedAllSamples())
  
  mc:verify() 
	
end

function testGetLaunchButtonState()
  local tested = DrumMap()
  regGlobal("floppyImgPath", "/c/")

  local result = tested:getLaunchButtonState()
  assertEqual(result, "")

  tested:setSelectedKeyGroup("drumMap-10")
  result = tested:getLaunchButtonState()
  assertEqual(result, "You cannot load both an image and samples.\nPlease clear some data")

  tested:setSelectedSample("sample3")
  result = tested:getLaunchButtonState()
  assertEqual(result, "You cannot load both an image and samples.\nPlease clear some data")

  delGlobal("floppyImgPath")

  result = tested:getLaunchButtonState()
  assertEqual(result, "")

  tested:setSelectedKeyGroup("drumMap-10")
  result = tested:getLaunchButtonState()
  assertEqual(result, "Select a sample and a key group")
end

runTests{useANSI = false}
