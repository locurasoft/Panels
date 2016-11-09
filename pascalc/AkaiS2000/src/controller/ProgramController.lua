require("AbstractController")
require("Logger")
require("lutils")

local log = Logger("ProgramController")

ProgramController = {}
ProgramController.__index = ProgramController

setmetatable(ProgramController, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ProgramController:_init(programList)
  AbstractController._init(self)
  self.programList = programList
  programList:addListener(self, "updateProgramList")
end

function ProgramController:updateTuneLabel(modName, semi, cent)
  self:setText(string.format("%s-LBL", modName), string.format("%02d.%02d", semi, cent))
end

function ProgramController:updateProgramList(pl)
  -- update program and keygroup selectors
  local numPrograms = pl:getNumPrograms()
  if numPrograms < 1 then
    self:toggleActivation("programSelector", false)
    self:setText("PRNAME", "Please load a program")
    return
  end

  self:setMax("programSelector", numPrograms)
  local activeProgram = pl:getActiveProgram()
  if activeProgram == nil then
    self:setText("PRNAME", "")
  else
    self:changeProgram(activeProgram)
  end
end

function ProgramController:changeProgram(newProgram)
  if self.activeProgram == nil then
    log:info("Active program is nil! Disabling prog selector.")
    self:toggleActivation("programSelector", false)
  else
    self.activeProgram:removeListener(self.programListenerId)
  end
  self.programListenerId = newProgram:addListener(self, "assignProgramValues")
  self.activeProgram = newProgram
  self:assignProgramValues(newProgram)
end

function ProgramController:assignProgramValues(program)
  program:setUpdating(true)
  self:setText("PRNAME", program:getName())

  if self.programList:getNumPrograms() > 1 then
    self:toggleActivation("programSelector", true)
  end

  self:toggleActivation("kgSelector", true)
  self:setMax("kgSelector", program:getNumKeyGroups())
  local currKg = self:getValue("kgSelector")
  if program:getActiveKeyGroupIndex() == currKg then
    self:assignKeyGroupValues(self.activeProgram, self.activeProgram:getActiveKeyGroupIndex())
  else
    self:setValue("kgSelector", program:getActiveKeyGroupIndex())
  end
  for k,v in pairs(PROGRAM_BLOCK) do
    local mod = panel:getModulatorByName(k)
    if mod ~= nil then
      local value = program:getParamValue(k)
      if type(value) == "string" then
        mod:getComponent():setText(value)
      else
        local minValue = mod:getMinNonMapped()
        mod:setValue(programService:getAbsoluteParamValue(k, value, minValue), true)
      end
    end
  end
  program:setUpdating(false)
end

function ProgramController:assignKeyGroupValues(program, kgIndex)
  local keyGroup = program:getKeyGroup(kgIndex)

  -- TODO: Why is this necessary?
  if keyGroup == nil then
    return
  end
  keyGroup:setUpdating(true)
  local zones = keyGroup:getZones()
  for k = 1, 4 do
    local sampleName = ""
    if zones[k] ~= nil then
      sampleName = zones[k]:getSampleName()
    end
    local selector = string.format("zone%dSelector", k)
    panel:getComponent(selector):setText(sampleName, true)
  end

  for k,v in pairs(KEY_GROUP_BLOCK) do
    local mod = panel:getModulatorByName(k)
    if mod ~= nil then
      local value = keyGroup:getParamValue(k)
      local minValue = mod:getMinNonMapped()
      mod:setValue(programService:getAbsoluteParamValue(k, value, minValue), true)
    end
  end
  keyGroup:setUpdating(false)
end

function ProgramController:storeProgParamEdit(blockType, mod, value)
  local program = self.programList:getActiveProgram()
  if program == nil then
    return
  end

  local status, phead = pcall(ProgramService.phead, programService, program, blockType, mod:getProperty("name"), value)
  if status then
    midiService:sendMidiMessage(phead)
    program:storeParamEdit(phead)
  else
    log:warn(lutils.getErrorMessage(phead))
  end
end

function ProgramController:storeKgParamEdit(blockType, mod, value)
  local program = self.programList:getActiveProgram()
  if program == nil then
    return
  end

  local status, khead = pcall(ProgramService.khead, programService, program, blockType, mod:getProperty("name"), value)
  if status then
    midiService:sendMidiMessage(khead)
    local keyGroup = program:getActiveKeyGroup()
    keyGroup:storeParamEdit(khead)
  else
    log:warn(lutils.getErrorMessage(khead))
  end
end

function ProgramController:getActiveKeyGroupMessage()
  local pIndex = self.programList:getActiveProgram()
  local kIndex = self.programList:getActiveKeyGroup()
  return self:getKeyGroupMessage(pIndex, kIndex)
end

function ProgramController:getKeyGroupMessage(pIndex, kIndex)
  local program = self.programList[pIndex]
  local keyGroup = program:getKeyGroup(kIndex)
  return keyGroup:getKdata()
end

function ProgramController:getActiveProgramMessagesList()
  local pIndex = self.programList:getActiveProgram()

  return self:getProgramMessagesList(pIndex)
end

function ProgramController:onProgramChange(mod, value)
  programList:setActiveProgram(value)
end

function ProgramController:onKeyGroupChange(mod, value)
  if value == 0 then
    value = 1
  end

  if self.activeProgram == nil then
    log:info("Active program is nil! Disabling kg selector.")
    self:toggleActivation("kgSelector", false)
  else
    self.activeProgram:setActiveKeyGroupIndex(value)
    self:assignKeyGroupValues(self.activeProgram, self.activeProgram:getActiveKeyGroupIndex())
  end
end

function ProgramController:onVssChange(mod, value)
  self:storeKgParamEdit(KG_VSS, mod, value)
end

function ProgramController:onKgDefaultParamChange(mod, value)
  self:storeKgParamEdit(KG_DEFAULT, mod, value + math.abs(mod:getMinNonMapped()))
end

function ProgramController:onProgDefaultParamChange(mod, value)
  self:storeProgParamEdit(PROG_DEFAULT, mod, value - mod:getMinNonMapped())
end

function ProgramController:onKgTuneChange(mod, value)
  self:storeKgParamEdit(KG_TUNE, mod, value)

  local ll, mm = midiService:toTuneBytes(value)
  self:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function ProgramController:onProgTuneChange(mod, value)
  self:storeProgParamEdit(PROG_TUNE, mod, value)

  local ll, mm = midiService:toTuneBytes(value)
  self:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function ProgramController:onKgStringChange(mod, value)
  self:storeKgParamEdit(KG_STRING, mod, value)
end

function ProgramController:onProgStringChange(mod, value)
  self:storeProgParamEdit(PROG_STRING, mod, value)
end
