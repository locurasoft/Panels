require("akaiS2kTestUtils")
require("model/DrumMap")
require("controller/DrumMapController")
require("service/MidiService")
require("MockPanel")
require("message/KdataMsg")
require("json4ctrlr")
require 'lunity'
require 'lemock'
module( 'ProgramIT', lunity )

function setup()
  regGlobal("midiService", MidiService())
  regGlobal("panel", MockPanel())
  regGlobal("drumMap", DrumMap())
  regGlobal("drumMapController", DrumMapController())
end

function teardown()
  delGlobal("midiService")
  delGlobal("panel")
  delGlobal("drumMap")
  delGlobal("drumMapController")
end

function testOnProgramChange()
end

function testOnKeyGroupChange()
end

function testOnVssChange()
end

function testOnKgDefaultParamChange()
end

function testOnProgDefaultParamChange()
end

function testOnKgTuneChange()
end

function testOnProgTuneChange()
end

function testOnKgStringChange()
end

function testOnProgStringChange()
end

--runTests{useANSI = false}
