require("controller/AbstractS2kController")
require("Logger")

local log = Logger("GlobalController")
local PROGRAM, SAMPLE, DRUMMAP = 0, 1, 2
local INTELL_TYPE, CYCLIC_TYPE = 0, 1

GlobalController = {}
GlobalController.__index = GlobalController

setmetatable(GlobalController, {
  __index = AbstractS2kController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function GlobalController:_init()
  AbstractS2kController._init(self)
  self.on_midi_received_func = nil
end

function GlobalController:clearMidiReceived()
  self.on_midi_received_func = nil
end

function GlobalController:setMidiReceived(midiCallback)
  self.on_midi_received_func = midiCallback
end

--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--
function GlobalController:onMidiReceived(midi)
  local data = midi:getData()
  if data:getByte(0) ~= 0xF0 or data:getByte(1) ~= 0x47 then
    log:info("Invalid S2K Sysex received!")
    return
  end
  if self.on_midi_received_func ~= nil then
    self.on_midi_received_func(data)
  end
end

--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function GlobalController:onToggleEditor(mod, value)
  sampleListController:updateSampleLists(sampleList)
  if value == SAMPLE and editSample ~= nil then
    self:updateSampleEdit(editSample, true)
  elseif value == DRUMMAP then
    drumMapController:updateStatus("Select a sample and a key group")
    drumMapController:updateDrumMap(drumMap)
  elseif value == PROGRAM then
    programController:updateProgramList(programList)
  end

  self:toggleLayerVisibility("ProgramBackground", value == PROGRAM)
  self:toggleLayerVisibility("ProgramControls", value == PROGRAM)
  self:toggleLayerVisibility("SampleBackground", value == SAMPLE)
  self:toggleLayerVisibility("Sample", value == SAMPLE)
  self:toggleLayerVisibility("SampleTrim", value == SAMPLE)
  self:toggleLayerVisibility("SampleLoop", value == SAMPLE)
  self:toggleLayerVisibility("Drummap", value == DRUMMAP)
end

--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function GlobalController:onLogLevelChanged(mod, value)
  log:setLevel(value)
end

--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function GlobalController:onPanelStateChanged(mod, value)
  panelState = value
  log:info("[onPanelStateChanged] %d", panelState)
end

----
---- Called when a modulator value changes
---- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
---- @value    new numeric value of the modulator
----
--function GlobalController:onTest1(mod, value)
--  local getModulator = function(modName)
--    return panel:getModulatorByName(modName)
--  end
--
--  local json = "{'apa':[" ..
--    "{'methodName':'onToggleEditor', 'modulator':'editorSelector', 'value':2}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onDrumMapProgramNameChange', 'component':'programCreateNameLbl', 'content':'Test2'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onPadSelected', 'component':'drumMap-1'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onSamplesTabChanged', 'modulator':'sampleTabs', 'value':1}," ..
--    "{'methodName':'onSampleSelected', 'component':'samplerSampleList'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onSampleSelected', 'component':'samplerSampleList'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'loadstring', 'code':'panel:getComponent(\"samplerSampleList\"):setComponentText(\"DRILL.WAV -R\")'}," ..
--    "{'methodName':'onSampleDoubleClicked', 'component':'samplerSampleList'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onSampleSelected', 'component':'samplerSampleList'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onSampleSelected', 'component':'samplerSampleList'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onSampleDoubleClicked', 'component':'samplerSampleList'}," ..
--    "{'methodName':'onKeyGroupNumChange', 'modulator':'numKeyGroups', 'value':16}," ..
--    "{'methodName':'onCreateProgram', 'modulator':'createProgramBtn', 'value':0}," ..
--    "{'methodName':'onProgramChange', 'modulator':'programSelector', 'value':0}" ..
--    "]}"
--
--  local callObject = cson.decode(json)
--  local callQueue = callObject['apa']
--  for k, v in ipairs(callQueue) do
--    local methodName = v['methodName']
--    if methodName == "sleep" then
--      io.write("Waiting for <ENTER>...\n")
--      local s = io.read()
--      console(s)
--    elseif methodName == "loadstring" then
--      loadstring(v['code'])()
--    elseif v['modulator'] ~= nil and v['value'] ~= nil then
--      _G[methodName](getModulator(v['modulator']), tonumber(v['value']))
--    elseif v['modulator'] ~= nil and v['file'] ~= nil then
--      _G[methodName](getModulator(v['modulator']), File(v['file']))
--    elseif v['modulator'] ~= nil and v['sample'] ~= nil then
--      _G[methodName](getModulator(v['modulator']), v['sample'])
--    elseif v['component'] ~= nil and v['content'] ~= nil then
--      _G[methodName](getModulator(v['component']):getComponent(), v['content'])
--    elseif v['component'] ~= nil then
--      _G[methodName](getModulator(v['component']):getComponent())
--    end
--  end
--end
