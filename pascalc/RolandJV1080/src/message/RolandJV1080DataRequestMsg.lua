require("SyxMsg")

RolandJV1080DataRequestMsg = {}
RolandJV1080DataRequestMsg.__index = RolandJV1080DataRequestMsg

local CS_END = 12
local CS_OFFS = 13

setmetatable(RolandJV1080DataRequestMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RolandJV1080DataRequestMsg:_init(patchOffset, length)
  SyxMsg._init(self)
  self.data = MemoryBlock({ 0xf0, 0x41, 0x10, 0x6A, 0x11, 0x03, 0x00, patchOffset, 0x00, 0x00, 0x00, 0x00, length, 0, 0xf7 })
  local checksum = midiService:calculateChecksum(self.data, CS_END)
  self.data:setByte(CS_OFFS, checksum)
end
