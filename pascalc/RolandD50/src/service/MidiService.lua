require("LuaObject")
require("Logger")
require("lutils")
require("mutils")

local log = Logger("MidiService")

local CHECKSUM_START = 5

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
end

function MidiService:calculateChecksum(sysex, csEnd)
  local sum = 0
  for i = CHECKSUM_START, csEnd do
    sum = sum + sysex:getByte(i)
  end
  sum = sum * -1
  return bit.band(sum, 0x7f)
end

function MidiService:trimSyxData(data)
  local dataSize = data:getSize()
  local cleanIndex = 0
  local cleanData = MemoryBlock(dataSize, true)
  local i = 0
  while i < dataSize do
    -- gets the voice parameter values
    if bit.band(data:getByte(i), 0xFF) == 0xF0 then
      i = i + 8
    elseif bit.band(data:getByte(i+1), 0xFF) == 0xF7 then
      i = i + 2
    else
      cleanData:setByte(cleanIndex, data:getByte(i))
      cleanIndex = cleanIndex + 1
      i = i + 1
    end
  end
  local trimmedData = MemoryBlock(cleanIndex, true)
  trimmedData:copyFrom(cleanData, 0, cleanIndex)
  return trimmedData
end

function MidiService:splitIntoSysexMessages(data)
  local dataSize = data:getSize()
  local numWholeMessages = math.floor(dataSize / 256)

  log:fine("MsgSplit: dataSize %d, numWholeMessages %d", dataSize, numWholeMessages)

  local messages = {}

  local address = 0
  local tempHeader = MemoryBlock(Voice_HeaderSize, true)
  for i = 0, numWholeMessages do
    local msgSize = 256
    if i == numWholeMessages then
      msgSize = dataSize - (numWholeMessages * msgSize)
      if msgSize == 0 then
        break
      end
    end
    local wholeMsgSize = Voice_HeaderSize + msgSize + Voice_FooterSize
    local splitMessageData = MemoryBlock(wholeMsgSize, true)
    tempHeader:copyFrom(Voice_Header, 0, Voice_HeaderSize)

    local hsb = math.floor(address / (0x80 * 0x80))
    local rest = address - hsb * 0x80 * 0x80
    local msb = math.floor(rest / 0x80)
    local lsb = rest -  msb * 0x80
    tempHeader:setByte(5, hsb + 2)
    tempHeader:setByte(6, msb)
    tempHeader:setByte(7, lsb)

    splitMessageData:copyFrom(tempHeader, 0, Voice_HeaderSize)
    local tempData = MemoryBlock(msgSize, true)
    data:copyTo(tempData, address, msgSize)
    splitMessageData:copyFrom(tempData, Voice_HeaderSize, msgSize)

    local offset = Voice_HeaderSize + msgSize
    splitMessageData:copyFrom(Voice_Footer, offset, Voice_FooterSize)

    local cs = self:calculateChecksum(splitMessageData, CHECKSUM_START + msgSize + 3)
    splitMessageData:setByte(wholeMsgSize - 2, cs)
    table.insert(messages, splitMessageData)
    address = address + msgSize
  end
  log:fine("MsgSplit: Num messages %d", table.getn(messages))
  return messages
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
