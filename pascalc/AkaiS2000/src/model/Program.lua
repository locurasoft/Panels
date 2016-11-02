require("Dispatcher")
require("message/PdataMsg")
require("Logger")

local log = Logger("Program")

Program = {}
Program.__index = Program

setmetatable(Program, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Program:_init(data)
  Dispatcher._init(self)
  self.pdata = data or PdataMsg()
  self.keyGroups = {}
  self.activeKg = 1
  self.updating = false
  self[LUA_CONTRUCTOR_NAME] = "Program"
end

function Program:getName()
  return self.pdata:getName()
end

function Program:setName(name)
  self.pdata:setName(name)
  self:notifyListeners()
end

function Program:setProgramNumber(programNumber)
  self.pdata:setProgramNumber(programNumber)
end

function Program:getProgramNumber()
  return self.pdata:getProgramNumber()
end

function Program:setActiveKeyGroupIndex(index)
  self.activeKg = index
  --self:notifyListeners()
end

function Program:getActiveKeyGroupIndex()
  return self.activeKg
end

function Program:getActiveKeyGroup()
  return self.keyGroups[self.activeKg]
end

function Program:getNumKeyGroups()
  return table.getn(self.keyGroups)
end

function Program:addKeyGroup(keyGroup)
  table.insert(self.keyGroups, keyGroup)
  self:notifyListeners()
end

function Program:getKeyGroup(index)
  return self.keyGroups[index]
end

function Program:removeKeyGroup(index)
  table.remove(self.keyGroups, index)
  self:notifyListeners()
end

function Program:storeParamEdit(phead)
  if self.updating then
    return
  end
  self.pdata:storePhead(phead)
end

function Program:getParamValue(blockId)
  return self.pdata:getPdataValue(blockId)
end

function Program:setUpdating(updating)
  self.updating = updating
end

function Program:isUpdating()
  return self.updating
end

function Program:toString()
  return self.pdata:toString()
end

function Program:toJson()
  local base = json.encode(self)
  -- Replace pdata
  base = string.gsub(
    base, "\"pdata\":{[^}]+}", string.format("\"pdata\":%s", self.pdata:toJson()),	1)
  -- Replace keygroups
  local kgs = ""
  for k,v in pairs(self.keyGroups) do
    if kgs == "" then
      kgs = string.format("%s", v:toJson())
    else
      kgs = string.format("%s,%s", kgs, v:toJson())
    end
  end
  base = string.gsub(
    base, "\"keyGroups\":\[[^]+\]", string.format("\"keyGroups\":[%s]", kgs),	1)
  return base
end
