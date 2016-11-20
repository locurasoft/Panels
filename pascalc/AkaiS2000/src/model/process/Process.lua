require("Dispatcher")
require("Logger")
require("cutils")


PROCESS_RUNNING = 1
PROCESS_ABORTED = 2

local MIDI_POLL_THREAD_ID = 33
local log = Logger("Process")

local getFileContents = function(filepath)
  local f = io.open(filepath, "rb")
  local content = ""
  if f ~= nil then
    content = f:read("*all")
    f:close()
  end

  return content
end

local macOsXExecutor = function(scriptDir, scriptName)
  os.execute(string.format("chmod 755 %s/%s", scriptDir, scriptName))
  os.execute(string.format("pushd %s; ./%s > %s.log 2>&1", scriptDir, scriptName, scriptName))

  local logPath = string.format("%s/%s.log", scriptDir, scriptName)
end

local windowsExecutor = function(scriptDir, scriptName)
  local scriptPath = string.format("%s\\%s", scriptDir, scriptName)
  local script = io.open(scriptPath, "a")
  script:write(cutils.getEolChar())
  script:write("exit")
  script:write(cutils.getEolChar())
  script:close()

  os.execute(string.format("cmd /C start /B %s ^> %s.log", scriptPath, scriptPath))
end

Process = {}
Process.__index = Process

setmetatable(Process, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Process:_init()
  Dispatcher._init(self)
  -- Get random transferId
  math.randomseed( os.time() )
  math.random(); math.random(); math.random()

  self.state = false
  self.workFolder = settings:getWorkFolder()
  self.message = ""
  self.externalProcessActive = false
  self.abortGenerators = {}
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

function Process:hasAborter()
  return table.getn(self.abortGenerators) > 0
end

function Process:isRunning()
  return bit.band(self.state, 0x1) == 1 
end

function Process:getState()
  return self.state
end

function Process:withLaunchVariable(key, value)
  self.launchVariables[key] = value
  return self
end

function Process:withAbortGenerator(value)
  table.insert(self.abortGenerators, value)
  return self
end

function Process:registerMidiCallback(cbkFunc)
  log:info("Adding midiCallback")
  midiService:setMidiReceived(cbkFunc)
end

function Process:launchMidiSender(sndFunc, interval)
  log:info("Launching midiSender")
  timer:stopTimer(MIDI_POLL_THREAD_ID)

  timer:setCallback(MIDI_POLL_THREAD_ID, sndFunc)
  log:info("Starting timer %d, with interval %d", MIDI_POLL_THREAD_ID, interval)
  timer:startTimer(MIDI_POLL_THREAD_ID, interval)
end

function Process:launchExternalProcess(launchGenerators, launchVariables, abortGenerators)
  if self.externalProcessActive then
    log:warn("Cannot run more than one external process at the time!")
    return
  end

  self.abortGenerators = abortGenerators
  local scriptName = string.format("scriptLauncher.%s", self.suffix)
  launchVariables["scriptIndex"] = self.id
  launchVariables["scriptName"] = scriptName
  launchVariables["scriptPath"] = cutils.toFilePath(self.workFolder, scriptName)
  launchVariables["scriptDir"]  = self.workFolder
  os.remove(launchVariables["scriptPath"])

  for key,launchGenerator in pairs(launchGenerators) do
    launchGenerator(launchVariables)
  end

  if cutils.getOsName() == "win" then
    windowsExecutor(self.workFolder, scriptName)
  else
    macOsXExecutor(self.workFolder, scriptName)
  end
end

function Process:stopAll()
  self:stopMidiThreads()
  self:stopExternalProcess()
end

function Process:stopExternalProcess()
  if self:hasAborter() then
    local abortScriptName = string.format("scriptAborter.%s", self.suffix)
    local abortScriptPath = cutils.toFilePath(self.workFolder, abortScriptName)
    os.remove(abortScriptPath)
    for key,abortGenerator in ipairs(self.abortGenerators) do
      abortGenerator(abortScriptPath)
    end
    if cutils.getOsName() == "win" then
      windowsExecutor(self.workFolder, abortScriptName)
    else
      macOsXExecutor(self.workFolder, abortScriptName)
    end
    self.externalProcessActive = false
  end
end

function Process:stopMidiThreads()
  midiService:clearMidiReceived()
  timer:stopTimer(MIDI_POLL_THREAD_ID)
end

function Process:abort()
  self:stopAll()
  self.state = PROCESS_ABORTED
  self:notifyListeners()
end
