require("ctrlrTestUtils")
require("Logger")
require("MockPanel")
require("MockTimer")
require("MockPopupMenu")
require("MockImage")
require("model/YamahaCS1xPatch")
require("controller/YamahaCS1xController")
require("controller/YamahaCS1xControllerAutogen")
require("controller/onPanelBeforeLoad")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'YamahaCS1xPatchTest', lunity )

local log = Logger("YamahaCS1xPatchTest")

local midiCallback = nil

local calculateChecksum = function(sysex, csStart, csEnd)
  if csEnd < 0 then
    csEnd = sysex:getSize() + csEnd
  end

  local sum = 0
  for i = csStart, csEnd do
    sum = sum + sysex:getByte(i)
  end

  return bit.band((bit.bnot(sum) + 1), 0x7f)
end

function setup()
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)
  regGlobal("timer", MockTimer())
  regGlobal("PopupMenu", MockPopupMenu)
  regGlobal("Image", MockImage)

  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
    if midiCallback ~= nil then
      midiCallback(midiMessage)
    end
  end
  regGlobal("panel", MockPanel("Yamaha-CS1x.panel", midiListener))
  onPanelBeforeLoad()
end

function teardown()
  delGlobal("midiService")
end

function testToStandaloneData()
	local p = YamahaCS1xPatch()
	local result = p:toStandaloneData()
	assertEqual(result:getSize(), SinglePerformanceSize)
end

function testCalculateChecksum()
  local start = 4
  local extraLength = start + 5 - 1
  local memBlock =  MemoryBlock("f0 43 00 4b 00 29 60 04 00 00 00 3f 01 40 09 04 7f 40 4b 40 00 7f 2f 7f 01 02 40 7f 40 40 40 00 40 40 40 40 01 7f 40 40 03 40 40 40 40 40 40 40 40 40 2a f7")
  local memBlock2 = MemoryBlock("f0 43 00 4b 00 09 60 00 50 00 00 00 28 00 00 00 01 26 78 f7")
  local memBlock3 =  MemoryBlock("F0 43 00 4B 00 2E 60 00 00 53 74 61 62 20 20 20 20 00 7F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 20 20 20 00 00 51 1D 07 06 69 F7")
  local header = MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x29, 0x60, 0x04, 0x00 })
  assertEqual(calculateChecksum(memBlock, start, memBlock:getByte(5) + extraLength), 0x2A)
  assertEqual(calculateChecksum(memBlock2, start, memBlock2:getByte(5) + extraLength), 0x78)
  assertEqual(calculateChecksum(memBlock3, start, memBlock3:getByte(5) + extraLength), 0x6E)
end

runTests{useANSI = false}
