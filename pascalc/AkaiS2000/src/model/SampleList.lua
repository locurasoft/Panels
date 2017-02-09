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

function SampleList:getSampleName(index)
  return table.get(self.list, index)
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

function SampleList:indexOf(sampleName)
  for k,v in pairs(self.list) do
    if v == sampleName then
      return k
    end
  end
  error("Sample not loaded.\nPlease make sure the sample is loaded on your sampler and run RsList")
end

function SampleList:isEmpty()
	return table.getn(self.list) == 0
end