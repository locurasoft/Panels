local log = Logger("SampleListController")

__SampleListController = AbstractController()

function __SampleListController:setSampleList(sampleList)
	local sampleListListener = function(sl)
		self:updateSampleLists(sl)
	end
	sampleList:addListener(sampleListListener)
end

function __SampleListController:updateSampleLists(sampleList)
	local sampleNames = sampleList:getSampleNames()
	self:toggleVisibility("noSamplesLabel", sampleNames == "")
	self:toggleVisibility("noSamplesLabel-1", sampleNames == "")
	self:toggleVisibility("samplerFileList", sampleNames ~= "")
	self:toggleVisibility("samplerFileList-1", sampleNames ~= "")
	self:setListBoxContents("samplerFileList", sampleNames)
	self:setListBoxContents("samplerFileList-1", sampleNames)
	self:setComboBoxContents("zone1Selector", sampleNames)
	self:setComboBoxContents("zone2Selector", sampleNames)
	self:setComboBoxContents("zone3Selector", sampleNames)
	self:setComboBoxContents("zone4Selector", sampleNames)
end

function SampleListController()
	return newInstance(sampleList)
end
