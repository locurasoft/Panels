require("model/EnsoniqEsq1Patch")

EnsoniqEsq1StandalonePatch = {}
EnsoniqEsq1StandalonePatch.__index = EnsoniqEsq1StandalonePatch

setmetatable(EnsoniqEsq1StandalonePatch, {
  __index = EnsoniqEsq1Patch, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function EnsoniqEsq1StandalonePatch:_init(patchData)
  EnsoniqEsq1Patch._init(self)

  assert(patchData:getSize() == PATCH_BUFFER_SIZE, string.format("midiSize %d is invalid and cannot be assigned to controllers", patchData:getSize()))
  self.data = patchData
  self.patchOffset = 5
end
