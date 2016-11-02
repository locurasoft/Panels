require("SyxMsg")
require("Logger")

local log = Logger("SlistMsg")
local numSamplesOffs = 5
local sampleNameOffs = 7

SlistMsg = {}
SlistMsg.__index = SlistMsg

setmetatable(SlistMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SlistMsg:_init(bytes)
  SyxMsg._init(self)
  assert(bytes:getByte(3) == 0x05, "Invalid slist message")
  self.data = bytes
end

function SlistMsg:getNumSamples()
  return self.data:getByte(numSamplesOffs)
end

function SlistMsg:getSampleList()
  local offset = sampleNameOffs
  local numSamples = self:getNumSamples()
  local buf = MemoryBlock(SAMPLE_NAME_LENG, true)
  local sampleNames = {}

  while offset + SAMPLE_NAME_LENG < self.data:getSize() do
    self.data:copyTo(buf, offset, SAMPLE_NAME_LENG)
    offset = offset + SAMPLE_NAME_LENG
    local name = midiService:fromAkaiString(buf)
    table.insert(sampleNames, name)
  end
  return sampleNames
end


