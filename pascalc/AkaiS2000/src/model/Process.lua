local log = Logger("Process")

__Process = Object()

function __Process:getLogFilePath()
	local logFileName = string.format("scriptLauncher.%s.log", self.suffix)
	return self:getFullPath(logFileName)
end

function __Process:getFullPath(scriptName)
	return string.format("%s%s%s", self.scriptPath, pathseparator, scriptName)
end

function __Process:getScriptPath()
	console(string.format("[s2kProcess:getScriptPath()] %s", self.scriptPath))
	return self.scriptPath
end

function __Process:hasLauncher()
	return table.getn(self.launchGenerators) > 0
end

function __Process:hasAborter()
	return table.getn(self.abortGenerators) > 0
end

function __Process:getLaunchName()
	return self.launchVariables["scriptName"]
end

function __Process:getAbortName()
	return self.abortScriptName
end

function __Process:build()
	local scriptName = string.format("scriptLauncher.%s", self.suffix)
	self.launchVariables["scriptIndex"] = self.id
	self.launchVariables["scriptName"] = scriptName
	self.launchVariables["scriptPath"] = self:getFullPath(scriptName)
	self.launchVariables["scriptDir"]  = self.scriptPath
	os.remove(self.launchVariables["scriptPath"])
	console(string.format("Building process %d %s in %s",
		self.launchVariables["scriptIndex"], self.launchVariables["scriptName"],
		self.launchVariables["scriptDir"]))

	for key,launchGenerator in pairs(self.launchGenerators) do
		launchGenerator(self.launchVariables)
	end

	self.abortScriptName = string.format("scriptAborter.%s", self.suffix)
	local abortScriptPath = self:getFullPath(self.abortScriptName)
	os.remove(abortScriptPath)
	for key,abortGenerator in pairs(self.abortGenerators) do
		abortGenerator(abortScriptPath)
	end
end

function __Process:withLaunchVariable(key, value)
	self.launchVariables[key] = value
	return self
end

function __Process:withLaunchGenerator(value)
	table.insert(self.launchGenerators, value)
	return self
end

function __Process:withAbortGenerator(value)
	table.insert(self.abortGenerators, value)
	return self
end

function __Process:withSuffix(value)
	self.suffix = value
	return self
end

function __Process:withPath(value)
	self.scriptPath = value
	return self
end

function __Process:withMidiCallback(newval)
	self.midiCallback = newval
	return self
end

function __Process:withMidiSender(newval, newInterval)
	self.midiSender = newval
	self.interval = newInterval
	return self
end

function Process()
	-- Get random transferId
	math.randomseed( os.time() )
	math.random(); math.random(); math.random()

	local o = {
		midiCallback = nil,
		midiSender = nil,
		interval = 0,
		scriptName = nil,
		launchGenerators = {},
		abortGenerators = {},
		launchVariables = {},
		scriptPath = workFolder:getFullPathName(),
		abortScriptPath = nil,
		id = math.random(100000)
	}
	
	o.suffix = "bat"
	if operatingSystem == "mac" then
		o.suffix = "sh"
	end

	return __Process:new(o)
end
