require("SyxMsg")

AllUserPresetsRequest = {}
AllUserPresetsRequest.__index = AllUserPresetsRequest

setmetatable(AllUserPresetsRequest, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function AllUserPresetsRequest:_init()
  SyxMsg._init(self)
  self.data = MemoryBlock({ 0xF0, 0x18, 0x04, 0x00, 0x00, 0x7E, 0x7F, 0xF7 })
end
