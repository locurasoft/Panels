local log = Logger("SampleList")

__SampleList = Dispatcher()

function __SampleList:sampleExists(name)
	return self.list[name]
end

function __SampleList:getSampleList()
	return self.list
end

function __SampleList:getSampleNames()
	local sampleListString = ""
	for k,v in pairs(self.list) do
		if sampleListString == "" then
			sampleListString = k
		else
			sampleListString = string.format("%s\n%s", sampleListString, k)
		end
	end
	return sampleListString
end

function __SampleList:addSample(name)
	self.list[name] = true
	table.sort(self.list)
	self:notifyListeners()
end

function __SampleList:addSamples(slist)
	local modified = false
	local sampleNames = slist:getSampleList()
	for k,v in pairs(sampleNames) do
		if not self:sampleExists(v) then
			self.list[v] = true
			modified = true
		end
	end
	table.sort(self.list)

	if modified then
		self:notifyListeners()
	end
end

function SampleList(data)
	return __SampleList:new {
		list = {},
		[LUA_CLASS_NAME] = "SampleList"
	}
end
