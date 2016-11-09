require("LuaObject")
require("Logger")
require("cutils")

local log = Logger("ProcessController")
local MIDI_POLL_THREAD_ID = 33

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

ProcessController = {}
ProcessController.__index = ProcessController

setmetatable(ProcessController, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ProcessController:_init(pl)
  LuaObject._init(self)
  self.processListener = pl
  self.curr_transfer_proc = nil
end

function ProcessController:execute(proc)
  assert(self.curr_transfer_proc == nil)
  self.curr_transfer_proc = proc

  if self.processListener ~= nil then
    self.processListener(true)
  end

  if proc.midiCallback ~= nil then
    log:info("Adding midiCallback")
    globalController:setMidiReceived(proc.midiCallback)
  end

  if proc.midiSender ~= nil then
    log:info("Launching midiSender")

    timer:stopTimer(MIDI_POLL_THREAD_ID)

    timer:setCallback (MIDI_POLL_THREAD_ID, proc.midiSender)
    log:info("Starting timer %d, with interval %d", MIDI_POLL_THREAD_ID, proc.interval)
    timer:startTimer(MIDI_POLL_THREAD_ID, proc.interval)
  end

  if proc:hasLauncher() then
    local scriptPath = proc:getScriptPath()
    local scriptName = proc:getLaunchName()
    if cutils.getOsName() == "win" then
      log:info("[hxcLaunchOnWindows] %s - %s:", scriptPath, scriptName)
      windowsExecutor(scriptPath, scriptName)
    else
      log:info("[hxcLaunchOnMacOsX] %s - %s", scriptPath, scriptName)
      macOsXExecutor(scriptPath, scriptName)
    end
  end
end

function ProcessController:abort()
  assert(self.curr_transfer_proc ~= nil, "No active process to abort!")
  timer:stopTimer(MIDI_POLL_THREAD_ID)
  globalController:clearMidiReceived()

  if self.curr_transfer_proc:hasAborter() then
    local scriptPath = self.curr_transfer_proc:getScriptPath()
    local scriptName = self.curr_transfer_proc:getAbortName()
    if cutils.getOsName() == "win" then
      log:info("[hxcLaunchOnWindows] %s - %s:", scriptPath, scriptName)
      windowsExecutor(scriptPath, scriptName)
    else
      log:info("[hxcLaunchOnMacOsX] %s - %s", scriptPath, scriptName)
      macOsXExecutor(scriptPath, scriptName)
    end
  end

  if self.processListener ~= nil then
    self.processListener(false)
  end

  self.curr_transfer_proc = nil
end
