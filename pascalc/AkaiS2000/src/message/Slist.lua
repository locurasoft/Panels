local numSamplesOffs = 5
local sampleNameOffs = 7

__SlistMsg = SyxMsg()

function __SlistMsg:getNumSamples()
	return self.data:getByte(numSamplesOffs)
end

function __SlistMsg:getSampleList()
	local offset = sampleNameOffs
	local numSamples = self:getNumSamples()
	local buf = MemoryBlock(SAMPLE_NAME_LENG, true)
	local sampleNames = {}

	while offset + SAMPLE_NAME_LENG < self.data:getSize() do
		self.data:copyTo(buf, offset, SAMPLE_NAME_LENG)
		offset = offset + SAMPLE_NAME_LENG
		local name = midiSrvc:fromAkaiString(buf)
		--self.log:fine("Sample Name: %s", name)
		table.insert(sampleNames, name)
	end
	return sampleNames
end

function Slist(bytes)
	local logger = Logger("SlistMsg")
	if bytes:getByte(3) == 0x05 then
		return __SlistMsg:new{ data = bytes, log = logger }
	else
		logger:info("Not a slist msg")
		return nil
	end
end
