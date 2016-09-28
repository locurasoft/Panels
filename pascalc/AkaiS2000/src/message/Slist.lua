require("SyxMsg")

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
  local logger = Logger("SlistMsg")
  if bytes:getByte(3) == 0x05 then
    self.data = bytes
    self.log = logger
  else
    logger:info("Not a slist msg")
  end
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
    local name = midiSrvc:fromAkaiString(buf)
    --self.log:fine("Sample Name: %s", name)
    table.insert(sampleNames, name)
  end
  return sampleNames
end


