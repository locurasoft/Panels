require("SyxMsg")

CS1xReceiveMsg = {}
CS1xReceiveMsg.__index = CS1xReceiveMsg

setmetatable(CS1xReceiveMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function CS1xReceiveMsg:_init(cS1xReceiveMsgType)
  SyxMsg._init(self)

  self.data = { 0xF0, 0x43, 0x20, 0x4B, 0x60, 0x00, 0x00, 0xF7 }
  
  if cS1xReceiveMsgType == COMMON_1 then
    table.insert(self.data, 7, 0x30)
  elseif cS1xReceiveMsgType == COMMON_2 then
    table.insert(self.data, 7, 0x50)
  elseif cS1xReceiveMsgType == LAYER1 then
    table.insert(self.data, 6, 0x01)
  elseif cS1xReceiveMsgType == LAYER2 then
    table.insert(self.data, 6, 0x02)
  elseif cS1xReceiveMsgType == LAYER3 then
    table.insert(self.data, 6, 0x03)
  elseif cS1xReceiveMsgType == LAYER4 then
    table.insert(self.data, 6, 0x04)
  end
end
