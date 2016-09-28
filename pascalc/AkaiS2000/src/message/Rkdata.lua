require("SyxMsg")

RkdataMsg = {}
RkdataMsg.__index = RkdataMsg

setmetatable(RkdataMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RkdataMsg:_init(programNumber, kgNumber)
  SyxMsg._init(self)
  local pb = midiSrvc:splitBytes(programNumber)
  local bytes = {0xf0, 0x47, 0x00, 0x08, 0x48, pb[1], pb[2], kgNumber, 0xf7}
  self.data = bytes
end
