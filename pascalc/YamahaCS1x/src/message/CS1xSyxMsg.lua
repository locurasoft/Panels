require("SyxMsg")

D50SyxMsg = {}
D50SyxMsg.__index = D50SyxMsg

setmetatable(D50SyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function D50SyxMsg:_init(data)
  SyxMsg._init(self)
  self.data = data
end
