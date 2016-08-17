local log = Logger("ProgramList")

__ProgramList = Dispatcher()

function __ProgramList:getNumPrograms()
	return table.getn(self.list)
end

function __ProgramList:getProgram(index)
	return self.list[index]
end

function __ProgramList:addProgram(program)
	table.insert(self.list, program)
	self:notifyListeners()
end

function __ProgramList:removeProgram(index)
	table.remove(self.list, index)
	self:notifyListeners()
end

function __ProgramList:activateProgram(index)
	self.activeProgram = index
	self:notifyListeners()
end

function __ProgramList:getActiveProgram()
	log:fine("[getActiveProgram] Active program %d", self.activeProgram)
	if self.activeProgram <= 0 then
		return nil
	else
		return self.list[self.activeProgram]
	end
end

function __ProgramList:setActiveProgram(activeProgNum)
	--log:fine("Active program before %d", self.activeProgram)
	self.activeProgram = activeProgNum
	--log:fine("Active program after %d", self.activeProgram)
	self:notifyListeners()
end

function __ProgramList:hasProgram(programName)
	for k,program in pairs(self.list) do
		if program:getName() == programName then
			return true
		end
	end
	return false
end

function ProgramList(data)
	return __ProgramList:new {
		activeProgram = -1,
		list = {},
		[LUA_CLASS_NAME] = "ProgramList"
	}
end
