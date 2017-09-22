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

  assert(patchData:getSize() == PATCH_BUFFER_SIZE, string.format("midiSize %d is invalid and cannot be assigned to controllers", patchData:getSize()))
  self.data = patchData
  self.patchOffset = 5
end
