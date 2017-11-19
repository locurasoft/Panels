require("SyxMsg")

GMSystemOffMsg = {}
GMSystemOffMsg.__index = GMSystemOffMsg

setmetatable(GMSystemOffMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function GMSystemOffMsg:_init()
  SyxMsg._init(self)
  self.data = {0xf0, 0x7E, 0x7F, 0x09, 0x02, 0xF7}
end
