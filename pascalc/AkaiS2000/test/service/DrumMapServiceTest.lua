require("akaiS2kTestUtils")
require("service.DrumMapService")
require 'lunity'
require 'lemock'
module( 'DrumMapServiceTest', lunity )

function setup()
  -- code here will be run before each test
  --console("setup")
  underTest = DrumMapService()
  mc = lemock.controller()
  listener = mc:mock()
  listener2 = mc:mock()
end

function teardown()
  -- code here will be run after each test
  --console("teardown")
end

function testGetSamplerFileName()
  assertEqual(underTest:getSamplerFileName("Death Grips - Get Got.mp3"), "DEATH GRIP")
  assertEqual(underTest:getSamplerFileName("Akai test mp3.mp3"), "AKAI TEST ")
  assertEqual(underTest:getSamplerFileName("Ak.mp3"), "AK.MP3    ")
end

function testFindStereoCounterpart()
	local sampleList = {
	  "AK.MP3  -L",
	  "AK.MP3  -R",
	  "AKAI TEST ",
	  "DEATH GR-L",
	  "DEATH GR-R",
	}
end

runTests{useANSI = false}
