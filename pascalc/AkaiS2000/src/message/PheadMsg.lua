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
  local pgm = mutils.d2n(progNbr)
  local headerOffsArray = mutils.d2b(headerOffset, false)
  local numBytesArray = mutils.d2n(valuesMemBlock:getSize() / 2)

  local memBlock = MemoryBlock(13 + valuesMemBlock:getSize(), true)
  memBlock:loadFromHexString(string.format("F0 47 00 28 48 %s 00 %s %s %s F7",
    pgm:toHexString(1), headerOffsArray:toHexString(1), numBytesArray:toHexString(1), valuesMemBlock:toHexString(1)))

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
