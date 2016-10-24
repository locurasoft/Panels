require("AbstractController")
require("Logger")

local log = Logger("PanelController")
local PROGRAM, SAMPLE, DRUMMAP = 0, 1, 2

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
  panel:getComponent("wavSelector"):setProperty("uiFileListCurrentRoot",
    cutils.getUserHome(), false)
end

function PanelController:toggleEditor(visibleLayerIndex)

  if visibleLayerIndex == SAMPLE and editSample ~= nil then
    self:updateSampleEdit(editSample, true)
  elseif visibleLayerIndex == DRUMMAP then
    drumMapController:updateStatus("Select a sample and a key group")
    drumMapController:updateDrumMap(drumMap)
  end

  self:toggleLayerVisibility("ProgramBackground", visibleLayerIndex == PROGRAM)
  self:toggleLayerVisibility("ProgramControls", visibleLayerIndex == PROGRAM)
  self:toggleLayerVisibility("SampleBackground", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("Sample", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("SampleTrim", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("SampleLoop", visibleLayerIndex == SAMPLE)
  self:toggleLayerVisibility("Drummap", visibleLayerIndex == DRUMMAP)
end
