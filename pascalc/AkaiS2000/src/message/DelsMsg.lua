require("SyxMsg")

DelsMsg = {}
DelsMsg.__index = DelsMsg

setmetatable(DelsMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DelsMsg:_init(sampleNumber)
  SyxMsg._init(self)
  local sb = mutils.d2b(sampleNumber, false)
  self.data = MemoryBlock(string.format("f0 47 00 14 48 %s f7", sb:toHexString(1)))
end
