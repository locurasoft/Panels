require("Dispatcher")
require("Logger")
require("lutils")

local log = Logger("ProgramList")

ProgramList = {}
ProgramList.__index = ProgramList

setmetatable(ProgramList, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ProgramList:_init()
  Dispatcher._init(self)
  self.activeProgram = -1
  self.list = {}
  self[LUA_CONTRUCTOR_NAME] = "ProgramList"
end

function ProgramList:getNumPrograms()
  return table.getn(self.list)
end

function ProgramList:getProgram(index)
  return self.list[index]
end

function ProgramList:addProgram(program)
  log:warn("Adding prog %s (%d)", program:getName(), self:getNumPrograms())
  table.insert(self.list, program)
  self:notifyListeners()
end

function ProgramList:removeProgram(index)
  table.remove(self.list, index)
  self:notifyListeners()
end

function ProgramList:getActiveProgram()
  if self.activeProgram <= 0 then
    return nil
  else
    return self.list[self.activeProgram]
  end
end

function ProgramList:setActiveProgram(activeProgNum)
  if activeProgNum == 0 then
    activeProgNum = 1
  end

  if self:getNumPrograms() == 0 then
    return
  end

  self.activeProgram = activeProgNum
  self:notifyListeners()
end

function ProgramList:hasProgram(programName)
  for k, program in pairs(self.list) do
    if lutils.trim(program:getName()) == lutils.trim(midiService:toAkaiString(programName)) then
      return true
    end
  end
  return false
end
