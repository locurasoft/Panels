require("Dispatcher")
require("Logger")

local log = Logger("DrumMapSelectedSample")

DrumMapSelectedSample = {}
DrumMapSelectedSample.__index = DrumMapSelectedSample

setmetatable(DrumMapSelectedSample, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DrumMapSelectedSample:_init()
  Dispatcher._init(self)

  self.selectedSample = nil
  self.selectedFile = nil
  self.useSample = true

  self[LUA_CONTRUCTOR_NAME] = "DrumMapSelectedSample"
end

function DrumMapSelectedSample:setSample(sample)
  if type(sample) == "string" and self.useSample then
    self.selectedSample = sample
  elseif type(sample) ~= "string" and not self.useSample then
    self.selectedFile = sample
  else
    assert(false, "Invalid sample selection state")
  end
  self:notifyListeners()
end

function DrumMapSelectedSample:getSample()
  if self.useSample then
    return self.selectedSample
  else
    return self.selectedFile
  end
end

function DrumMapSelectedSample:setUseSample(useSample)
  self.useSample = useSample
  self:notifyListeners()
end
