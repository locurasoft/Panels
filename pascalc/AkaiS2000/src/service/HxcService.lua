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

function HxcService:_init()
  LuaObject._init(self)
  local hxcPath = File(panel:getComponent("hxcPathLabel"):getText())
  local logger = Logger("HxcService")
  self.hxc_pipe = "HXC_PIPE"
  self.hxc_cmd_log = "hxc_cmd.log"
  self.hxc_child_pid = "hxc_child_pid"
  self.hxc_launch_timeout = 100
  self.hxc_timer_id = 20
  self.hxc_path = hxcPath:getFullPathName()
  self.hxc_root = hxcPath:getParentDirectory():getFullPathName()
  self.log = logger
  logger:info("HxC constants initialised.")
end

function __HxcService:setHxcPath(hxcPath)
  self.hxc_path = hxcPath:getFullPathName()
  self.hxc_root = hxcPath:getParentDirectory():getFullPathName()
end

function __HxcService:getMacOsXLauncher()
  local launcher = function (variables)
    local scriptPath = variables["scriptPath"]
    local imgPath = variables["imgPath"]

    local file = io.open(scriptPath, "a")
    file:write("#!/bin/bash\n")
    --file:write("set -x -v\n")
    file:write("set -e\n")

    file:write(string.format("pipe=%s", hxc_pipe))
    file:write(eol)
    file:write("if [ -p \"${pipe}\" ]; then rm -rf ${pipe}; fi")
    file:write(eol)
    file:write("mkfifo ${pipe}")
    file:write(eol)

    local hxc_cmd = self.getHxcCommand(imgPath)
    file:write(string.format("./%s < ${pipe}", hxc_cmd))
    file:write(eol)
    file:close()
  end
  return launcher
end

function __HxcService:getMacOsXAborter()
  local aborter = function (scriptPath)
    local file = io.open(scriptPath, "a")
    file:write("#!/bin/bash\n")
    --file:write("set -x -v\n")
    file:write("set -e\n")

    file:write("echo \"Attempting to kill hxcfe...\"")
    file:write(eol)
    file:write(string.format("echo \"q\n\" > %s", hxc_pipe))
    file:write(eol)
    file:close()
  end
  return aborter
end

function __HxcService:getWindowsAborter()
  local aborter = function(scriptPath)
    local file = io.open(scriptPath, "a")
    file:write("for /f \"tokens=2 delims=,\" %%a in ('tasklist /v /fo csv ^| findstr /i \"hxcfe\"') do set \"$PID=%%a\"")
    file:write(eol)
    file:write("taskkill /F /PID %$PID%")
    file:write(eol)
    file:close()
  end
  return aborter
end

function __HxcService:getWindowsLauncher()
  local launcher = function(variables)
    local scriptPath = variables["scriptPath"]
    local imgPath = variables["imgPath"]

    self.log:info("Generating %s with image %s", scriptPath, imgPath)

    local file = io.open(scriptPath, "a")
    file:write(string.format("cd %s", self.hxc_root))
    file:write(eol)
    file:write(self:getHxcCommand(imgPath))
    file:write(eol)
    file:close()
  end
  return launcher
end


function __HxcService:getHxcCommand(imgPath)
  return string.format("%s -uselayout:AKAIS3000_HD -finput:%s -usb:", self.hxc_path, imgPath)
end

function __HxcService:getHxcPath()
  return self.hxc_path
end

function __HxcService:getHxcLauncher()
  if operatingSystem == "win" then
    return self:getWindowsLauncher()
  else
    return self:getMacOsXLauncher()
  end
end

function __HxcService:getHxcAborter()
  if operatingSystem == "win" then
    return self:getWindowsAborter()
  else
    return self:getMacOsXAborter()
  end
end
