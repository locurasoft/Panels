require("SyxMsg")

RslistMsg = {}
RslistMsg.__index = RslistMsg

setmetatable(RslistMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RslistMsg:_init()
  SyxMsg._init(self)
  self.data = {0xf0, 0x47, 0x00, 0x04, 0x48, 0xf7}
end
