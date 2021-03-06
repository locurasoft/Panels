require("SyxMsg")

KheadMsg = {}
KheadMsg.__index = KheadMsg

setmetatable(KheadMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function KheadMsg:_init(prog, kg, headerOffset, valuesMemBlock)
  SyxMsg._init(self)
  local pgm = mutils.d2n(prog)
  local headerOffsArray = mutils.d2b(headerOffset, false)
  local numBytesArray = mutils.d2n(valuesMemBlock:getSize() / 2)

  local memBlock = MemoryBlock(13 + valuesMemBlock:getSize(), true)
  memBlock:loadFromHexString(string.format("F0 47 00 2A 48 %s %.2x %s %s %s F7",
    pgm:toHexString(1), kg, headerOffsArray:toHexString(1), numBytesArray:toHexString(1), valuesMemBlock:toHexString(1)))

  self.data = memBlock
  self.offset = headerOffset 
  self.valBlock = valuesMemBlock 
end

function KheadMsg:getOffset()
	return self.offset
end

function KheadMsg:getValueBlock()
	return self.valBlock
end
