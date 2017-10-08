require("SyxMsg")

DelpMsg = {}
DelpMsg.__index = DelpMsg

setmetatable(DelpMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DelpMsg:_init(programNumber)
  SyxMsg._init(self)
  local pb = mutils.d2b(programNumber, false)
  self.data = MemoryBlock(string.format("f0 47 00 12 48 %s f7", pb:toHexString(1)))
end
