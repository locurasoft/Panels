require("controller/AbstractS2kController")
require("Logger")

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

local NO_LOOPING_TYPE, LP_IN_RELEASE_TYPE, ONE_SHOT_TYPE = 0, 1, 2

SampleEditController = {}
SampleEditController.__index = SampleEditController

setmetatable(SampleEditController, {
  __index = AbstractS2kController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SampleEditController:_init()
  AbstractS2kController._init(self)
end

function SampleEditController:setSampleList(sampleList)
	sampleList:addListener(self, "updateSampleLists")
end

function SampleEditController:updateSampleEdit(sample, updateKnobs)

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
	self:setValue("trimStart", sample:getTrimStart())
	self:setValue("trimEnd", sample:getTrimEnd())

	if updateKnobs then
		self:setValue("sampleTrimStartKnob", sample:getTrimStart())
		self:setValue("sampleTrimEndKnob", sample:getTrimEnd())
	end

	--
	-- Update loop controls
	--

	panel:setGlobalVariable(2, sample:getLoopStart())
	panel:getComponent("sampleLoop"):repaint()

	if updateKnobs then
		self:setValue("sampleLoopType", sample:getLoopType())
		self:setValue("sampleLoopTune", sample:getLoopTune())
		self:setValue("sampleLoopHold", sample:getLoopHold())
		self:setValue("sampleLoopStartMod", sample:getLoopStart())
		self:setValue("sampleLoopLength", sample:getLoopLength())
		self:setValue("sampleCrossfade", sample:getLoopCrossfade())
	end

	--
	-- Update timestretch controls
	--
	self:toggleVisibility("sampleTimestrCyclicGrp", sample:getTimestretchType() ~= INTELL_TYPE)
	self:toggleVisibility("sampleTimestrIntellGrp", sample:getTimestretchType() == INTELL_TYPE)

	if updateKnobs then
		self:setValue("stretch", sample:getTimestretch())
		self:setValue("sampleTimestretchType", sample:getTimestretchType())
		self:setValue("sampleTimestretchQuality", sample:getTimestretchQuality())
		self:setValue("sampleTimestretchXfd", sample:setTimestretchCrossfade())
		self:setValue("sampleTimestretchCycleAuto", sample:getTimestretchCycleMode())
		self:setText("sampleTimestretchCyclicTime", sample:getTimestretchCycleTime())
	end

	--
	-- Update resample controls
	--
	if updateKnobs then
		self:setValue("sampleResampleQuality", sample:getResampleQuality())
		self:setValue("sampleResampleBandwidth", sample:getResampleBandwidth())
	end

	--
	-- Update waveform controls
	--
	if sample:getWaveform() == nil then
		self:setText("editWaveformPathLbl", "Select a wav file...")
	else
		self:setText("editWaveformPathLbl", sample:getWaveform():getFullPath())
		panel:getWaveformComponent("waveEditor"):loadFromFile(sample:getWaveform())
	end

	--
	-- Update file controls
	--
	self:setText("sampleName", sample:getName())
	rotate("trimEnd", true)
	rotate("waveEditor", sample:getReverse())
	if updateKnobs then
		self:setValue("samplePitch", sample:getPitch())
	end

	-- Done updating knobs
	if updateKnobs then
		sample:setUpdating(false)
	end
end
