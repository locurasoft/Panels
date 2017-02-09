require("controller/AbstractS2kController")
require("Logger")

local log = Logger("SampleListController")

SampleListController = {}
SampleListController.__index = SampleListController

setmetatable(SampleListController, {
  __index = AbstractS2kController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SampleListController:_init()
  AbstractS2kController._init(self)
end

function SampleListController:setSampleList(sampleList)
  self.sampleList = sampleList
  sampleList:addListener(self, "updateSampleLists")
end

function SampleListController:updateSampleLists(sampleList)
  local sampleNames = sampleList:getSampleNames()
  self:toggleVisibility("noSamplesLabel", sampleList:isEmpty())
  self:toggleVisibility("noSamplesLabel-1", sampleList:isEmpty())
  self:toggleVisibility("samplerFileList", not sampleList:isEmpty())
  self:toggleVisibility("samplerSampleList", not sampleList:isEmpty())
  self:setListBoxContents("samplerFileList", sampleNames)
  self:setListBoxContents("samplerSampleList", sampleNames)
  for k = 1, 4 do
    self:setComboBoxContents(string.format("SNAME%d", k), sampleNames)
  end

  if not settings:getSampleTabsSelected() then
    if sampleList:isEmpty() then
      panel:getComponent("sampleTabs"):setProperty("uiTabsCurrentTab", 0, false)
    else
      panel:getComponent("sampleTabs"):setProperty("uiTabsCurrentTab", 1, false)
    end
  end
end

function SampleListController:toggleRsListButton(process)
  self:toggleActivation("receiveSampleList", not process:isRunning())
  if process:getState() == RECEIVING_SAMPLE_LIST then
    self:updateStatus("Receiving sample list...")
  elseif process:getState() == SAMPLE_LIST_RECEIVED then
    self:updateStatus("Sample list received.")
  else
  end
end

function SampleListController:onRslist(mod, value)
  local proc = RsListProcess(sampleList)
  proc:addListener(self, "toggleRsListButton")

  local status, err = pcall(ProcessController.execute, processController, proc)
  if not status then
    self:updateStatus(cutils.getErrorMessage(err))
  end
end
