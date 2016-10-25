require("LuaObject")
require("Logger")
require("model/Program")

local log = Logger("ProgramService")

ProgramService = {}
ProgramService.__index = ProgramService

setmetatable(ProgramService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ProgramService:_init()
  LuaObject._init(self)
end

function ProgramService:getProgramMessagesList(program)
	local msgs = {}
	table.insert(msgs, program:getPdata())

	local numKeyGroups = program:getNumKeyGroups()
	for i = 1, numKeyGroups do
		local keyGroup = program:getKeyGroup(i)
		table.insert(msgs, keyGroup:getKdata())
	end
	return msgs
end

function ProgramService:loadProgramFromFile(filePath)
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

function ProgramService:saveProgramToFolder(folderPath, program)
	local msgs = self:getProgramMessagesList(program)
	local progName = program:getName()
	local filePath = cutils.toFilePath(folderPath, string.format("%s.syx", progName))
	local file = assert(io.open(filePath, "wb"))
	for k,v in pairs(msgs) do
		file:write(v:toMidiMessage():getData())
	end
	assert(file:close())
end

function ProgramService:saveProgramsToFolder(folderPath, programList)
	local numPrograms = programList:getNumPrograms()
	assert(numPrograms > 0, "There are no programs to store...")

	for i = 1, numPrograms do
		self:saveProgramToFile(folderPath, programList:getProgram(i))
	end
end

function ProgramService:newProgram(programName, keyGroups)
	local prog = Program()
	prog:setName(programName)
	for k,v in pairs(keyGroups) do
		prog:addKeyGroup(v)
	end
	return prog
end
