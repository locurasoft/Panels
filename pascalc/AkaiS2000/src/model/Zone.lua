local log = Logger("Zone")

__Zone = Object()

function __Zone:setSample(sampleName)
	self.sampleLoaded = true
	self.sampleName = sampleName
end

function __Zone:setFile(file)
	self.sampleLoaded = false
	self.file = file
	self.fileName = file:getFileName()
end

function __Zone:isSampleLoaded()
	return self.sampleLoaded
end

function __Zone:getSampleName()
	if self:isSampleLoaded() then
		--log:info("sample loaded %s", self.sampleName))
		return self.sampleName
	else
		--log:info("sample not loaded %s", self.fileName))
		return self.fileName
	end
end

function __Zone:matchesSampleName(sampleName)
	local monoSampleName = v
	if string.sub(v, #v - 2, #v) == "-L" or string.sub(v, #v - 2, #v) == "-R" then
		monoSampleName = string.sub(v, 1, #v - 2)
	end
end

function Zone()
	return __Zone:new {
		sampleLoaded = false,
		file = nil,
		fileName = nil,
		sampleName = nil,
		[LUA_CLASS_NAME] = "Zone"
	}
end
