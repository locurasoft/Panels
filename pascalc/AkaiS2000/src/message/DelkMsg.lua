require("SyxMsg")

DelkMsg = {}
DelkMsg.__index = DelkMsg

setmetatable(DelkMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DelkMsg:_init(programNumber, kgNumber)
  SyxMsg._init(self)
  local pb = mutils.d2b(programNumber)
  self.data = MemoryBlock({0xf0, 0x47, 0x00, 0x13, 0x48, pb[1], pb[2], kgNumber, 0xf7})
end
