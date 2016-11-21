require("SyxMsg")

RkdataMsg = {}
RkdataMsg.__index = RkdataMsg

setmetatable(RkdataMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RkdataMsg:_init(programNumber, kgNumber)
  SyxMsg._init(self)
  local pb = mutils.d2b(programNumber)
  self.data = MemoryBlock(string.format("f0 47 00 08 48 %s %.2x f7", pb:toHexString(1), kgNumber))
end
