if SampleList ~= nil then return end
require("Dispatcher")
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
  self[LUA_CONTRUCTOR_NAME] = "SampleList"
end

function SampleList:sampleExists(name)
  return self.list[name] ~= nil
end

function SampleList:getSampleList()
  return self.list
end

function SampleList:getSampleNames()
  local sampleListString = ""
  for k,v in pairs(self.list) do
    if sampleListString == "" then
      sampleListString = k
    else
      sampleListString = string.format("%s\n%s", sampleListString, k)
    end
  end
  return sampleListString
end

function SampleList:addSample(name)
  self.list[name] = true
  table.sort(self.list)
  self:notifyListeners()
end

function SampleList:addSamples(slist)
  local modified = false
  local sampleNames = slist:getSampleList()
  for k,v in pairs(sampleNames) do
    if not self:sampleExists(v) then
      self.list[v] = true
      modified = true
    end
  end
  table.sort(self.list)

  if modified then
    self:notifyListeners()
  end
end
