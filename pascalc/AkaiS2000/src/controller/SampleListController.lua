require("AbstractController")
require("Logger")

local log = Logger("SampleListController")

SampleListController = {}
SampleListController.__index = SampleListController

setmetatable(SampleListController, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SampleListController:_init()
  AbstractController._init(self)
end

function SampleListController:setSampleList(sampleList)
  sampleList:addListener(self, "updateSampleLists")	
end

function SampleListController:updateSampleLists(sampleList)
	local sampleNames = sampleList:getSampleNames()
	self:toggleVisibility("noSamplesLabel", sampleNames == "")
	self:toggleVisibility("noSamplesLabel-1", sampleNames == "")
	self:toggleVisibility("samplerFileList", sampleNames ~= "")
	self:toggleVisibility("samplerSampleList", sampleNames ~= "")
	self:setListBoxContents("samplerFileList", sampleNames)
	self:setListBoxContents("samplerSampleList", sampleNames)
	self:setComboBoxContents("zone1Selector", sampleNames)
	self:setComboBoxContents("zone2Selector", sampleNames)
	self:setComboBoxContents("zone3Selector", sampleNames)
	self:setComboBoxContents("zone4Selector", sampleNames)
end
