require("LuaObject")
require("Logger")
require("cutils")

local log = Logger("Process")

Process = {}
Process.__index = Process

setmetatable(Process, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Process:_init()
  LuaObject._init(self)
  -- Get random transferId
  math.randomseed( os.time() )
  math.random(); math.random(); math.random()

  self.midiCallback = nil
  self.midiSender = nil
  self.interval = 0
  self.scriptName = nil
  self.launchGenerators = {}
  self.abortGenerators = {}
  self.launchVariables = {}
  self.workFolder = settings:getWorkFolder()
  self.abortScriptPath = nil
  self.id = math.random(100000)

  self.suffix = "bat"
  if cutils.getOsName() == "mac" then
    self.suffix = "sh"
  end
end

function Process:getLogFilePath()
  local logFileName = string.format("scriptLauncher.%s.log", self.suffix)
  return cutils.toFilePath(self.workFolder, logFileName)
end

function Process:getScriptPath()
  return self.workFolder
end

function Process:hasLauncher()
  return table.getn(self.launchGenerators) > 0
end

function Process:hasAborter()
  return table.getn(self.abortGenerators) > 0
end

function Process:getLaunchName()
  return self.launchVariables["scriptName"]
end

function Process:getAbortName()
  return self.abortScriptName
end

function Process:build()
  local scriptName = string.format("scriptLauncher.%s", self.suffix)
  self.launchVariables["scriptIndex"] = self.id
  self.launchVariables["scriptName"] = scriptName
  self.launchVariables["scriptPath"] = cutils.toFilePath(self.workFolder, scriptName)
  self.launchVariables["scriptDir"]  = self.workFolder
  os.remove(self.launchVariables["scriptPath"])

  for key,launchGenerator in pairs(self.launchGenerators) do
    launchGenerator(self.launchVariables)
  end

  self.abortScriptName = string.format("scriptAborter.%s", self.suffix)
  local abortScriptPath = cutils.toFilePath(self.workFolder, self.abortScriptName)
  os.remove(abortScriptPath)
  for key,abortGenerator in pairs(self.abortGenerators) do
    abortGenerator(abortScriptPath)
  end
  return self
end

function Process:withLaunchVariable(key, value)
  self.launchVariables[key] = value
  return self
end

function Process:withLaunchGenerator(value)
  table.insert(self.launchGenerators, value)
  return self
end

function Process:withAbortGenerator(value)
  table.insert(self.abortGenerators, value)
  return self
end

function Process:withSuffix(value)
  self.suffix = value
  return self
end

function Process:withPath(value)
  self.workFolder = value
  return self
end

function Process:withMidiCallback(newval)
  self.midiCallback = newval
  return self
end

function Process:withMidiSender(newval, newInterval)
  self.midiSender = newval
  self.interval = newInterval
  return self
end