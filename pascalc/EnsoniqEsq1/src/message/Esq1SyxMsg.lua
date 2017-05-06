require("SyxMsg")

Esq1SyxMsg = {}
Esq1SyxMsg.__index = Esq1SyxMsg

setmetatable(Esq1SyxMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Esq1SyxMsg:_init(data)
  SyxMsg._init(self)
  self.data = data
end
