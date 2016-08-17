local log = Logger("Sample")

__Sample = Dispatcher()

function __Sample:setUpdating(updating)
	self.updating = updating
end

function __Sample:isUpdating()
	return self.updating
end

function __Sample:setName(name)
	self.name = name
end

function __Sample:getName()
	return self.name
end

function __Sample:setWaveform(waveform)
	self.waveform = waveform
end

function __Sample:getWaveform()
	return self.waveform
end

function __Sample:setTrimStart(trimStart)
	self.trimStart = trimStart
end

function __Sample:getTrimStart()
	return self.trimStart
end

function __Sample:setTrimEnd(trimEnd)
	self.trimEnd = trimEnd
end

function __Sample:getTrimEnd()
	return self.trimEnd
end

function __Sample:setLoopType(loopType)
	self.loopType = loopType
end

function __Sample:getLoopType()
	return self.loopType
end

function __Sample:setLoopTune(loopTune)
	self.loopTune = loopTune
end

function __Sample:getLoopTune()
	return self.loopTune
end

function __Sample:setLoopHold(loopHold)
	self.loopHold = loopHold
end

function __Sample:getLoopHold()
	return self.loopHold
end

function __Sample:setLoopStart(loopStart)
	self.loopStart = loopStart
end

function __Sample:getLoopStart()
	return self.loopStart
end

function __Sample:setLoopLength(loopLength)
	self.loopLength = loopLength
end

function __Sample:getLoopLength()
	return self.loopLength
end

function __Sample:setLoopCrossfade(loopCrossfade)
	self.loopCrossfade = loopCrossfade
end

function __Sample:getLoopCrossfade()
	return self.loopCrossfade
end

function __Sample:setTimestretch(timestretch)
	self.timestretch = timestretch
end

function __Sample:getTimestretch()
	return self.timestretch
end

function __Sample:setTimestretchCycleMode(timestretchCycleMode)
	self.timestretchCycleMode = timestretchCycleMode
end

function __Sample:getTimestretchCycleMode()
	return self.timestretchCycleMode
end

function __Sample:setTimestretchCycleTime(timestretchCycleTime)
	self.timestretchCycleTime = timestretchCycleTime
end

function __Sample:getTimestretchCycleTime()
	return self.timestretchCycleTime
end

function __Sample:setTimestretchType(timestretchType)
	self.timestretchType = timestretchType
end

function __Sample:getTimestretchType()
	return self.timestretchType
end

function __Sample:setTimestretchQuality(timestretchQuality)
	self.timestretchQuality = timestretchQuality
end

function __Sample:getTimestretchQuality()
	return self.timestretchQuality
end

function __Sample:setTimestretchCrossfade(timestretchCrossfade)
	self.timestretchCrossfade = timestretchCrossfade
end

function __Sample:getTimestretchCrossfade()
	return self.timestretchCrossfade
end

function __Sample:setResampleQuality(resampleQuality)
	self.resampleQuality = resampleQuality
end

function __Sample:getResampleQuality()
	return self.resampleQuality
end

function __Sample:setResampleBandwidth(resampleBandwidth)
	self.resampleBandwidth = resampleBandwidth
end

function __Sample:getResampleBandwidth()
	return self.resampleBandwidth
end

function __Sample:setReverse(reverse)
	self.reverse = reverse
end

function __Sample:getReverse()
	return self.reverse
end

function __Sample:setNormalize(normalize)
	self.normalize = normalize
end

function __Sample:getNormalize()
	return self.normalize
end

function __Sample:setPitch(pitch)
	self.pitch = pitch
end

function __Sample:getPitch()
	return self.pitch
end

function Sample(sampleName)
	return __Sample:new{ 
		name = sampleName,
		[LUA_CLASS_NAME] = "Sample"
	}
end
