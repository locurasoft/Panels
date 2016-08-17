
local rotate = function(compName, rot)
	local timesPi = 0
	if rot then
		timesPi = 1
	end
	local c = panel:getComponent(compName)
	local x = c:getX()+c:getWidth()/2
	local y = c:getY()+c:getHeight()/2
	transform = AffineTransform.rotation(timesPi * 3.1415926536, x, y)
		
	if transform:isSingularity() ~= true then
		c:setTransform (transform)
	end
end

__SampleController = AbstractController()

function __SampleController:setSampleList(sampleList)
	local sampleListListener = function(sl)
		self:updateSampleLists(sl)
	end
	sampleList:addListener(sampleListListener)
end

function __SampleController:updateSampleEdit(sample, updateKnobs)

	-- Avoid infinite loops
	updateKnobs = updateKnobs or false
	if sample:isUpdating() then
		return
	elseif updateKnobs then
		sample:setUpdating(true)
	end
	
	--
	-- Update trim controls
	--
	setValue("trimStart", sample:getTrimStart())
	setValue("trimEnd", sample:getTrimEnd())

	if updateKnobs then
		setValue("sampleTrimStartKnob", sample:getTrimStart())
		setValue("sampleTrimEndKnob", sample:getTrimEnd())
	end

	--
	-- Update loop controls
	--

	panel:setGlobalVariable(2, sample:getLoopStart())
	panel:getComponent("sampleLoop"):repaint()

	if updateKnobs then
		setValue("sampleLoopType", sample:getLoopType())
		setValue("sampleLoopTune", sample:getLoopTune())
		setValue("sampleLoopHold", sample:getLoopHold())
		setValue("sampleLoopStartMod", sample:getLoopStart())
		setValue("sampleLoopLength", sample:getLoopLength())
		setValue("sampleCrossfade", sample:getLoopCrossfade())
	end

	--
	-- Update timestretch controls
	--
	toggleVisibility("sampleTimestrCyclicGrp", sample:getTimestretchType() ~= INTELL_TYPE)
	toggleVisibility("sampleTimestrIntellGrp", sample:getTimestretchType() == INTELL_TYPE)

	if updateKnobs then
		setValue("stretch", sample:getTimestretch())
		setValue("sampleTimestretchType", sample:getTimestretchType())
		setValue("sampleTimestretchQuality", sample:getTimestretchQuality())
		setValue("sampleTimestretchXfd", sample:setTimestretchCrossfade())
		setValue("sampleTimestretchCycleAuto", sample:getTimestretchCycleMode())
		setText("sampleTimestretchCyclicTime", sample:getTimestretchCycleTime())
	end

	--
	-- Update resample controls
	--
	if updateKnobs then
		setValue("sampleResampleQuality", sample:getResampleQuality())
		setValue("sampleResampleBandwidth", sample:getResampleBandwidth())
	end

	--
	-- Update waveform controls
	--
	if sample:getWaveform() == nil then
		setText("editWaveformPathLbl", "Select a wav file...")
	else
		setText("editWaveformPathLbl", sample:getWaveform():getFullPath())
		panel:getWaveformComponent("waveEditor"):loadFromFile(sample:getWaveform())
	end

	--
	-- Update file controls
	--
	setText("sampleName", sample:getName())
	rotate("trimEnd", true)
	rotate("waveEditor", sample:getReverse())
	if updateKnobs then
		setValue("samplePitch", sample:getPitch())
	end

	-- Done updating knobs
	if updateKnobs then
		sample:setUpdating(false)
	end
end

function SampleController()
	return __SampleController:new()
end
