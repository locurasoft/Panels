local log = Logger("ProgramService")

__ProgramService = Object()

function __ProgramService:setProgramList(programList)
	self.programList = programList
end

function __ProgramService:storeProgParamEdit(phead)
	local program = self.programList:getActiveProgram()
	if program == nil then
		return
	end

	program:storeParamEdit(phead)
end

function __ProgramService:storeKgParamEdit(khead)
	local program = self.programList:getActiveProgram()
	if program == nil then
		return
	end
	local keyGroup = program:getActiveKeyGroup()
	keyGroup:storeParamEdit(khead)
end

function __ProgramService:getActiveKeyGroupMessage()
	local pIndex = self.programList:getActiveProgram()
	local kIndex = self.programList:getActiveKeyGroup()
	return self:getKeyGroupMessage(pIndex, kIndex)
end

function __ProgramService:getKeyGroupMessage(pIndex, kIndex)
	local program = self.programList[pIndex]
	local keyGroup = program:getKeyGroup(kIndex)
	return keyGroup:getKdata()
end

function __ProgramService:getActiveProgramMessagesList()
	local pIndex = self.programList:getActiveProgram()
	return self:getProgramMessagesList(pIndex)
end

function __ProgramService:getProgramMessagesList(pIndex)
	pIndex = pIndex or self.programList:getActiveProgram()
	local msgs = {}
	local program = self.programList[pIndex]
	table.insert(msgs, program:getPdata())

	local numKeyGroups = program:getNumKeyGroups()
	for i = 1, numKeyGroups do
		local keyGroup = program:getKeyGroup(i)
		table.insert(msgs, keyGroup:getKdata())
	end
	return msgs
end

function __ProgramService:loadProgramFromFile(filePath)
	local file = assert(io.open(filePath, "rb"))
	local data = file:read("*all")
	assert(file:close())

	local offset = 0
	local loadedProg = nil
	for i = 0,(data:getSize() - 1) do
		if data:getByte(i) == 0xF7 then
			-- Found end of sysex msg
			if i == PROGRAM_HEADER_SIZE then
				assert(loadedProg == nil, "Invalid Akai S2000 program file")
				local memBlock = MemoryBlock(PROGRAM_HEADER_SIZE, true)
				data:copyTo(memBlock, offset, PROGRAM_HEADER_SIZE)
				loadedProg = Program(Pdata(memBlock))
				offset = PROGRAM_HEADER_SIZE
			else
				assert(loadedProg ~= nil, "Could not find program header")
				assert(i - offset == KEY_GROUP_HEADER_SIZE, "Invalid key group size")
				local memBlock = MemoryBlock(KEY_GROUP_HEADER_SIZE, true)
				data:copyTo(memBlock, offset, i - offset)
				local kg = KeyGroup(Kdata(memBlock))
				loadedProg:addKeyGroup(kg)
				offset = i
			end
		end
	end
end

function __ProgramService:saveProgramToFolder(folderPath, pIndex)
	local msgs = self:getProgramMessagesList(pIndex)
	local program = self.programList:getProgram(pIndex)
	local progName = program:getName()
	local filePath = string.format("%s%s%s.syx", folderPath, pathseparator, progName)
	local file = assert(io.open(filePath, "wb"))
	for k,v in pairs(msgs) do
		file:write(v:toMidiMessage():getData())
	end
	assert(file:close())
end

function __ProgramService:saveProgramsToFolder(folderPath)
	local numPrograms = self.programList:getNumPrograms()
	if i < 1 then
		return "There are no programs to store..."
	end

	for i = 1, numPrograms do
		self:saveProgramToFile(folderPath, i)
	end
end

function __ProgramService:newProgram(programName, keyGroups)
	local prog = Program()
	prog:setName(programName)
	for k,v in pairs(keyGroups) do
		prog:addKeyGroup(v)
	end
	return prog
end

function __ProgramService:storParamEdit(indexGroup, headerOffs, values)
	local activeProg = self.programList:getActiveProgram()
	if activeProg ~= nil then
		if indexGroup == 0 then
			-- __Program param
			activeProg:setPdataByte(mod:getModulatorName(), values[1])
		else
			-- Key Group param
			local activeKg = activeProg:getActiveKeyGroup()
			activeKg:storeNibbles(mod:getModulatorName(), midiSrvc:toNibbles(values[1]))
		end
	end
end

function __ProgramService:toJson(programList)
	local numProgs = programList:getNumPrograms()
	for i = 1, numProgs do
		local prog = programList:getProgram(i)
	end
end

function ProgramService()
	return __ProgramService:new()
end
