require("SyxMsg")

ButtonReleaseSyxMsg = {}
ButtonReleaseSyxMsg.__index = ButtonReleaseSyxMsg

setmetatable(ButtonReleaseSyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ButtonReleaseSyxMsg:_init(btnIndex)
  SyxMsg._init(self)
  self.data = MemoryBlock({0xf0, 0x43, 0x10, 0x08, btnIndex, 0x00, 0xf7})
end
