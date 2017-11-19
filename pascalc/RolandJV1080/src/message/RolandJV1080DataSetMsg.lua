require("SyxMsg")

-- Roland system exclusive data set.
-- Not used very much so far (only writing the mode change to patch mode)
RolandJV1080DataSetMsg = {}
RolandJV1080DataSetMsg.__index = RolandJV1080DataSetMsg

local CS_END = 9
local CS_OFFS = 10

setmetatable(RolandJV1080DataSetMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RolandJV1080DataSetMsg:_init()
  SyxMsg._init(self)
  self.data = { 0xf0, 0x41, 0x10, 0x6A, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0, 0xf7 }
  local checksum = midiService:calculateChecksum(self.data, CS_END)
  self.data:setByte(CS_OFFS, checksum)
end
