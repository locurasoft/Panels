require("SyxMsg")

Proteus2SyxMsg = {}
Proteus2SyxMsg.__index = Proteus2SyxMsg

setmetatable(Proteus2SyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Proteus2SyxMsg:_init(data)
  SyxMsg._init(self)
  self.data = data
end
