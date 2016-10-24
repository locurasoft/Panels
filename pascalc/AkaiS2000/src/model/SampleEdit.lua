require("Dispatcher")
require("Logger")

local log = Logger("SampleEdit")

SampleEdit = {}
SampleEdit.__index = SampleEdit

setmetatable(SampleEdit, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SampleEdit:_init()
  Dispatcher._init(self)
  self[LUA_CONTRUCTOR_NAME] = "SampleEdit"
end

function SampleEdit:setUpdating(updating)
  self.updating = updating
end

function SampleEdit:isUpdating()
  return self.updating
end

function SampleEdit:setName(name)
  self.name = name
end

function SampleEdit:getName()
  return self.name
end

function SampleEdit:setWaveform(waveform)
  self.waveform = waveform
end

function SampleEdit:getWaveform()
  return self.waveform
end

function SampleEdit:setTrimStart(trimStart)
  self.trimStart = trimStart
end

function SampleEdit:getTrimStart()
  return self.trimStart
end

function SampleEdit:setTrimEnd(trimEnd)
  self.trimEnd = trimEnd
end

function SampleEdit:getTrimEnd()
  return self.trimEnd
end

function SampleEdit:setLoopType(loopType)
  self.loopType = loopType
end

function SampleEdit:getLoopType()
  return self.loopType
end

function SampleEdit:setLoopTune(loopTune)
  self.loopTune = loopTune
end

function SampleEdit:getLoopTune()
  return self.loopTune
end

function SampleEdit:setLoopHold(loopHold)
  self.loopHold = loopHold
end

function SampleEdit:getLoopHold()
  return self.loopHold
end

function SampleEdit:setLoopStart(loopStart)
  self.loopStart = loopStart
end

function SampleEdit:getLoopStart()
  return self.loopStart
end

function SampleEdit:setLoopLength(loopLength)
  self.loopLength = loopLength
end

function SampleEdit:getLoopLength()
  return self.loopLength
end

function SampleEdit:setLoopCrossfade(loopCrossfade)
  self.loopCrossfade = loopCrossfade
end

function SampleEdit:getLoopCrossfade()
  return self.loopCrossfade
end

function SampleEdit:setTimestretch(timestretch)
  self.timestretch = timestretch
end

function SampleEdit:getTimestretch()
  return self.timestretch
end

function SampleEdit:setTimestretchCycleMode(timestretchCycleMode)
  self.timestretchCycleMode = timestretchCycleMode
end

function SampleEdit:getTimestretchCycleMode()
  return self.timestretchCycleMode
end

function SampleEdit:setTimestretchCycleTime(timestretchCycleTime)
  self.timestretchCycleTime = timestretchCycleTime
end

function SampleEdit:getTimestretchCycleTime()
  return self.timestretchCycleTime
end

function SampleEdit:setTimestretchType(timestretchType)
  self.timestretchType = timestretchType
end

function SampleEdit:getTimestretchType()
  return self.timestretchType
end

function SampleEdit:setTimestretchQuality(timestretchQuality)
  self.timestretchQuality = timestretchQuality
end

function SampleEdit:getTimestretchQuality()
  return self.timestretchQuality
end

function SampleEdit:setTimestretchCrossfade(timestretchCrossfade)
  self.timestretchCrossfade = timestretchCrossfade
end

function SampleEdit:getTimestretchCrossfade()
  return self.timestretchCrossfade
end

function SampleEdit:setResampleQuality(resampleQuality)
  self.resampleQuality = resampleQuality
end

function SampleEdit:getResampleQuality()
  return self.resampleQuality
end

function SampleEdit:setResampleBandwidth(resampleBandwidth)
  self.resampleBandwidth = resampleBandwidth
end

function SampleEdit:getResampleBandwidth()
  return self.resampleBandwidth
end

function SampleEdit:setReverse(reverse)
  self.reverse = reverse
end

function SampleEdit:getReverse()
  return self.reverse
end

function SampleEdit:setNormalize(normalize)
  self.normalize = normalize
end

function SampleEdit:getNormalize()
  return self.normalize
end

function SampleEdit:setPitch(pitch)
  self.pitch = pitch
end

function SampleEdit:getPitch()
  return self.pitch
end
