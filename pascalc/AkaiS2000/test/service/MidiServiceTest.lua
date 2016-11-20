require("akaiS2kTestUtils")
require("service/MidiService")
require("message/DelkMsg")
require 'lunity'
require 'lemock'
module( 'MidiServiceTest', lunity )

local progNames = {
  ["TEST PROGRAM"] = "1E 0F 1D 1E 0A 1A 1C 19 11 1C 0B 17",
  ["MUTE-DAMPSW1"] = "17 1F 1E 0F 27 0E 0B 17 1A 1D 21 01",
  ["MUTE-DAMPSW2"] = "17 1F 1E 0F 27 0E 0B 17 1A 1D 21 02",
  ["MUTE-PULLSW1"] = "17 1F 1E 0F 27 1A 1F 16 16 1D 21 01",
  ["MUTE-PULLSW2"] = "17 1F 1E 0F 27 1A 1F 16 16 1D 21 02",
  ["3-WAY SW 1  "] = "03 27 21 0B 23 0A 1D 21 0A 01 0A 0A",
  ["3-WAY SW 2  "] = "03 27 21 0B 23 0A 1D 21 0A 02 0A 0A",
  ["MUTE GUITAR1"] = "17 1F 1E 0F 0A 11 1F 13 1E 0B 1C 01",
  ["MUTE GUITAR2"] = "17 1F 1E 0F 0A 11 1F 13 1E 0B 1C 02",
  ["DAMP GUITAR1"] = "0E 0B 17 1A 0A 11 1F 13 1E 0B 1C 01",
  ["DAMP GUITAR2"] = "0E 0B 17 1A 0A 11 1F 13 1E 0B 1C 02",
  ["GIBSON 335 1"] = "11 13 0C 1D 19 18 0A 03 03 05 0A 01",
  ["GIBSON 335 2"] = "11 13 0C 1D 19 18 0A 03 03 05 0A 02",
  ["GIBSON PLECT"] = "11 13 0C 1D 19 18 0A 1A 16 0F 0D 1E",
  ["GIBSON HARM1"] = "11 13 0C 1D 19 18 0A 12 0B 1C 17 01",
  ["GIBSON HARM2"] = "11 13 0C 1D 19 18 0A 12 0B 1C 17 02",
  ["DAMP GIBSON1"] = "0E 0B 17 1A 0A 11 13 0C 1D 19 18 01",
  ["DAMP GIBSON2"] = "0E 0B 17 1A 0A 11 13 0C 1D 19 18 02",
  ["OCT DMP GBSN"] = "19 0D 1E 0A 0E 17 1A 0A 11 0C 1D 18",
  ["GIBSON BASS1"] = "11 13 0C 1D 19 18 0A 0C 0B 1D 1D 01",
  ["GIBSON BASS2"] = "11 13 0C 1D 19 18 0A 0C 0B 1D 1D 02",
  ["JAZZ DUOBASS"] = "14 0B 24 24 0A 0E 1F 19 0C 0B 1D 1D",
  ["JAZZ DUO GTR"] = "14 0B 24 24 0A 0E 1F 19 0A 11 1E 1C",
}

local s = "01 01 03 01 0C 00 0D 01 09 01 08 01 0A 00 0C 00 0B 00 0D 01 0D 01 02 00"

function setup()
  mc = lemock.controller()
  panel = mc:mock()
  syxMsg = mc:mock()
  regGlobal("panel", panel)
end

function teardown()
  delGlobal("panel")
end

function testConstructor()
  local tested = MidiService()
  assertEqual(type(tested), "table")
end

function testProgNames()
  local tested = MidiService()
  for k, v in ipairs(progNames) do
    assertEqual(tested:fromAkaiStringBytes(MemoryBlock(v)), k)
  end
end

function testSendMidiMessages_1Msg()
  local tested = MidiService()
  local msgs = { syxMsg }

  syxMsg:toMidiMessage(); mc:returns(1); mc:times(1)
  panel:sendMidiMessageNow(1); mc:times(1)

  mc:replay()
  tested:sendMidiMessages(msgs)
  mc:verify()
end

function testSendMidiMessages_3Msgs()
  local tested = MidiService()
  local msgs = { syxMsg, syxMsg, syxMsg }

  syxMsg:toMidiMessage(); mc:returns(1); mc:times(3)
  panel:sendMidiMessageNow(1); mc:times(3)

  mc:replay()
  tested:sendMidiMessages(msgs)
  mc:verify()
end

function testSendMidiMessages_12Msgs()
  local tested = MidiService()
  local msgs = { syxMsg, syxMsg, syxMsg,
    syxMsg, syxMsg, syxMsg,
    syxMsg, syxMsg, syxMsg,
    syxMsg, syxMsg, syxMsg }
  syxMsg:toMidiMessage(); mc:returns(1); mc:times(12)
  panel:sendMidiMessageNow(1); mc:times(12)

  mc:replay()
  tested:sendMidiMessages(msgs)
  mc:verify()
end

function testMidiDispatcher()
  local data = MemoryBlock({0xF0, 0x47})
  local midiReceivedCount = 0
  local midiReceivedFunc = function(d)
    assertEqual(d, data)
    midiReceivedCount = midiReceivedCount + 1
  end

  local tested = MidiService()
  tested:setMidiReceived(midiReceivedFunc)
  tested:dispatchMidi(data)
  assertEqual(midiReceivedCount, 1)

  tested:dispatchMidi(data)
  assertEqual(midiReceivedCount, 2)

  tested:dispatchMidi(data)
  assertEqual(midiReceivedCount, 3)

  --No midi received func registered
  tested:clearMidiReceived()
  tested:dispatchMidi(data)
  assertEqual(midiReceivedCount, 3)

  -- Wrong midi data
  data = MemoryBlock({0x00, 0x47})
  tested:setMidiReceived(midiReceivedFunc)
  tested:dispatchMidi(data)
  assertEqual(midiReceivedCount, 3)
end

function testTofromAkaiStringNibbles()
  local tested = MidiService()
  local resultData = tested:toAkaiStringNibbles("Test")
  local resultString = tested:fromAkaiStringNibbles(resultData)
  assertEqual(resultString, "TEST        ")

  resultData = tested:toAkaiStringNibbles("T")
  resultString = tested:fromAkaiStringNibbles(resultData)
  assertEqual(resultString, "T           ")

  resultData = tested:toAkaiStringNibbles("ABCDEFGHIJKL")
  resultString = tested:fromAkaiStringNibbles(resultData)
  assertEqual(resultString, "ABCDEFGHIJKL")

  resultData = tested:toAkaiStringNibbles("abcdefghijkl")
  resultString = tested:fromAkaiStringNibbles(resultData)
  assertEqual(resultString, "ABCDEFGHIJKL")

  resultData = tested:toAkaiStringNibbles("abcdefghijklmnop")
  resultString = tested:fromAkaiStringNibbles(resultData)
  assertEqual(resultString, "ABCDEFGHIJKL")

  local slapBass = "0d 01 06 01 0b 00 0a 01 0a 00 0c 00 0b 00 0d 01 0d 01 0a 00 0a 00 0a 00"
  local percLoop = "0a 01 0f 00 0c 01 0d 00 0a 00 06 01 09 01 09 01 0a 01 0a 00 0a 00 0a 00"
  local dDrumSet = "0e 00 08 02 0e 00 0c 01 0f 01 07 01 0a 00 0d 01 0f 00 0e 01 0a 00 0a 00"

  resultString = tested:fromAkaiStringNibbles(MemoryBlock(slapBass))
  assertEqual(resultString, "SLAP BASS   ")
  resultString = tested:fromAkaiStringNibbles(MemoryBlock(percLoop))
  assertEqual(resultString, "PERC LOOP   ")
  resultString = tested:fromAkaiStringNibbles(MemoryBlock(dDrumSet))
  assertEqual(resultString, "D.DRUM SET  ")

  resultData = tested:toAkaiStringNibbles("SLAP BASS")
  assertEqual(slapBass, resultData:toHexString(1))
  resultData = tested:toAkaiStringNibbles("PERC LOOP")
  assertEqual(percLoop, resultData:toHexString(1))
  resultData = tested:toAkaiStringNibbles("D.DRUM SET  ")
  assertEqual(dDrumSet, resultData:toHexString(1))

end

runTests{useANSI = false}
