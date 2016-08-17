
local log = Logger("ProgramController")

__ProgramController = AbstractController()

function __ProgramController:setProgramList(programList)
	local programListListener = function(pl)
		self:updateProgramList(pl)
	end
	programList:addListener(programListListener)
end

function __ProgramController:updateTuneLabel(modName, semi, cent)
	self:setText(string.format("%s-LBL", modName), string.format("%02d.%02d", semi, cent))
end

function __ProgramController:updateProgramList(pl)
	-- update program and keygroup selectors
	local numPrograms = pl:getNumPrograms()
	if numPrograms < 1 then
		self:toggleActivation("programSelector", false)
		self:setText("PRNAME", "Please load a program")
		return
	end

	log:fine("Setting program selector max to %s", numPrograms)
	self:setMax("programSelector", numPrograms)
	local activeProgram = pl:getActiveProgram()
	if activeProgram == nil then
		self:setText("PRNAME", "")
		log:info("Active program is nil!")
	else
		log:info("Found active program!")
		self:changeProgram(activeProgram)
	end
end

function __ProgramController:changeProgram(newProgram)
	if self.activeProgram ~= nil then
		self.activeProgram:removeListener(self.programListenerId)
	end
	local programListener = function(p)
		self:updateProgram(p)
	end
	self.programListenerId = newProgram:addListener(programListener)
	self.activeProgram = newProgram
	self:assignProgramValues(newProgram)
end

function __ProgramController:changeKeyGroup(keyGroupIndex)
	if self.activeProgram == nil then
		log:warn("Active program is nil! Disabling kg selector.")
		self:toggleActivation("kgSelector", false)
	else
		--log:info("Before kg change: %s", self.activeProgram:getActiveKeyGroup():toString())
		self.activeProgram:setActiveKeyGroupIndex(keyGroupIndex)
		self:assignKeyGroupValues(self.activeProgram, self.activeProgram:getActiveKeyGroupIndex())
		--log:info("After kg change: %s", self.activeProgram:getActiveKeyGroup():toString())
	end
end

function __ProgramController:assignProgramValues(program)
	program:setUpdating(true)
	--log:info("Active program name: %s", program:getName())
	self:setText("PRNAME", program:getName())
	self:toggleActivation("kgSelector", true)
	self:setMax("kgSelector", program:getNumKeyGroups())
	local currKg = self:getValue("kgSelector")
	if program:getActiveKeyGroupIndex() == currKg then
		self:assignKeyGroupValues(self.activeProgram, self.activeProgram:getActiveKeyGroupIndex())
	else
		self:setValue("kgSelector", program:getActiveKeyGroupIndex())
	end
	for k,v in pairs(programBlock) do
		local mod = panel:getModulatorByName(k)
		if mod ~= nil then
			local value = program:getParamValue(k)
			if type(value) == "string" then
				mod:getComponent():setText(value)
			else
				local absValue = value + mod:getMinNonMapped()
				--log:info("Setting prog modulator %s to %d (%d)", k, absValue, value)
				mod:setValue(absValue, true)
			end
		end
	end
	program:setUpdating(false)
end

function __ProgramController:assignKeyGroupValues(program, kgIndex)
	local keyGroup = program:getKeyGroup(kgIndex)

	-- TODO: Why is this necessary?
	if keyGroup == nil then
		return
	end
	keyGroup:setUpdating(true)
	--log:info("Updating keyGroup %d", kgIndex)
	for k,zone in pairs(keyGroup:getZones()) do
		local sampleName = zone:getSampleName()
		local selector = string.format("zone%dSelector", k)
		--log:info("Setting sample %s to %s", sampleName, selector)
		panel:getComponent(selector):setText(sampleName, true)
	end

	for k,v in pairs(keyGroupBlock) do
		local mod = panel:getModulatorByName(k)
		if mod ~= nil then
			local value = keyGroup:getParamValue(k)
			local minValue = mod:getMinNonMapped()
			local absValue = value + minValue
			if math.abs(minValue) > 256 then
				absValue = value
			end
			
			--log:info("Setting kg modulator %s to %d (%d)", k, absValue, value)
			mod:setValue(absValue, true)
		end
	end
	keyGroup:setUpdating(false)
end

function ProgramController()
	return __ProgramController:new()
end
