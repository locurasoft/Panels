require("SyxMsg")

PheadMsg = {}
PheadMsg.__index = PheadMsg

setmetatable(PheadMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function PheadMsg:_init(progNbr, headerOffset, valuesMemBlock)
  SyxMsg._init(self)
  local pgm = midiService:toNibbles(progNbr)
  local headerOffsArray = midiService:splitBytes(headerOffset)
  local numBytesArray = midiService:splitBytes(valuesMemBlock:getSize())

  local memBlock = MemoryBlock(13 + valuesMemBlock:getSize(), true)
  memBlock:loadFromHexString(string.format("F0 47 00 28 48 %s 0x00 %.2x %.2x %.2x %.2x%s F7",
    pgm:toHexString(1), headerOffsArray[1], headerOffsArray[2],
    numBytesArray[1], numBytesArray[2], valuesMemBlock:toHexString(1)))

  self.data = memBlock
  self.offset = headerOffset
  self.valBlock = valuesMemBlock
end

function PheadMsg:getOffset()
  return self.offset
end

function PheadMsg:getValueBlock()
  return self.valBlock
end
