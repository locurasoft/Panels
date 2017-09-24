require("SyxMsg")

DX7SyxMsg = {}
DX7SyxMsg.__index = DX7SyxMsg

setmetatable(DX7SyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DX7SyxMsg:_init(data)
  SyxMsg._init(self)
  self.data = data
end
