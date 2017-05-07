require("SyxMsg")

SingleProgDumpRequest = {}
SingleProgDumpRequest.__index = SingleProgDumpRequest

setmetatable(SingleProgDumpRequest, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SingleProgDumpRequest:_init()
  SyxMsg._init(self)
  self.data = MemoryBlock({0xF0, 0x0F, 0x02, 0x00, 0x09, 0xF7})
end
