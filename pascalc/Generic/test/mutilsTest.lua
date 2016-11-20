require("ctrlrTestUtils")
require("mutils")
require 'lunity'
module( 'mutilsTest', lunity )

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


function testNibbleConversion()
  local result = mutils.d2n(1)
  assertEqual(result:getByte(0), 1)
  assertEqual(result:getByte(1), 0)
  result = mutils.d2n(2)
  assertEqual(result:getByte(0), 2)
  assertEqual(result:getByte(1), 0)
    
  assertEqual(mutils.n2d(1, 0), 1)
  assertEqual(mutils.n2d(2, 0), 2)
end

function testA2n()
	local s1 = "01 01 03 01 0C 00 0D 01 09 01 08 01 0A 00 0C 00 0B 00 0D 01 0D 01 02 00"
	local result = mutils.n2a(MemoryBlock(s1))
	assertEqual(result:toHexString(1):upper(), "11 13 0C 1D 19 18 0A 0C 0B 1D 1D 02")
end

function testF2n()
  local verifyFloat2Nibbles = function(value, expectedMemBlock)
    local temp = string.upper(mutils.f2n(value):toHexString(1))
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

function testN2f()
  local verifyNibbles2Float = function(memBlock, expectedValue)
    local result = mutils.n2f(MemoryBlock(memBlock), 0)

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
  for k,v in pairs(nibbles) do
    local result = mutils.d2n(k - 1)
    assertEqual(result:toHexString(1), v)
  end

  for k,v in pairs(nibbles) do
    local mb = MemoryBlock(v)
    local result = mutils.n2d(mb:getByte(0), mb:getByte(1))
    assertEqual(result, k - 1)
  end
end

function testN2d()
	assertEqual(mutils.n2d(0x0E, 0x0C), -50)
  assertEqual(mutils.n2d(0x07, 0x0E), -25)
  assertEqual(mutils.n2d(0x0F, 0x0F), -1)
end

function testD2b()
  assertEqual(mutils.d2b(0):toHexString(1), "00 00")
  assertEqual(mutils.d2b(1):toHexString(1), "01 00")
  assertEqual(mutils.d2b(2):toHexString(1), "02 00")
  assertEqual(mutils.d2b(16):toHexString(1), "10 00")
  assertEqual(mutils.d2b(20):toHexString(1), "14 00")
  assertEqual(mutils.d2b(33):toHexString(1), "21 00")
  assertEqual(mutils.d2b(118):toHexString(1), "76 00")
  assertEqual(mutils.d2b(132):toHexString(1), "04 01")
  assertEqual(mutils.d2b(146):toHexString(1), "12 01")
  assertEqual(mutils.d2b(149):toHexString(1), "15 01")
  assertEqual(mutils.d2b(150):toHexString(1), "16 01")
  assertEqual(mutils.d2b(151):toHexString(1), "17 01")
  assertEqual(mutils.d2b(159):toHexString(1), "1f 01")
end

runTests{useANSI = false}
