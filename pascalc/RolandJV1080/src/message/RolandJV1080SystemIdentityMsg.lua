require("SyxMsg")

RolandJV1080SystemIdentityMsg = {}
RolandJV1080SystemIdentityMsg.__index = RolandJV1080SystemIdentityMsg

setmetatable(RolandJV1080SystemIdentityMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RolandJV1080SystemIdentityMsg:_init()
  SyxMsg._init(self)
  self.data = {0xf0, 0x7E, 0x10, 0x06, 0x01, 0xF7}
end
