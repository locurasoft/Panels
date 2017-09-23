require("SyxMsg")

AllFactoryPresetsRequest = {}
AllFactoryPresetsRequest.__index = AllFactoryPresetsRequest

setmetatable(AllFactoryPresetsRequest, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function AllFactoryPresetsRequest:_init()
  SyxMsg._init(self)
  self.data = MemoryBlock({ 0xF0, 0x18, 0x04, 0x00, 0x00, 0x7F, 0x7F, 0xF7 })
end
