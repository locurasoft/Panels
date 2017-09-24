require("SyxMsg")

ButtonPressSyxMsg = {}
ButtonPressSyxMsg.__index = ButtonPressSyxMsg

setmetatable(ButtonPressSyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ButtonPressSyxMsg:_init(btnIndex)
  SyxMsg._init(self)
  self.data = MemoryBlock({0xf0, 0x43, 0x10, 0x08, btnIndex, 0x7f, 0xf7})
end
