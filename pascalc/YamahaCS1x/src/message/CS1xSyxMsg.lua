require("SyxMsg")

CS1xSyxMsg = {}
CS1xSyxMsg.__index = CS1xSyxMsg

setmetatable(CS1xSyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function CS1xSyxMsg:_init(data)
  SyxMsg._init(self)
  self.data = data
end
