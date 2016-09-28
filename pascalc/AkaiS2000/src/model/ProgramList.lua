require("Dispatcher")
require("Logger")

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
  table.insert(self.list, program)
  self:notifyListeners()
end

function ProgramList:removeProgram(index)
  table.remove(self.list, index)
  self:notifyListeners()
end

function ProgramList:activateProgram(index)
  self.activeProgram = index
  self:notifyListeners()
end

function ProgramList:getActiveProgram()
  log:fine("[getActiveProgram] Active program %d", self.activeProgram)
  if self.activeProgram <= 0 then
    return nil
  else
    return self.list[self.activeProgram]
  end
end

function ProgramList:setActiveProgram(activeProgNum)
  --log:fine("Active program before %d", self.activeProgram)
  self.activeProgram = activeProgNum
  --log:fine("Active program after %d", self.activeProgram)
  self:notifyListeners()
end

function ProgramList:hasProgram(programName)
  for k,program in pairs(self.list) do
    if program:getName() == programName then
      return true
    end
  end
  return false
end
