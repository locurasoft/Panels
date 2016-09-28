require("LuaObject")
require("Logger")

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

function S2kDieService:_init(s2kDieP, setfdprmP)
  LuaObject._init(self)
  self.s2kDiePath = s2kDieP
  self.setfdprmPath = setfdprmP
  self.log = Logger("S2kDieService")
end

function getFilePath(fileDir, fileName)
	return string.format("%s%s%s", fileDir, pathseparator, fileName)
end

function getFileName(filePath)
	local lastSlash = string.find(filePath, string.format("%s[^%s]*$", pathseparator, pathseparator))
	return string.sub(filePath, lastSlash + 1)
end

function getScriptName(index)
	return string.format("script-%d.s2k", index)
end

function S2kDieService:getS2kDiePath()
	return self.s2kDiePath
end

function S2kDieService:setS2kDiePath(s2kDiePath)
	self.s2kDiePath = s2kDiePath
end

function S2kDieService:setFdprmPath(setfdprmPath)
	self.setfdprmPath = setfdprmPath
end

function S2kDieService:getNumGeneratedSamples(logFilePath)
	self.log:info("%s", logFilePath)
	local logFile = io.open(logFilePath, "rb")
	local highestValue = -1
	if logFile ~= nil then
		local content = logFile:read("*all")
		self.log:info(content)
		logFile:close()
		
		for value in string.gfind(content, "%[(%d+)%]") do
			local numValue = tonumber(value) + 1
			self.log:info("[getNumGeneratedSamples] %d", numValue)
			if numValue > highestValue then
				highestValue = numValue
			end
		end
	end

	return highestValue
end

function S2kDieService:s2kDieLauncher()
	local s2kDieRoot = self.s2kDiePath
	local launcher = function(variables)
		self.log:info("Generating scripts...")

		-- Generate s2kDie script
		local scriptDir = variables["scriptDir"]
		local scriptIndex = variables["scriptIndex"]
		local scriptPath = variables["scriptPath"]
		local wavFiles = variables["wavFiles"]

		local fileName = getScriptName(scriptIndex)
		local filePath = getFilePath(scriptDir, fileName)
		local file = io.open(filePath, "w+")
		file:write("BLANK S2000")
		file:write(eol)
		file:write(string.format("VOL %s", fileName))
		file:write(eol)

		for key, wavFile in pairs(wavFiles) do
			file:write(string.format("WLOAD %s", getFileName(wavFile:getFullPathName())))
			file:write(eol)
		end

		local imgPath = getFilePath(scriptDir, string.format("floppy-%d.img", scriptIndex))
		file:write(string.format("SAVE %s", imgPath))
		file:write(eol)
		file:write("DIR")
		file:write(eol)
		file:close()
		variables["imgPath"] = imgPath

		-- Append commands to shell script
		local script = io.open(scriptPath, "a")
		for key, wavFile in pairs(wavFiles) do
			wavPath = wavFile:getFullPathName()
			script:write(string.format("cp %s %s", wavPath, getFilePath(scriptDir, getFileName(wavPath))))
			script:write(eol)
		end

		script:write(string.format("cd %s", scriptDir))
		script:write(eol)
		script:write(string.format("php %s %s", s2kDieRoot:getFullPathName(), filePath, filePath))
		script:write(eol)
		script:close()
	end
	return launcher
end
