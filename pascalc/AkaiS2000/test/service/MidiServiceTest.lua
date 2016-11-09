require("akaiS2kTestUtils")
require("service/MidiService")
require("message/DelkMsg")
require 'lunity'
require 'lemock'
module( 'MidiServiceTest', lunity )

local positiveNumbers = {   
    "02 00 00 00",
    "05 00 00 00",
    "07 00 00 00",
    "0A 00 00 00",
    "0C 00 00 00",
    "0F 00 00 00",
    "02 01 00 00",
    "04 01 00 00",
    "07 01 00 00",
    "09 01 00 00",
    "0C 01 00 00",
    "0E 01 00 00",
    "01 02 00 00",
    "03 02 00 00",
    "06 02 00 00",
    "09 02 00 00",
    "0B 02 00 00",
    "0E 02 00 00",
    "00 03 00 00",
    "03 03 00 00",
    "05 03 00 00",
    "08 03 00 00",
    "0B 03 00 00",
    "0D 03 00 00",
    "00 04 00 00",
    "02 04 00 00",
    "05 04 00 00",
    "07 04 00 00",
    "0A 04 00 00",
    "0C 04 00 00",
    "0F 04 00 00",
    "02 05 00 00",
    "04 05 00 00",
    "07 05 00 00",
    "09 05 00 00",
    "0C 05 00 00",
    "0E 05 00 00",
    "01 06 00 00",
    "03 06 00 00",
    "06 06 00 00",
    "09 06 00 00",
    "0B 06 00 00",
    "0E 06 00 00",
    "00 07 00 00",
    "03 07 00 00",
    "05 07 00 00",
    "08 07 00 00",
    "0B 07 00 00",
    "0D 07 00 00",
    "00 08 00 00",
    "02 08 00 00",
    "05 08 00 00",
    "07 08 00 00",
    "0A 08 00 00",
    "0C 08 00 00",
    "0F 08 00 00",
    "02 09 00 00",
    "04 09 00 00",
    "07 09 00 00",
    "09 09 00 00",
    "0C 09 00 00",
    "0E 09 00 00",
    "01 0A 00 00",
    "03 0A 00 00",
    "06 0A 00 00",
    "09 0A 00 00",
    "0B 0A 00 00",
    "0E 0A 00 00",
    "00 0B 00 00",
    "03 0B 00 00",
    "05 0B 00 00",
    "08 0B 00 00",
    "0B 0B 00 00",
    "0D 0B 00 00",
    "00 0C 00 00",
    "02 0C 00 00",
    "05 0C 00 00",
    "07 0C 00 00",
    "0A 0C 00 00",
    "0C 0C 00 00",
    "0F 0C 00 00",
    "02 0D 00 00",
    "04 0D 00 00",
    "07 0D 00 00",
    "09 0D 00 00",
    "0C 0D 00 00",
    "0E 0D 00 00",
    "01 0E 00 00",
    "03 0E 00 00",
    "06 0E 00 00",
    "09 0E 00 00",
    "0B 0E 00 00",
    "0E 0E 00 00",
    "00 0F 00 00",
    "03 0F 00 00",
    "05 0F 00 00",
    "08 0F 00 00",
    "0B 0F 00 00",
    "0D 0F 00 00",
    "00 00 01 00"
}

local negativeNumbers = {
    "0E 0F 0F 0F",
    "0B 0F 0F 0F",
    "09 0F 0F 0F",
    "06 0F 0F 0F",
    "04 0F 0F 0F",
    "01 0F 0F 0F",
    "0E 0E 0F 0F",
    "0C 0E 0F 0F",
    "09 0E 0F 0F",
    "07 0E 0F 0F",
    "04 0E 0F 0F",
    "02 0E 0F 0F",
    "0F 0D 0F 0F",
    "0D 0D 0F 0F",
    "0A 0D 0F 0F",
    "07 0D 0F 0F",
    "05 0D 0F 0F",
    "02 0D 0F 0F",
    "00 0D 0F 0F",
    "0D 0C 0F 0F",
    "0B 0C 0F 0F",
    "08 0C 0F 0F",
    "05 0C 0F 0F",
    "03 0C 0F 0F",
    "00 0C 0F 0F",
    "0E 0B 0F 0F",
    "0B 0B 0F 0F",
    "09 0B 0F 0F",
    "06 0B 0F 0F",
    "04 0B 0F 0F",
    "01 0B 0F 0F",
    "0E 0A 0F 0F",
    "0C 0A 0F 0F",
    "09 0A 0F 0F",
    "07 0A 0F 0F",
    "04 0A 0F 0F",
    "02 0A 0F 0F",
    "0F 09 0F 0F",
    "0D 09 0F 0F",
    "0A 09 0F 0F",
    "07 09 0F 0F",
    "05 09 0F 0F",
    "02 09 0F 0F",
    "00 09 0F 0F",
    "0D 08 0F 0F",
    "0B 08 0F 0F",
    "08 08 0F 0F",
    "05 08 0F 0F",
    "03 08 0F 0F",
    "00 08 0F 0F",
    "0E 07 0F 0F",
    "0B 07 0F 0F",
    "09 07 0F 0F",
    "06 07 0F 0F",
    "04 07 0F 0F",
    "01 07 0F 0F",
    "0E 06 0F 0F",
    "0C 06 0F 0F",
    "09 06 0F 0F",
    "07 06 0F 0F",
    "04 06 0F 0F",
    "02 06 0F 0F",
    "0F 05 0F 0F",
    "0D 05 0F 0F",
    "0A 05 0F 0F",
    "07 05 0F 0F",
    "05 05 0F 0F",
    "02 05 0F 0F",
    "00 05 0F 0F",
    "0D 04 0F 0F",
    "0B 04 0F 0F",
    "08 04 0F 0F",
    "05 04 0F 0F",
    "03 04 0F 0F",
    "00 04 0F 0F",
    "0E 03 0F 0F",
    "0B 03 0F 0F",
    "09 03 0F 0F",
    "06 03 0F 0F",
    "04 03 0F 0F",
    "01 03 0F 0F",
    "0E 02 0F 0F",
    "0C 02 0F 0F",
    "09 02 0F 0F",
    "07 02 0F 0F",
    "04 02 0F 0F",
    "02 02 0F 0F",
    "0F 01 0F 0F",
    "0D 01 0F 0F",
    "0A 01 0F 0F",
    "07 01 0F 0F",
    "05 01 0F 0F",
    "02 01 0F 0F",
    "00 01 0F 0F",
    "0D 00 0F 0F",
    "0B 00 0F 0F",
    "08 00 0F 0F",
    "05 00 0F 0F",
    "03 00 0F 0F",
    "00 00 0F 0F"
}

local floatIntegers = {
  ["-50.00"] = "00 00 0E 0C",
  ["-40.00"] = "00 00 08 0D",
  ["-30.00"] = "00 00 02 0E",
  ["-20.00"] = "00 00 0C 0E",
  ["-10.00"] = "00 00 06 0F",
  ["00.00"] = "00 00 00 00",
  ["10.00"] = "00 00 0A 00",
  ["20.00"] = "00 00 04 01",
  ["30.00"] = "00 00 0E 01",
  ["40.00"] = "00 00 08 02",
  ["50.00"] = "00 00 02 03"
}

local nibbles = {
  "00 00",
  "01 00",
  "02 00",
  "03 00",
  "04 00",
  "05 00",
  "06 00",
  "07 00",
  "08 00",
  "09 00",
  "0a 00",
  "0b 00",
  "0c 00",
  "0d 00",
  "0e 00",
  "0f 00",
  "00 01",
  "01 01",
  "02 01",
  "03 01",
  "04 01",
  "05 01",
  "06 01",
  "07 01",
  "08 01",
  "09 01",
  "0a 01",
  "0b 01",
  "0c 01",
  "0d 01",
  "0e 01",
  "0f 01",
  "00 02",
  "01 02",
  "02 02",
  "03 02",
  "04 02",
  "05 02",
  "06 02",
  "07 02",
  "08 02",
  "09 02",
  "0a 02",
  "0b 02",
  "0c 02",
  "0d 02",
  "0e 02",
  "0f 02",
  "00 03",
  "01 03",
  "02 03",
  "03 03",
  "04 03",
  "05 03",
  "06 03",
  "07 03",
  "08 03",
  "09 03",
  "0a 03",
  "0b 03",
  "0c 03",
  "0d 03",
  "0e 03",
  "0f 03",
  "00 04",
  "01 04",
  "02 04",
  "03 04",
  "04 04",
  "05 04",
  "06 04",
  "07 04",
  "08 04",
  "09 04",
  "0a 04",
  "0b 04",
  "0c 04",
  "0d 04",
  "0e 04",
  "0f 04",
  "00 05",
  "01 05",
  "02 05",
  "03 05",
  "04 05",
  "05 05",
  "06 05",
  "07 05",
  "08 05",
  "09 05",
  "0a 05",
  "0b 05",
  "0c 05",
  "0d 05",
  "0e 05",
  "0f 05",
  "00 06",
  "01 06",
  "02 06",
  "03 06"
}

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

function testFloat2Nibbles()
  local tested = MidiService()
  local verifyFloat2Nibbles = function(value, expectedMemBlock)
      local temp = string.upper(tested:float2nibbles(value):toHexString(1))
      assertEqual(temp, expectedMemBlock, 
        string.format("Incorrect result for %.2f, expected %s, got %s", value, expectedMemBlock, temp))
  end
  
  for k,v in pairs(floatIntegers) do
      verifyFloat2Nibbles(tonumber(k), v)
  end
  
  for k,v in pairs(positiveNumbers) do
      verifyFloat2Nibbles(k / 100, v)
  end
  
  for k,v in pairs(negativeNumbers) do
      verifyFloat2Nibbles((k / 100) * -1, v)
  end
end

function testNibbles2Float()
  local tested = MidiService()
  local verifyNibbles2Float = function(memBlock, expectedValue)
    local result = tested:nibbles2float(MemoryBlock(memBlock), 0)
    
    assertEqual(
      string.format("%.2f", result), 
      string.format("%.2f", expectedValue), 
      string.format("Incorrect result for %s, expected %.2f, got %.2f", 
        memBlock, expectedValue, result))
  end

  for k,v in pairs(floatIntegers) do
    verifyNibbles2Float(v, tonumber(k))
  end
  
  for k,v in pairs(positiveNumbers) do
    verifyNibbles2Float(v, k / 100)
  end
  
  for k,v in pairs(negativeNumbers) do
    verifyNibbles2Float(v, (k / 100) * -1)
  end
end

function testToFromNibbles()
  local tested = MidiService()
  for k,v in pairs(nibbles) do
    local result = tested:toNibbles(k - 1)
    assertEqual(result:toHexString(1), v)
  end

  for k,v in pairs(nibbles) do
    local mb = MemoryBlock(v)
    local result = tested:fromNibbles(mb:getByte(0), mb:getByte(1))
    assertEqual(result, k - 1)
  end
end

function testTofromAkaiStringBytes()
	local tested = MidiService()
	local resultData = tested:toAkaiStringBytes("Test")
	local resultString = tested:fromAkaiStringBytes(resultData)
	assertEqual(resultString, "TEST        ")
	
	resultData = tested:toAkaiStringBytes("T")
  resultString = tested:fromAkaiStringBytes(resultData)
  assertEqual(resultString, "T           ")
  
  resultData = tested:toAkaiStringBytes("ABCDEFGHIJKL")
  resultString = tested:fromAkaiStringBytes(resultData)
  assertEqual(resultString, "ABCDEFGHIJKL")
  
  resultData = tested:toAkaiStringBytes("abcdefghijkl")
  resultString = tested:fromAkaiStringBytes(resultData)
  assertEqual(resultString, "ABCDEFGHIJKL")
  
  resultData = tested:toAkaiStringBytes("abcdefghijklmnop")
  resultString = tested:fromAkaiStringBytes(resultData)
  assertEqual(resultString, "ABCDEFGHIJKL")
  
  local slapBass = "1d 16 0b 1a 0a 0c 0b 1d 1d 0a 0a 0a"
  local percLoop = "1a 0f 1c 0d 0a 16 19 19 1a 0a 0a 0a"
  local dDrumSet = "0e 28 0e 1c 1f 17 0a 1d 0f 1e 0a 0a"

  resultString = tested:fromAkaiStringBytes(MemoryBlock(slapBass))
  assertEqual(resultString, "SLAP BASS   ")
  resultString = tested:fromAkaiStringBytes(MemoryBlock(percLoop))
  assertEqual(resultString, "PERC LOOP   ")
  resultString = tested:fromAkaiStringBytes(MemoryBlock(dDrumSet))
  assertEqual(resultString, "D.DRUM SET  ")
  
  resultData = tested:toAkaiStringBytes("SLAP BASS")
  assertEqual(slapBass, resultData:toHexString(1))
  resultData = tested:toAkaiStringBytes("PERC LOOP")
  assertEqual(percLoop, resultData:toHexString(1))
  resultData = tested:toAkaiStringBytes("D.DRUM SET  ")
  assertEqual(dDrumSet, resultData:toHexString(1))
  
end

runTests{useANSI = false}
