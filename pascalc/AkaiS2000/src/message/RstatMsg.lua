require("SyxMsg")

RstatMsg = {}
RstatMsg.__index = RstatMsg

setmetatable(RstatMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RstatMsg:_init(bytes)
  SyxMsg._init(self)
  self.data = MemoryBlock({0xf0, 0x47, 0x00, 0x00, 0x48, 0xf7})
end
