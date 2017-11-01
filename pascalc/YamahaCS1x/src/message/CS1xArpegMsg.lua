require("SyxMsg")

CS1xArpegMsg = {}
CS1xArpegMsg.__index = CS1xArpegMsg

setmetatable(CS1xArpegMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function CS1xArpegMsg:_init(value)
  SyxMsg._init(self)
  self.data = MemoryBlock(string.format("F0 43 10 4B 60 00 2D %.2X F7", value))
end
