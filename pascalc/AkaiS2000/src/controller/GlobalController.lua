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
end

--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--
function GlobalController:onMidiReceived(midi)
  midiService:dispatchMidi(midi:getData())
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

function GlobalController:onTest1(mod, value)
  local kgData = { 
    "F0 47 00 09 48 14 00 00 02 00 08 0A 06 06 08 01 07 03 00 00 04 0F 00 00 00 00 02 03 00 00 04 01 00 00 0F 05 00 00 08 02 00 00 00 00 00 00 03 0F 00 00 00 05 00 00 0C 03 00 00 00 00 00 00 06 0F 00 03 00 00 01 00 04 00 0F 0F 0F 0F 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0F 00 02 00 0A 00 01 00 0F 07 0C 00 00 00 00 00 00 00 0E 0C 00 00 0F 0F 0F 0F 00 04 08 06 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0F 00 02 00 0A 00 00 00 0F 07 04 0F 0F 0F 00 00 00 00 02 03 00 00 0F 0F 0F 0F 00 04 08 06 0D 01 0B 00 01 02 0E 01 09 01 09 01 0E 01 02 01 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 0A 01 0F 01 06 01 0D 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 06 02 03 00 00 04 01 00 00 00 00 03 06 00 00 03 06 00 00 0F 0F 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7",
    "F0 47 00 09 48 14 00 01 02 00 04 0B 06 06 08 03 0E 03 00 00 04 0F 00 00 00 00 02 03 00 00 04 01 00 00 0E 05 00 00 08 02 00 00 00 00 00 00 03 0F 00 00 00 05 00 00 0C 03 00 00 00 00 00 00 06 0F 00 03 00 00 01 00 04 00 0F 0F 0F 0F 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 02 00 0A 00 01 00 0F 07 0C 00 00 00 00 00 00 00 0E 0C 00 00 0F 0F 0F 0F 0C 04 08 06 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 02 00 0A 00 00 00 0F 07 04 0F 0F 0F 00 00 00 00 02 03 00 00 0F 0F 0F 0F 0C 04 08 06 0D 01 0B 00 01 02 0E 01 09 01 09 01 0E 01 02 01 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 0A 01 0F 01 06 01 0D 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 06 02 03 00 00 04 01 00 00 00 00 03 06 00 00 03 06 00 00 0F 0F 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7",
    "F0 47 00 09 48 14 00 02 02 00 00 0C 06 06 0F 03 04 04 00 00 04 0F 00 00 00 00 02 03 00 00 04 01 00 00 06 05 00 00 08 02 00 00 00 00 00 00 03 0F 00 00 0C 04 00 00 0C 03 00 00 00 00 00 00 06 0F 00 03 00 00 01 00 04 00 0F 0F 0F 0F 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0F 00 03 00 0A 00 01 00 0F 07 0C 00 00 00 00 00 00 00 0E 0C 00 00 0F 0F 0F 0F 08 05 08 06 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0F 00 03 00 0A 00 00 00 0F 07 04 0F 0F 0F 00 00 00 00 02 03 00 00 0F 0F 0F 0F 08 05 08 06 0D 01 0B 00 01 02 0E 01 09 01 09 01 0E 01 02 01 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 0A 01 0F 01 06 01 0D 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 06 02 03 00 00 04 01 00 00 00 00 03 06 00 00 03 06 00 00 0F 0F 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7",
    "F0 47 00 09 48 14 00 03 02 00 0C 0C 06 06 05 04 09 04 00 00 04 0F 00 00 00 00 02 03 00 00 04 01 00 00 03 05 00 00 08 02 00 00 00 00 00 00 03 0F 00 00 06 04 00 00 0C 03 00 00 00 00 00 00 06 0F 00 03 00 00 01 00 04 00 0F 0F 0F 0F 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 03 00 0A 00 01 00 0F 07 0C 00 00 00 00 00 00 00 0E 0C 00 00 0F 0F 0F 0F 04 06 08 06 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 03 00 0A 00 00 00 0F 07 04 0F 0F 0F 00 00 00 00 02 03 00 00 0F 0F 0F 0F 04 06 08 06 0D 01 0B 00 01 02 0E 01 09 01 09 01 0E 01 02 01 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 0A 01 0F 01 06 01 0D 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 06 02 03 00 00 04 01 00 00 00 00 03 06 00 00 03 06 00 00 0F 0F 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7",
    "F0 47 00 09 48 14 00 04 02 00 08 0D 06 06 0A 04 00 05 00 00 04 0F 00 00 00 00 02 03 00 00 04 01 00 00 03 05 00 00 08 02 00 00 00 00 00 00 03 0F 00 00 06 04 00 00 0C 03 00 00 00 00 00 00 06 0F 00 03 00 00 01 00 04 00 0F 0F 0F 0F 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0F 00 04 00 0A 00 01 00 0F 07 0C 00 00 00 00 00 00 00 0E 0C 00 00 0F 0F 0F 0F 00 07 08 06 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0F 00 04 00 0A 00 00 00 0F 07 04 0F 0F 0F 00 00 00 00 02 03 00 00 0F 0F 0F 0F 00 07 08 06 0D 01 0B 00 01 02 0E 01 09 01 09 01 0E 01 02 01 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 0A 01 0F 01 06 01 0D 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 06 02 03 00 00 04 01 00 00 00 00 03 06 00 00 03 06 00 00 0F 0F 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7",
    "F0 47 00 09 48 14 00 05 02 00 04 0E 06 06 01 05 07 05 00 00 04 0F 00 00 00 00 02 03 00 00 04 01 00 00 03 05 00 00 08 02 00 00 00 00 00 00 03 0F 00 00 06 04 00 00 0C 03 00 00 00 00 00 00 06 0F 00 03 00 00 01 00 04 00 0F 0F 0F 0F 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 04 00 0A 00 01 00 0F 07 0C 00 00 00 00 00 00 00 0E 0C 00 00 0F 0F 0F 0F 0C 07 08 06 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 04 00 0A 00 00 00 0F 07 04 0F 0F 0F 00 00 00 00 02 03 00 00 0F 0F 0F 0F 0C 07 08 06 0D 01 0B 00 01 02 0E 01 09 01 09 01 0E 01 02 01 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 0A 01 0F 01 06 01 0D 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 06 02 03 00 00 04 01 00 00 00 00 03 06 00 00 03 06 00 00 0F 0F 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7",
    "F0 47 00 09 48 14 00 05 02 00 04 0E 06 06 01 05 07 05 00 00 04 0F 00 00 00 00 02 03 00 00 04 01 00 00 03 05 00 00 08 02 00 00 00 00 00 00 03 0F 00 00 06 04 00 00 0C 03 00 00 00 00 00 00 06 0F 00 03 00 00 01 00 04 00 0F 0F 0F 0F 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 04 00 0A 00 01 00 0F 07 0C 00 00 00 00 00 00 00 0E 0C 00 00 0F 0F 0F 0F 0C 07 08 06 01 01 0C 00 0D 01 08 01 0A 00 03 00 03 00 05 00 0A 00 0B 00 04 00 0A 00 00 00 0F 07 04 0F 0F 0F 00 00 00 00 02 03 00 00 0F 0F 0F 0F 0C 07 08 06 0D 01 0B 00 01 02 0E 01 09 01 09 01 0E 01 02 01 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 0A 01 0F 01 06 01 0D 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 0F 0F 0F 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 06 02 03 00 00 04 01 00 00 00 00 03 06 00 00 03 06 00 00 0F 0F 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7"
  }
  
  local programData = "F0 47 00 07 48 14 00 01 00 00 0C 06 06 01 01 03 01 0C 00 0D 01 09 01 08 01 0A 00 0C 00 0B 00 0D 01 0D 01 02 00 03 01 00 00 0F 01 01 00 08 01 0F 07 00 00 00 00 03 06 00 00 0A 05 02 03 00 00 00 00 00 01 00 00 02 03 00 00 07 03 00 00 02 03 09 00 00 00 00 00 02 00 00 00 01 00 07 00 03 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 0A 00 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 05 00 00 00 00 02 00 00 00 00 00 06 00 08 00 01 00 06 00 03 00 06 00 06 00 06 00 05 00 03 00 0A 00 0A 00 05 00 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0C 03 00 00 00 00 00 00 00 00 0E 01 02 03 0E 01 0C 03 00 00 00 00 00 00 00 00 00 00 00 00 09 01 00 00 0F 0F 0F 0F 0D 01 03 01 08 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 00 00 0F 07 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 00 00 00 00 0D 01 0B 01 0F 01 0B 00 0C 01 0F 00 0A 00 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7"
  local pdata = PdataMsg(MemoryBlock(programData))
  local prog = Program(pdata)
  
  for k, v in ipairs(kgData) do
    local kdata = KdataMsg(MemoryBlock(v))
    prog:addKeyGroup(KeyGroup(kdata))
  end
  programList:addProgram(prog)
  programList:setActiveProgram(1)
--  onKeyGroupChange(panel:getModulatorByName("kgSelector"), 6)
--  onKeyGroupChange(panel:getModulatorByName("kgSelector"), 7)
  
end
