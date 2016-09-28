require("SyxMsg")

RplistMsg = {}
RplistMsg.__index = RplistMsg

setmetatable(RplistMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RplistMsg:_init()
  SyxMsg._init(self)
  self.data = {0xf0, 0x47, 0x00, 0x02, 0x48, 0xf7}
end
