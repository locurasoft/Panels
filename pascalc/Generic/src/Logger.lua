require("LuaObject")

FINE, INFO, WARN = 2, 1, 0
LOG_LEVEL = WARN

local GLOBAL_LOG_FILE = io.open("akaiS2000Panel.log", "w")

Logger = {}
Logger.__index = Logger

setmetatable(Logger, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Logger:_init(loggerName)
  LuaObject._init(self)
  self.name = loggerName
end

function Logger:setLevel(level)
  LOG_LEVEL = level
end

function Logger:getLevel()
  return LOG_LEVEL
end

function Logger:warn(log, ...)
  if LOG_LEVEL >= WARN then
    local line = string.format("[WARN] [%s] - %s", self.name, string.format(log, ...))
    console(line)
    GLOBAL_LOG_FILE:write(line)
  end
end

function Logger:info(log, ...)
  if LOG_LEVEL >= INFO then
    local line = string.format("[INFO] [%s] - %s", self.name, string.format(log, ...))
    console(line)
    GLOBAL_LOG_FILE:write(line)
  end
end

function Logger:fine(log, ...)
  if LOG_LEVEL >= FINE then
    local line = string.format("[FINE] [%s] - %s", self.name, string.format(log, ...))
    console(line)
    GLOBAL_LOG_FILE:write(line)
  end
end

function flushLogFile()
  GLOBAL_LOG_FILE:flush()
end