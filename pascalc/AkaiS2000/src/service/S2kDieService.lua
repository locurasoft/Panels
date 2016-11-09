require("LuaObject")
require("cutils")
require("Logger")

local getScriptName = function(index)
  return string.format("script-%d.s2k", index)
end

S2kDieService = {}
S2kDieService.__index = S2kDieService

setmetatable(S2kDieService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function S2kDieService:_init(settings)
  LuaObject._init(self)
  self.settings = settings
  self.log = Logger("S2kDieService")
end

function S2kDieService:getNumGeneratedSamples(logFilePath)
  local content = cutils.getFileContents(logFilePath)
  local highestValue = -1

  for value in string.gfind(content, "%[(%d+)%]") do
    local numValue = tonumber(value) + 1
    self.log:info("[getNumGeneratedSamples] %d", numValue)
    if numValue > highestValue then
      highestValue = numValue
    end
  end

  return highestValue
end

function S2kDieService:s2kDieLauncher()
  local s2kDiePath = self.settings:getS2kDiePath()
  local launcher = function(variables)
    self.log:info("Generating scripts...")

    -- Generate s2kDie script
    local scriptDir = variables["scriptDir"]
    local scriptIndex = variables["scriptIndex"]
    local scriptPath = variables["scriptPath"]
    local wavFiles = variables["wavFiles"]

    local fileName = getScriptName(scriptIndex)
    local filePath = cutils.toFilePath(scriptDir, fileName)
    local file = io.open(filePath, "w+")
    file:write("BLANK S2000")
    file:write(cutils.getEolChar())
    file:write(string.format("VOL %s", fileName))
    file:write(cutils.getEolChar())

    for key, wavFile in pairs(wavFiles) do
      file:write(string.format("WLOAD %s", cutils.getFileName(wavFile:getFullPathName())))
      file:write(cutils.getEolChar())
    end

    local imgPath = cutils.toFilePath(scriptDir, string.format("floppy-%d.img", scriptIndex))
    file:write(string.format("SAVE %s", imgPath))
    file:write(cutils.getEolChar())
    file:write("DIR")
    file:write(cutils.getEolChar())
    file:close()
    variables["imgPath"] = imgPath

    -- Append commands to shell script
    local script = io.open(scriptPath, "a")
    for key, wavFile in pairs(wavFiles) do
      local wavPath = wavFile:getFullPathName()
      script:write(string.format("cp %s %s", wavPath, 
        cutils.toFilePath(scriptDir, cutils.getFileName(wavPath))))
      script:write(cutils.getEolChar())
    end

    script:write(string.format("cd %s", scriptDir))
    script:write(cutils.getEolChar())
    script:write(string.format("php %s %s", s2kDiePath, filePath, filePath))
    script:write(cutils.getEolChar())
    script:close()
  end
  return launcher
end
