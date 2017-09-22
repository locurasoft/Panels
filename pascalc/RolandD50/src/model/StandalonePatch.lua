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

  self.data = midiService:trimSyxData(patchData)
  self.patchOffset = 0
  assert(self.data:getSize() == Voice_singleSize, string.format("midiSize %d is invalid and cannot be assigned to controllers", self.data:getSize()))
end
