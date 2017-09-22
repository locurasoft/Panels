require("model/Patch")

StandalonePatch = {}
StandalonePatch.__index = StandalonePatch

setmetatable(StandalonePatch, {
  __index = Patch, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function StandalonePatch:_init(patchData)
  Patch._init(self)

  assert(patchData:getSize() == SINGLE_DATA_SIZE, string.format("midiSize %d is invalid and cannot be assigned to controllers", patchData:getSize()))
--    -- Set header and footer
--  patch:copyFrom(Voice_Header, 0, Voice_HeaderSize)
--  patch:copyFrom(Voice_Footer, Voice_singleSize - 2, Voice_FooterSize)
  
  self.data = patchData
  self.patchOffset = 0
end
