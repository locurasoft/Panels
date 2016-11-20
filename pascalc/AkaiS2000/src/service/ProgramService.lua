require("LuaObject")
require("Logger")
require("model/Program")
require("message/KheadMsg")
require("message/PheadMsg")

local log = Logger("ProgramService")

local absoluteValueParams = {
  ["VSS1"] = true,
  ["VSS2"] = true,
  ["VSS3"] = true,
  ["VSS4"] = true,
  ["VTUNO1"] = true,
  ["VTUNO2"] = true,
  ["VTUNO3"] = true,
  ["VTUNO4"] = true,
  ["PTUNO"] = true
}

local cloneKeyGroup = function(origKg)
  local kg = KeyGroup()
  for origKey, origValue in pairs(origKg) do
    if origKey == "kdata" then
      local hexData = origValue.data:toHexString(1)
      kg[origKey] = KdataMsg(MemoryBlock(hexData))
    else
      kg[origKey] = origValue
    end
  end

  local zones = origKg:getZones()
  for i = 1, 4 do
    local zone = zones[i]
    if zone ~= nil then
      kg["kdata"]:storeNibbles(string.format("VLOUD%d", i), mutils.d2n(63))
      if zone:isLeftSample() then
        kg["kdata"]:storeNibbles(string.format("VPANO%d", i), mutils.d2n(0))
      elseif zone:isRightSample() then
        kg["kdata"]:storeNibbles(string.format("VPANO%d", i), mutils.d2n(100))
      end
    end
  end

  return kg
end

PROG_TUNE, PROG_STRING, PROG_DEFAULT = 0, 1, 2
KG_TUNE, KG_STRING, KG_DEFAULT, KG_VSS, KG_FILQ = 3, 4, 5, 6, 7

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

function ProgramService:addNewProgram(programList, drumMap)
  local programName = drumMap:getProgramName()

  assert(programName ~= nil and programName ~= "", "Please provide program name...")
  assert(not programList:hasProgram(programName), "Program already exists...")
  assert(drumMap:hasLoadedAllSamples(), "You cannot create a program with unloaded samples...")

  local program = Program()
  program:setName(programName)
  for k,v in pairs(drumMap:getKeyGroups()) do
    program:addKeyGroup(cloneKeyGroup(v))
  end
  programList:addProgram(program)
  return program
end

function ProgramService:khead(program, blockType, blockName, value)
  local prog = program:getProgramNumber()
  local kg = program:getActiveKeyGroupIndex() - 1

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
    local msg = KheadMsg(prog, kg, offset, valueBlock)
    msg.data:setByte(8, 0x15)
    msg.data:setByte(9, 0x01)
    return msg
  elseif blockType == KG_FILQ then
    valueBlock = midiService:toFilqBlock(value)
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

function ProgramService:getAbsoluteParamValue(blockName, value, minValue)
  if absoluteValueParams[blockName] then
    return value
  elseif blockName == "LONOTE" or blockName == "HINOTE" then
    return value - 24
  elseif minValue > 0 then
    return value + minValue
  else
    return value
  end
end
