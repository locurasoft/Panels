if SampleList ~= nil then return end
require("Dispatcher")
require("lutils")
require("Logger")

local log = Logger("SampleList")

SampleList = {}
SampleList.__index = SampleList

setmetatable(SampleList, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SampleList:_init()
  Dispatcher._init(self)
  self.list = {}
  self.sampleNameList = {}
  self[LUA_CONTRUCTOR_NAME] = "SampleList"
end

function SampleList:sampleExists(name)
  return self.sampleNameList[name] ~= nil
end

function SampleList:getSampleList()
  return self.list
end

function SampleList:getSampleNames()
  local sampleListString = ""
  for k,v in pairs(self.list) do
    if sampleListString == "" then
      sampleListString = v
    else
      sampleListString = string.format("%s\n%s", sampleListString, v)
    end
  end
  return sampleListString
end

function SampleList:addSample(name)
  table.insert(self.list, name)
  table.sort(self.list)
  self.sampleNameList = lutils.flipTable(self.list)
  self:notifyListeners()
end

function SampleList:addSamples(slist)
  local modified = false
  local sampleNames = slist:getSampleList()
  for k,v in pairs(sampleNames) do
    if not self:sampleExists(v) then
      table.insert(self.list, v)
      modified = true
    end
  end
  table.sort(self.list)
  self.sampleNameList = lutils.flipTable(self.list)

  if modified then
    self:notifyListeners()
  end
end
