require("LuaObject")
require("Logger")

HxcService = {}
HxcService.__index = HxcService

setmetatable(HxcService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function HxcService:_init(settings)
  LuaObject._init(self)
  
  self.log = Logger("HxcService")
  self.settings = settings
  self.hxcPipe = "HXC_PIPE"
  self.log:info("HxC constants initialised.")
end

function HxcService:getMacOsXLauncher()
  local launcher = function (variables)
    local scriptPath = variables["scriptPath"]
    local imgPath = variables["imgPath"]

    local file = io.open(scriptPath, "a")
    file:write("#!/bin/bash\n")
    --file:write("set -x -v\n")
    file:write("set -e\n")

    file:write(string.format("pipe=%s", self.hxcPipe))
    file:write(EOL)
    file:write("if [ -p \"${pipe}\" ]; then rm -rf ${pipe}; fi")
    file:write(EOL)
    file:write("mkfifo ${pipe}")
    file:write(EOL)

    local hxc_cmd = self:getHxcCommand(imgPath)
    file:write(string.format("./%s < ${pipe}", hxc_cmd))
    file:write(EOL)
    file:close()
  end
  return launcher
end

function HxcService:getMacOsXAborter()
  local aborter = function (scriptPath)
    local file = io.open(scriptPath, "a")
    file:write("#!/bin/bash\n")
    --file:write("set -x -v\n")
    file:write("set -e\n")

    file:write("echo \"Attempting to kill hxcfe...\"")
    file:write(EOL)
    file:write(string.format("echo \"q\n\" > %s", self.hxcPipe))
    file:write(EOL)
    file:close()
  end
  return aborter
end

function HxcService:getWindowsAborter()
  local aborter = function(scriptPath)
    local file = io.open(scriptPath, "a")
    file:write("for /f \"tokens=2 delims=,\" %%a in ('tasklist /v /fo csv ^| findstr /i \"hxcfe\"') do set \"$PID=%%a\"")
    file:write(EOL)
    file:write("taskkill /F /PID %$PID%")
    file:write(EOL)
    file:close()
  end
  return aborter
end

function HxcService:getWindowsLauncher()
  local launcher = function(variables)
    local scriptPath = variables["scriptPath"]
    local imgPath = variables["imgPath"]

    self.log:info("Generating %s with image %s", scriptPath, imgPath)

    local file = io.open(scriptPath, "a")
    file:write(string.format("cd %s", self.settings:getHxcRoot()))
    file:write(EOL)
    file:write(self:getHxcCommand(imgPath))
    file:write(EOL)
    file:close()
  end
  return launcher
end

function HxcService:getHxcCommand(imgPath)
  return string.format("%s -uselayout:AKAIS3000_HD -finput:%s -usb:", self.settings:getHxcPath(), imgPath)
end

function HxcService:getHxcLauncher()
  if OPERATING_SYSTEM == "win" then
    return self:getWindowsLauncher()
  else
    return self:getMacOsXLauncher()
  end
end

function HxcService:getHxcAborter()
  if OPERATING_SYSTEM == "win" then
    return self:getWindowsAborter()
  else
    return self:getMacOsXAborter()
  end
end
