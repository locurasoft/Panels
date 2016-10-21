require("LuaObject")
require("Logger")

local log = Logger("Zone")

Zone = {}
Zone.__index = Zone

setmetatable(Zone, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Zone:_init()
  LuaObject._init(self)
  self.sampleLoaded = false
  self.file = nil
  self.fileName = nil
  self.sampleName = nil
  self[LUA_CONTRUCTOR_NAME] = "Zone"
end
local log = Logger("Zone")

function Zone:setSample(sampleName)
  self.sampleLoaded = true
  self.sampleName = sampleName
end

function Zone:setFile(file)
  self.sampleLoaded = false
  self.file = file
  self.fileName = file:getFileName()
end

function Zone:isSampleLoaded()
  return self.sampleLoaded
end

function Zone:getSampleName()
  if self:isSampleLoaded() then
    --log:info("sample loaded %s", self.sampleName))
    return self.sampleName
  else
    --log:info("sample not loaded %s", self.fileName))
    return self.fileName
  end
end

function Zone:matchesSampleName(sampleName)
  local monoSampleName = v
  if string.sub(v, #v - 2, #v) == "-L" or string.sub(v, #v - 2, #v) == "-R" then
    monoSampleName = string.sub(v, 1, #v - 2)
  end
end
