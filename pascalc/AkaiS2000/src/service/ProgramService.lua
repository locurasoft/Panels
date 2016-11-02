require("LuaObject")
require("Logger")
require("model/Program")

local log = Logger("ProgramService")

PROG_TUNE, PROG_STRING, PROG_DEFAULT = 0, 1, 2
KG_TUNE, KG_STRING, KG_DEFAULT, KG_VSS = 3, 4, 5, 6

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

function ProgramService:khead(program, blockType, blockName, value)
  local prog = program:getProgramNumber()
  local kg = program:getActiveKeyGroupIndex()
  
  local offset = KEY_GROUP_BLOCK[blockName]
  local valueBlock = -1
  if blockType == KG_DEFAULT then
    valueBlock = midiService:toDefaultBlock(value)
  elseif blockType == KG_STRING then
    valueBlock = midiService:toStringBlock(value)
  elseif blockType == KG_TUNE then
    valueBlock = midiService:toTuneBlock(value)
  elseif blockType == KG_VSS then
    valueBlock = midiService:toVssBlock(value)
  else
    assert(false, "Invalid keygroup modulator type " .. blockType)
  end
  
  return KheadMsg(prog, kg, offset, valueBlock)
end

function ProgramService:phead(program, blockType, blockName, value)
  local prog = program:getProgramNumber()
  local offset = PROGRAM_BLOCK[blockName]
  local valueBlock = -1
  if blockType == PROG_DEFAULT then
    valueBlock = midiService:toDefaultBlock(value)
  elseif blockType == PROG_STRING then
    valueBlock = midiService:toStringBlock(value)
  elseif blockType == PROG_TUNE then
    valueBlock = midiService:toTuneBlock(value)
  else
    assert(false, "Invalid program modulator type " .. blockType)
  end
  
  return PheadMsg(prog, offset, valueBlock)
end