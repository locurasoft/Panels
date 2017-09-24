require("model/RolandD50Patch")

RolandD50StandalonePatch = {}
RolandD50StandalonePatch.__index = RolandD50StandalonePatch

setmetatable(RolandD50StandalonePatch, {
  __index = RolandD50Patch, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RolandD50StandalonePatch:_init(patchData)
  RolandD50Patch._init(self)

  self.data = midiService:trimSyxData(patchData)
  self.patchOffset = 0
  assert(self.data:getSize() == Voice_singleSize, string.format("midiSize %d is invalid and cannot be assigned to controllers", self.data:getSize()))
end
