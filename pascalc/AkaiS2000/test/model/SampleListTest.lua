require("akaiS2kTest")
require("model.SampleList")
require 'lunity'
require 'lemock'
module( 'TEST_RUNTIME', lunity )

local mySample = "MYSAMPLE  "
local mySample2 = "MYSAMPLE2 "

function setup()
  -- code here will be run before each test
  console("setup")
  underTest = SampleList()
  mc = lemock.controller()
  listener = mc:mock()
  listener2 = mc:mock()  listener:notify(underTest);mc:times(2)
end

function teardown()
  -- code here will be run after each test
  console("teardown")
end

function numSamples(list)
  local count = 0
  for i, v in pairs( list ) do
    count = count + 1
  end
  return count
end

function testAddSample()
  
  listener2:notify(underTest);mc:times(1)
  mc:replay()

  underTest:addListener(listener, "notify")
  underTest:addSample(mySample)
  
  assertEqual(numSamples(underTest.list), 1)
  assertTrue(underTest.list[mySample] ~= nil)
  
  underTest:addListener(listener2, "notify")

  underTest:addSample(mySample2)
  
  assertEqual(numSamples(underTest.list), 2)
  assertTrue(underTest.list[mySample] ~= nil)
  assertTrue(underTest.list[mySample2] ~= nil)

  mc:verify()
end

function testSampleExists()
  assertFalse(underTest:sampleExists(mySample))
  assertFalse(underTest:sampleExists(mySample2))

  underTest:addSample(mySample)
  assertTrue(underTest:sampleExists(mySample))
  assertFalse(underTest:sampleExists(mySample2))
  
  underTest:addSample(mySample2)
  assertTrue(underTest:sampleExists(mySample))
  assertTrue(underTest:sampleExists(mySample2))
end

function testGetSampleNames()
  assertEqual(underTest:getSampleNames(), "")

  underTest:addSample(mySample)
  assertEqual(underTest:getSampleNames(), mySample)
  
  underTest:addSample(mySample2)
  assertEqual(underTest:getSampleNames(), string.format("%s\n%s", mySample, mySample2))
end

runTests{useANSI = false}
