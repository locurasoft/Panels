require("ctrlrTestUtils")
require("Logger")
require("model/Bank")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'BankTest', lunity )

local log = Logger("BankTest")

local PATCH_NAMES = {
  "Fantasia          ",
  "Metal Harp        ",
  "Jazz Guitar Duo   ",
  "Arco Strings      ",
  "Horn Section      ",
  "Living Calliope   ",
  "D-50 Voices       ",
  "Slow Rotor        ",
  "DigitalNativeDance",
  "Bass Marimba      ",
  "Flute-Piano Duo   ",
  "Combie Strings    ",
  "Harpsichord Stabs ",
  "Griitttarr        ",
  "Nylon Atmosphere  ",
  "Synthetic Electric",
  "Breathy Chiffer   ",
  "Gamelan Bell      ",
  "Slap Brass        ",
  "PressureMe Strings",
  "Rich Brass        ",
  "Pipe Solo         ",
  "Soundtrack        ",
  "Cathedral Organ   ",
  "Shamus Theme      ",
  "Vibraphone        ",
  "Basin Strat Blues ",
  "Pizzagogo         ",
  "Flutish Brass     ",
  "Pressure Me Lead  ",
  "Spacious Sweep    ",
  "Piano-Fifty       ",
  "Glass Voices      ",
  "Hollowed Harp     ",
  "Ethnic Session    ",
  "Jete Strings      ",
  "Stereo Polysynth  ",
  "Tine Wave         ",
  "Syn-Harmonium     ",
  "Rock Organ        ",
  "Staccato Heaven   ",
  "Oriental Bells    ",
  "E-Bass and E-Piano",
  "Legato Strings    ",
  "JX Horns-Strings  ",
  "Shakuhachi        ",
  "Choir             ",
  "Picked Guitar Duo ",
  "Nightmare         ",
  "Syn Marimba       ",
  "Slap Bass n Brass ",
  "String Ensemble   ",
  "Velo-Brass        ",
  "Digital Cello     ",
  "O K  Chorale      ",
  "Pianissimo        ",
  "Intruder FX       ",
  "Steel Pick        ",
  "Synth Bass        ",
  "Afterthought      ",
  "Bones             ",
  "Bottle Blower     ",
  "Future Pad        ",
  "PCM E-Piano       "
}

local bankData = nil

function setup()
  mc = lemock.controller()

  midiServiceMock = mc:mock()
  regGlobal("midiService", MidiService())
  regGlobal("Voice_singleSize", 448)
  regGlobal("Voice_Header", MemoryBlock({ 0xF0, 0x41, 0x00, 0x14, 0x12, 0x00, 0x00, 0x00 }))
  regGlobal("Voice_HeaderSize", Voice_Header:getSize())
  regGlobal("Voice_Footer", MemoryBlock({ 0x00, 0xF7 }))
  regGlobal("Voice_FooterSize", Voice_Footer:getSize())


  local f = io.open("test/data/bank.syx", "rb")
  local content = f:read("*all")
  f:close()
  bankData = MemoryBlock(content)
end

function teardown()
  delGlobal("midiService")
  bankData = nil
end

function testConstructorWithoutData()
  local tested = Bank()
  assertEqual(tested:getSelectedPatchIndex(), 0)
  assertEqual(tested.data:getSize(), 34688)

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

function testConstructorWithData()
  local tested = Bank(bankData)
  assertEqual(tested.data:getSize(), 34688)

  for i = 0, 63 do
    tested:setSelectedPatchIndex(i)
    local p = tested:getSelectedPatch()
    assertNotNil(p)
    assertEqual(p:getPatchName(), PATCH_NAMES[i + 1])
    assertEqual(p.patchOffset, i * Voice_singleSize)
  end
end

function testParamSetting()
  local tested = Bank(bankData)
  tested:setSelectedPatchIndex(1)
  local p = tested:getSelectedPatch()

  p:setPatchName("Pelle")
  assertEqual(p:getPatchName(), "Pelle             ")

  p:setUpperToneName("UpperPell")
  assertEqual(p:getUpperToneName(), "UpperPell ")

  p:setLowerToneName("LowerPelle")
  assertEqual(p:getLowerToneName(), "LowerPelle")

  -- Set LFO 1 Rate -> 346
  p:setValue(346, 3)
  assertEqual(p:getValue(346), 3)

  -- Set Partial 1 resonance -> 206
  p:setValue(206, 27)
  assertEqual(p:getValue(206), 27)

  tested:setSelectedPatchIndex(35)
  p = tested:getSelectedPatch()

  p:setPatchName("Pelle35")
  assertEqual(p:getPatchName(), "Pelle35           ")

  p:setUpperToneName("UpperP35")
  assertEqual(p:getUpperToneName(), "UpperP35  ")

  p:setLowerToneName("LowerPel35")
  assertEqual(p:getLowerToneName(), "LowerPel35")

  -- Set LFO 1 Rate -> 346
  p:setValue(346, 2)
  assertEqual(p:getValue(346), 2)

  -- Set Partial 1 resonance -> 206
  p:setValue(206, 29)
  assertEqual(p:getValue(206), 29)

  tested:setSelectedPatchIndex(1)
  p = tested:getSelectedPatch()
  assertEqual(p:getPatchName(), "Pelle             ")
  assertEqual(p:getUpperToneName(), "UpperPell ")
  assertEqual(p:getLowerToneName(), "LowerPelle")
  assertEqual(p:getValue(346), 3)
  assertEqual(p:getValue(206), 27)

  tested:setSelectedPatchIndex(35)
  p = tested:getSelectedPatch()
  assertEqual(p:getPatchName(), "Pelle35           ")
  assertEqual(p:getUpperToneName(), "UpperP35  ")
  assertEqual(p:getLowerToneName(), "LowerPel35")
  assertEqual(p:getValue(346), 2)
  assertEqual(p:getValue(206), 29)
end

function testSetPatchName()

end

function testPartialSelects()
  local tested = Bank(bankData)
  tested:setSelectedPatchIndex(0)
  local p = tested:getSelectedPatch()
  log:info("Lower %d %d", p:getLowerPartial1Value(), p:getLowerPartial2Value())
  log:info("Upper %d %d", p:getUpperPartial1Value(), p:getUpperPartial2Value())

  tested:setSelectedPatchIndex(1)
  p = tested:getSelectedPatch()
  log:info("Lower %d %d", p:getLowerPartial1Value(), p:getLowerPartial2Value())
  log:info("Upper %d %d", p:getUpperPartial1Value(), p:getUpperPartial2Value())

  tested:setSelectedPatchIndex(0)
  p = tested:getSelectedPatch()
  log:info("Lower %d %d", p:getLowerPartial1Value(), p:getLowerPartial2Value())
  log:info("Upper %d %d", p:getUpperPartial1Value(), p:getUpperPartial2Value())

  tested:setSelectedPatchIndex(1)
  p = tested:getSelectedPatch()
  log:info("Lower %d %d", p:getLowerPartial1Value(), p:getLowerPartial2Value())
  log:info("Upper %d %d", p:getUpperPartial1Value(), p:getUpperPartial2Value())
end

runTests{useANSI = false}
