require("SyxMsg")

DelsMsg = {}
DelsMsg.__index = DelsMsg

setmetatable(DelsMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DelsMsg:_init(sampleNumber)
  SyxMsg._init(self)
  local sb = midiSrvc:splitBytes(sampleNumber)
  self.data = {0xf0, 0x47, 0x00, 0x14, 0x48, sb[1], sb[2], 0xf7}
end
