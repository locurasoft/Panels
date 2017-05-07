require("ctrlrTestUtils")
require("Logger")
require("model/Bank")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'BankTest', lunity )

local log = Logger("BankTest")

local PATCH_NAMES =   {
  "PIANO2",
  "DIGPNO",
  "ICYORG",
  "PIPES1",
  "PLKBRS",
  "VANGEL",
  "AHHHHS",
  "STRBAS",
  "KEBASS",
  "ANSYN1",
  "PNOSTR",
  "5OFSWE",
  "SHRTST",
  "ESTR",
  "CHOIRX",
  "SLOBEL",
  "GLDBEL",
  "DBELL",
  "FRIDAY",
  "CHOIR2",
  "KLUNKS",
  "PWRSNK",
  "BIG1",
  "CTHDRL",
  "MINIM3",
  "MIAMIW",
  "\"EOWW\"",
  "SYNLED",
  "STLGUT",
  "CLOUDS",
  "MUSCBX",
  "ORCBEL",
  "BOTTLS",
  "F-111",
  "CHNSAW",
  "STARS*"
}
local bankData = nil

function setup()
  regGlobal("midiService", MidiService())

  local f = io.open("test/data/Esqhits^2.txt", "rb")
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
  assertEqual(tested.data:getSize(), BANK_BUFFER_SIZE)

  local p = tested:getSelectedPatch()
  assertNotNil(p)

  assertEqual(p:getPatchName(), "PATCH")
  assertEqual(p.patchOffset, 0)

  tested:setSelectedPatchIndex(35)

  p = tested:getSelectedPatch()
  assertNotNil(p)
  assertEqual(p:getPatchName(), "PATCH")

  assertEqual(p.patchOffset, 35 * PATCH_BUFFER_SIZE)
end

function testConstructorWithData()
  local tested = Bank(bankData)
  assertEqual(tested.data:getSize(), 8166)

  for i = 0, 39 do
    tested:setSelectedPatchIndex(i)
    local p = tested:getSelectedPatch()
    assertNotNil(p)
    assertEqual(p:getPatchName(), PATCH_NAMES[i + 1])
    for i = 1, 132 do
      p:getValue(i)
    end
  end
end

runTests{useANSI = false}
