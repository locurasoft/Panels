require("Dispatcher")
require("Logger")

local log = Logger("Sample")

Sample = {}
Sample.__index = Sample

setmetatable(Sample, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Sample:_init()
  Dispatcher._init(self)
  self.    name = sampleName
  self[LUA_CONTRUCTOR_NAME] = "Sample"
end

function Sample:setUpdating(updating)
  self.updating = updating
end

function Sample:isUpdating()
  return self.updating
end

function Sample:setName(name)
  self.name = name
end

function Sample:getName()
  return self.name
end

function Sample:setWaveform(waveform)
  self.waveform = waveform
end

function Sample:getWaveform()
  return self.waveform
end

function Sample:setTrimStart(trimStart)
  self.trimStart = trimStart
end

function Sample:getTrimStart()
  return self.trimStart
end

function Sample:setTrimEnd(trimEnd)
  self.trimEnd = trimEnd
end

function Sample:getTrimEnd()
  return self.trimEnd
end

function Sample:setLoopType(loopType)
  self.loopType = loopType
end

function Sample:getLoopType()
  return self.loopType
end

function Sample:setLoopTune(loopTune)
  self.loopTune = loopTune
end

function Sample:getLoopTune()
  return self.loopTune
end

function Sample:setLoopHold(loopHold)
  self.loopHold = loopHold
end

function Sample:getLoopHold()
  return self.loopHold
end

function Sample:setLoopStart(loopStart)
  self.loopStart = loopStart
end

function Sample:getLoopStart()
  return self.loopStart
end

function Sample:setLoopLength(loopLength)
  self.loopLength = loopLength
end

function Sample:getLoopLength()
  return self.loopLength
end

function Sample:setLoopCrossfade(loopCrossfade)
  self.loopCrossfade = loopCrossfade
end

function Sample:getLoopCrossfade()
  return self.loopCrossfade
end

function Sample:setTimestretch(timestretch)
  self.timestretch = timestretch
end

function Sample:getTimestretch()
  return self.timestretch
end

function Sample:setTimestretchCycleMode(timestretchCycleMode)
  self.timestretchCycleMode = timestretchCycleMode
end

function Sample:getTimestretchCycleMode()
  return self.timestretchCycleMode
end

function Sample:setTimestretchCycleTime(timestretchCycleTime)
  self.timestretchCycleTime = timestretchCycleTime
end

function Sample:getTimestretchCycleTime()
  return self.timestretchCycleTime
end

function Sample:setTimestretchType(timestretchType)
  self.timestretchType = timestretchType
end

function Sample:getTimestretchType()
  return self.timestretchType
end

function Sample:setTimestretchQuality(timestretchQuality)
  self.timestretchQuality = timestretchQuality
end

function Sample:getTimestretchQuality()
  return self.timestretchQuality
end

function Sample:setTimestretchCrossfade(timestretchCrossfade)
  self.timestretchCrossfade = timestretchCrossfade
end

function Sample:getTimestretchCrossfade()
  return self.timestretchCrossfade
end

function Sample:setResampleQuality(resampleQuality)
  self.resampleQuality = resampleQuality
end

function Sample:getResampleQuality()
  return self.resampleQuality
end

function Sample:setResampleBandwidth(resampleBandwidth)
  self.resampleBandwidth = resampleBandwidth
end

function Sample:getResampleBandwidth()
  return self.resampleBandwidth
end

function Sample:setReverse(reverse)
  self.reverse = reverse
end

function Sample:getReverse()
  return self.reverse
end

function Sample:setNormalize(normalize)
  self.normalize = normalize
end

function Sample:getNormalize()
  return self.normalize
end

function Sample:setPitch(pitch)
  self.pitch = pitch
end

function Sample:getPitch()
  return self.pitch
end
