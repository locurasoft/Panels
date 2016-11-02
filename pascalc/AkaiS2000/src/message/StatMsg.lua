require("SyxMsg")

StatMsg = {}
StatMsg.__index = StatMsg

setmetatable(StatMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function StatMsg:_init(bytes)
  SyxMsg._init(self)
  assert(bytes:getSize() == 21 and bytes:getByte(3) == 0x01, "Invalid stat message")
  self.data = bytes
end

function StatMsg:getSwVersion()
  return string.format("%d.%d", self.data:getByte(6), self.data:getByte(5))
end

function StatMsg:getNumFreeWords()
  local result = 0
  for i = 15,18 do
    local offset = 128 ^ (i - 15)
    result = result + self.data:getByte(i) * offset
  end
  return result
end
