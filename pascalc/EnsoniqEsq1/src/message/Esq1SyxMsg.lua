require("SyxMsg")

-- , 0x01
local END_OF_EXCL = MemoryBlock({ 0xF7 })
local END_OF_EXCL_SIZE = END_OF_EXCL:getSize()


Esq1SyxMsg = {}
Esq1SyxMsg.__index = Esq1SyxMsg

setmetatable(Esq1SyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Esq1SyxMsg:_init(msgCode, dataSize)
  SyxMsg._init(self)
  self.data = MemoryBlock(HEADER_SIZE + 1 + dataSize + END_OF_EXCL_SIZE, true)
  self.data:copyFrom(ESQ1_EXCL_HEADER, 0, HEADER_SIZE)
  self.data:setByte(HEADER_SIZE, msgCode)
  self.data:copyFrom(END_OF_EXCL, self.data:getSize() - 1, END_OF_EXCL_SIZE)
end

function Esq1SyxMsg:setPayload(payload)
  payload:copyTo(self.data, HEADER_SIZE + 1, payload:getSize())
end