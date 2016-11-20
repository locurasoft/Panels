require("LuaObject")
require("Logger")
require("lutils")
require("mutils")

SAMPLE_NAME_LENG  = 12
PROGRAM_NAME_LENG = 12
PROGRAM_HEADER_SIZE = 70
KEY_GROUP_HEADER_SIZE = 148
local AKAI_ALPHABET = {'0','1','2','3','4','5','6','7','8','9',' ','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','#','+','-','.'}

local POSITIVE_NUMBERS = {
  "00 00 00 00", "02 00 00 00", "05 00 00 00", "07 00 00 00", "0A 00 00 00", "0C 00 00 00", "0F 00 00 00", "02 01 00 00", "04 01 00 00", "07 01 00 00", "09 01 00 00", "0C 01 00 00",
  "0E 01 00 00", "01 02 00 00", "03 02 00 00", "06 02 00 00", "09 02 00 00", "0B 02 00 00", "0E 02 00 00", "00 03 00 00", "03 03 00 00", "05 03 00 00", "08 03 00 00", "0B 03 00 00",
  "0D 03 00 00", "00 04 00 00", "02 04 00 00", "05 04 00 00", "07 04 00 00", "0A 04 00 00", "0C 04 00 00", "0F 04 00 00", "02 05 00 00", "04 05 00 00", "07 05 00 00", "09 05 00 00",
  "0C 05 00 00", "0E 05 00 00", "01 06 00 00", "03 06 00 00", "06 06 00 00", "09 06 00 00", "0B 06 00 00", "0E 06 00 00", "00 07 00 00", "03 07 00 00", "05 07 00 00", "08 07 00 00",
  "0B 07 00 00", "0D 07 00 00", "00 08 00 00", "02 08 00 00", "05 08 00 00", "07 08 00 00", "0A 08 00 00", "0C 08 00 00", "0F 08 00 00", "02 09 00 00", "04 09 00 00", "07 09 00 00",
  "09 09 00 00", "0C 09 00 00", "0E 09 00 00", "01 0A 00 00", "03 0A 00 00", "06 0A 00 00", "09 0A 00 00", "0B 0A 00 00", "0E 0A 00 00", "00 0B 00 00", "03 0B 00 00", "05 0B 00 00",
  "08 0B 00 00", "0B 0B 00 00", "0D 0B 00 00", "00 0C 00 00", "02 0C 00 00", "05 0C 00 00", "07 0C 00 00", "0A 0C 00 00", "0C 0C 00 00", "0F 0C 00 00", "02 0D 00 00", "04 0D 00 00",
  "07 0D 00 00", "09 0D 00 00", "0C 0D 00 00", "0E 0D 00 00", "01 0E 00 00", "03 0E 00 00", "06 0E 00 00", "09 0E 00 00", "0B 0E 00 00", "0E 0E 00 00", "00 0F 00 00", "03 0F 00 00",
  "05 0F 00 00", "08 0F 00 00", "0B 0F 00 00", "0D 0F 00 00"
}

local NEGATIVE_NUMBERS = {
  "00 00 0F 0F", "0E 0F 0F 0F", "0B 0F 0F 0F", "09 0F 0F 0F", "06 0F 0F 0F", "04 0F 0F 0F", "01 0F 0F 0F", "0E 0E 0F 0F", "0C 0E 0F 0F", "09 0E 0F 0F", "07 0E 0F 0F", "04 0E 0F 0F",
  "02 0E 0F 0F", "0F 0D 0F 0F", "0D 0D 0F 0F", "0A 0D 0F 0F", "07 0D 0F 0F", "05 0D 0F 0F", "02 0D 0F 0F", "00 0D 0F 0F", "0D 0C 0F 0F", "0B 0C 0F 0F", "08 0C 0F 0F", "05 0C 0F 0F",
  "03 0C 0F 0F", "00 0C 0F 0F", "0E 0B 0F 0F", "0B 0B 0F 0F", "09 0B 0F 0F", "06 0B 0F 0F", "04 0B 0F 0F", "01 0B 0F 0F", "0E 0A 0F 0F", "0C 0A 0F 0F", "09 0A 0F 0F", "07 0A 0F 0F",
  "04 0A 0F 0F", "02 0A 0F 0F", "0F 09 0F 0F", "0D 09 0F 0F", "0A 09 0F 0F", "07 09 0F 0F", "05 09 0F 0F", "02 09 0F 0F", "00 09 0F 0F", "0D 08 0F 0F", "0B 08 0F 0F", "08 08 0F 0F",
  "05 08 0F 0F", "03 08 0F 0F", "00 08 0F 0F", "0E 07 0F 0F", "0B 07 0F 0F", "09 07 0F 0F", "06 07 0F 0F", "04 07 0F 0F", "01 07 0F 0F", "0E 06 0F 0F", "0C 06 0F 0F", "09 06 0F 0F",
  "07 06 0F 0F", "04 06 0F 0F", "02 06 0F 0F", "0F 05 0F 0F", "0D 05 0F 0F", "0A 05 0F 0F", "07 05 0F 0F", "05 05 0F 0F", "02 05 0F 0F", "00 05 0F 0F", "0D 04 0F 0F", "0B 04 0F 0F",
  "08 04 0F 0F", "05 04 0F 0F", "03 04 0F 0F", "00 04 0F 0F", "0E 03 0F 0F", "0B 03 0F 0F", "09 03 0F 0F", "06 03 0F 0F", "04 03 0F 0F", "01 03 0F 0F", "0E 02 0F 0F", "0C 02 0F 0F",
  "09 02 0F 0F", "07 02 0F 0F", "04 02 0F 0F", "02 02 0F 0F", "0F 01 0F 0F", "0D 01 0F 0F", "0A 01 0F 0F", "07 01 0F 0F", "05 01 0F 0F", "02 01 0F 0F", "00 01 0F 0F", "0D 00 0F 0F",
  "0B 00 0F 0F", "08 00 0F 0F", "05 00 0F 0F", "03 00 0F 0F"
}

local log = Logger("MidiService")

MidiService = {}
MidiService.__index = MidiService

setmetatable(MidiService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
--@module __MidiService
function MidiService:_init()
  LuaObject._init(self)
  self.onMidiReceivedFunc = nil
  self.alphabet = AKAI_ALPHABET
  self.flipAlphabet = lutils.flipTable(AKAI_ALPHABET)
end

function MidiService:dispatchMidi(data)
  if data:getByte(0) ~= 0xF0 or data:getByte(1) ~= 0x47 then
    log:info("Invalid S2K Sysex received!")
    return
  end

  if self.onMidiReceivedFunc ~= nil then
    self.onMidiReceivedFunc(data)
  end
end

function MidiService:clearMidiReceived()
  self.onMidiReceivedFunc = nil
end

function MidiService:setMidiReceived(midiCallback)
  self.onMidiReceivedFunc = midiCallback
end


---
-- @function [parent=#MidiService] sendMidiMessage
--
function MidiService:sendMidiMessage(syxMsg)
  panel:sendMidiMessageNow(syxMsg:toMidiMessage())
end

---
-- @function [parent=#MidiService] sendMidiMessages
--
function MidiService:sendMidiMessages(msgs)
  for k, nextMsg in pairs(msgs) do
    self:sendMidiMessage(nextMsg)
  end
end

function MidiService:toTuneBytes(value)
  local mm = math.floor(value / 100)
  if value < 0 then
    mm = math.ceil(value / 100)
  end
  local ll = math.abs(value - mm * 100)
  return ll, mm
end

function MidiService:toTuneBlock(value)
  return mutils.f2n(value / 100)
end

---
-- @function [parent=#MidiService] fromTuneBlock
--
function MidiService:fromTuneBlock(block, offset)
  return mutils.n2f(block, offset) * 100
end

---
-- @function [parent=#MidiService] toVssBlock
--
function MidiService:toVssBlock(value)
  local retval = MemoryBlock(4, true)
  local bigInt = BigInteger(value)
  if value < 0 then
    retval:setByte(0, bit.band(bit.bnot(bigInt:getBitRangeAsInt(0, 4)) + 1, 0xF))
    retval:setByte(1, bit.band(bit.bnot(bigInt:getBitRangeAsInt(4, 4)), 0xF))
    retval:setByte(2, bit.band(bit.bnot(bigInt:getBitRangeAsInt(8, 4)), 0xF))
    retval:setByte(3, bit.band(bit.bnot(bigInt:getBitRangeAsInt(12, 4)), 0xF))
  else
    retval:setByte(0, bigInt:getBitRangeAsInt(0, 4))
    retval:setByte(1, bigInt:getBitRangeAsInt(4, 4))
    retval:setByte(2, bigInt:getBitRangeAsInt(8, 4))
    retval:setByte(3, bigInt:getBitRangeAsInt(12, 4))
  end
  return retval
end

---
-- @function [parent=#MidiService] toFilqBlock
--
function MidiService:toFilqBlock(value)
  local retval = MemoryBlock(4, true)
  local values = mutils.d2n(value)
  retval:setByte(0, values:getByte(0))
  retval:setByte(1, values:getByte(1))
  retval:setByte(2, 0x03)
  retval:setByte(3, 0x06)
  return retval
end

---
-- @function [parent=#MidiService] fromVssBlock
--
function MidiService:fromVssBlock(buffer, offset)
  local bigInt = BigInteger(0)
  bigInt:setBitRangeAsInt(0, 8, buffer:getByte(offset))
  bigInt:setBitRangeAsInt(4, 8, buffer:getByte(offset + 1))
  bigInt:setBitRangeAsInt(8, 8, buffer:getByte(offset + 2))
  bigInt:setBitRangeAsInt(12, 8, buffer:getByte(offset + 3))
  local retval = bigInt:getBitRangeAsInt(0, 16)
  if buffer:getByte(offset + 3) > 8 then
    local invInt = bit.bnot(retval) + 1
    retval = (65536 + invInt) * -1
  end
  return retval
end

---
-- @function [parent=#MidiService] toStringBlock
--
function MidiService:toStringBlock(value)
  return self:toAkaiStringNibbles(value)
end

---
-- @function [parent=#MidiService] fromStringBlock
--
function MidiService:fromStringBlock(buffer, offset)
  local temp = MemoryBlock(PROGRAM_NAME_LENG * 2, true)
  buffer:copyTo(temp, offset, PROGRAM_NAME_LENG * 2)
  return self:fromAkaiStringNibbles(temp)
end

---
-- @function [parent=#MidiService] toDefaultBlock
--
function MidiService:toDefaultBlock(value)
  return mutils.d2n(value)
end

---
-- @function [parent=#MidiService] fromDefaultBlock
--
function MidiService:fromDefaultBlock(buffer, offset)
  return mutils.n2d(buffer:getByte(offset), buffer:getByte(offset + 1))
end

---
-- Returns a LUA string representation of an Akai sysex string
-- @function [parent=#MidiService] fromAkaiStringBytes
--
function MidiService:fromAkaiStringBytes(bytes)
  local result = ""
  for i = 1, bytes:getSize() do
    result = string.format("%s%s", result, self.alphabet[bytes:getByte(i - 1) + 1])
  end
  return result
end

---
-- Returns a LUA string representation of an Akai sysex string
-- @function [parent=#MidiService] fromAkaiStringNibbles
--
function MidiService:fromAkaiStringNibbles(nibbles)
  local bytes = mutils.n2a(nibbles)
  return self:fromAkaiStringBytes(bytes)
end


function MidiService:toAkaiString(str)
  local retval = ""
  for i = 1, SAMPLE_NAME_LENG do
    -- Pad with spaces
    if i > #str then
      retval = string.format("%s%s", retval, " ")
    else
      retval = string.format("%s%s", retval, string.sub(str, i, i):upper())
    end
  end
  return retval
end

---
-- @function [parent=#MidiService] toAkaiStringNibbles
--
function MidiService:toAkaiStringNibbles(name)
  local akaiString = self:toAkaiString(name)
  local akaiStringBytes = MemoryBlock(SAMPLE_NAME_LENG, true)
  for i = 1, SAMPLE_NAME_LENG do
    akaiStringBytes:setByte(i - 1, self.flipAlphabet[string.sub(akaiString, i, i)] - 1)
  end
  return mutils.a2n(akaiStringBytes)
end
