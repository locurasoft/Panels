require("LuaObject")
require("Logger")
require("cutils")

HxcService = {}
HxcService.__index = HxcService

local log = Logger("HxcService")
local hxcPipe = "HXC_PIPE"

local getHxcCommand = function(settings, imgPath)
  return string.format("%s -uselayout:AKAIS3000_HD -finput:%s -usb:", settings:getHxcPath(), imgPath)
end

local getMacOsXLauncher = function(settings)
  local launcher = function (variables)
    local scriptPath = variables["scriptPath"]
    local imgPath = variables["imgPath"]

    local file = io.open(scriptPath, "a")
    file:write("#!/bin/bash\n")
    --file:write("set -x -v\n")
    file:write("set -e\n")

    file:write(string.format("pipe=%s", hxcPipe))
    file:write(cutils.getEolChar())
    file:write("if [ -p \"${pipe}\" ]; then rm -rf ${pipe}; fi")
    file:write(cutils.getEolChar())
    file:write("mkfifo ${pipe}")
    file:write(cutils.getEolChar())

    local hxc_cmd = getHxcCommand(settings, imgPath)
    file:write(string.format("%s < ${pipe}", hxc_cmd))
    file:write(cutils.getEolChar())
    file:close()
  end
  return launcher
end

local getMacOsXAborter = function(settings)
  local aborter = function (scriptPath)
    local file = io.open(scriptPath, "a")
    file:write("#!/bin/bash\n")
    --file:write("set -x -v\n")
    file:write("set -e\n")

    file:write("echo \"Attempting to kill hxcfe...\"")
    file:write(cutils.getEolChar())
    file:write(string.format("echo \"q\n\" > %s", hxcPipe))
    file:write(cutils.getEolChar())
    file:close()
  end
  return aborter
end

local getWindowsAborter = function(settings)
  local aborter = function(scriptPath)
    local file = io.open(scriptPath, "a")
    file:write("for /f \"tokens=2 delims=,\" %%a in ('tasklist /v /fo csv ^| findstr /i \"hxcfe\"') do set \"$PID=%%a\"")
    file:write(cutils.getEolChar())
    file:write("taskkill /F /PID %$PID%")
    file:write(cutils.getEolChar())
    file:close()
  end
  return aborter
end

local getWindowsLauncher = function(settings)
  local launcher = function(variables)
    local scriptPath = variables["scriptPath"]
    local imgPath = variables["imgPath"]

    log:info("Generating %s with image %s", scriptPath, imgPath)

    local file = io.open(scriptPath, "a")
    file:write(string.format("cd %s", settings:getHxcRoot()))
    file:write(cutils.getEolChar())
    file:write(getHxcCommand(settings, imgPath))
    file:write(cutils.getEolChar())
    file:close()
  end
  return launcher
end

setmetatable(HxcService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function HxcService:_init()
  LuaObject._init(self)
  log:info("HxC constants initialised.")
end

function HxcService:setSettings(settings)
  self.settings = settings
end

function HxcService:getHxcLauncher()
  if cutils.getOsName() == "win" then
    return getWindowsLauncher(self.settings)
  else
    return getMacOsXLauncher(self.settings)
  end
end

function HxcService:getHxcAborter()
  if cutils.getOsName() == "win" then
    return getWindowsAborter(self.settings)
  else
    return getMacOsXAborter(self.settings)
  end
end
