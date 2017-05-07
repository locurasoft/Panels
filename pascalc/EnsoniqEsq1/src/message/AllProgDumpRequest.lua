require("SyxMsg")

AllProgDumpRequest = {}
AllProgDumpRequest.__index = AllProgDumpRequest

setmetatable(AllProgDumpRequest, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function AllProgDumpRequest:_init()
  SyxMsg._init(self)
  self.data = MemoryBlock({0xF0, 0x0F, 0x02, 0x00, 0x0A, 0xF7})
end
