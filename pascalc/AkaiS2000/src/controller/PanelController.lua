require("AbstractController")
require("Logger")

local log = Logger("PanelController")

PanelController = {}
PanelController.__index = PanelController

setmetatable(PanelController, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function PanelController:_init()
  AbstractController._init(self)
  self:toggleLayerVisibility("Debug", false)
end

function PanelController:toggleEditor(visibleLayerIndex)
  local PROGRAM, SAMPLE, DRUMMAP = 0, 1, 2

  if visibleLayerIndex == SAMPLE and editSample ~= nil then
    self:updateSampleEdit(editSample, true)
  elseif visibleLayerIndex == DRUMMAP then
    drumMapCtrl:updateStatus("Select a sample and a key group")
    drumMapCtrl:updateDrumMap(drumMapModel)
  end

  self:toggleLayerVisibility("ProgramBackground", visibleLayerIndex == PROGRAM)
  self:toggleLayerVisibility("ProgramControls", visibleLayerIndex == PROGRAM)
  self:toggleLayerVisibility("SampleBackground", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("Sample", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("SampleTrim", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("SampleLoop", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("Drummap", visibleLayerIndex == DRUMMAP)
end

function PanelController:setFileSystemRoot(comp, path)
  comp:setProperty("uiFileListCurrentRoot", path, false)
end

function PanelController:initFileSystemPath(operatingSystem)
  local comp = panel:getComponent("wavSelector")
  self:setFileSystemRoot(comp, cutils.getUserHome())
end
