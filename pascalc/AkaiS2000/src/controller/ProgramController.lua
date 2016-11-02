require("AbstractController")
require("Logger")

--  pIndex = pIndex or self.programList:getActiveProgram()

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

  log:fine("Setting program selector max to %s", numPrograms)
  self:setMax("programSelector", numPrograms)
  local activeProgram = pl:getActiveProgram()
  if activeProgram == nil then
    self:setText("PRNAME", "")
    log:info("Active program is nil!")
  else
    log:info("Found active program!")
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

function ProgramController:changeKeyGroup(keyGroupIndex)
  if keyGroupIndex == 0 then
    keyGroupIndex = 1
  end

  if self.activeProgram == nil then
    log:info("Active program is nil! Disabling kg selector.")
    self:toggleActivation("kgSelector", false)
  else
    self.activeProgram:setActiveKeyGroupIndex(keyGroupIndex)
    self:assignKeyGroupValues(self.activeProgram, self.activeProgram:getActiveKeyGroupIndex())
  end
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
        local absValue = value + mod:getMinNonMapped()
        mod:setValue(absValue, true)
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
  for k,zone in pairs(keyGroup:getZones()) do
    local sampleName = zone:getSampleName()
    local selector = string.format("zone%dSelector", k)
    panel:getComponent(selector):setText(sampleName, true)
  end

  for k,v in pairs(KEY_GROUP_BLOCK) do
    local mod = panel:getModulatorByName(k)
    if mod ~= nil then
      local value = keyGroup:getParamValue(k)
      local minValue = mod:getMinNonMapped()
      local absValue = value + minValue
      if math.abs(minValue) > 256 then
        absValue = value
      end

      mod:setValue(absValue, true)
    end
  end
  keyGroup:setUpdating(false)
end

function ProgramController:storeProgParamEdit(blockType, mod, value)
  local program = self.programList:getActiveProgram()
  if program == nil then
    return
  end
  
  local phead = programService:phead(program, blockType, mod:getProperty("name"), value)
  midiService:sendMidiMessage(phead)

  program:storeParamEdit(phead)
end

function ProgramController:storeKgParamEdit(blockType, mod, value)
  local program = self.programList:getActiveProgram()
  if program == nil then
    return
  end
  
  local khead = programService:khead(program, blockType, mod:getProperty("name"), value)
  midiService:sendMidiMessage(khead)
  
  local keyGroup = program:getActiveKeyGroup()
  keyGroup:storeParamEdit(khead)
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

function ProgramController:storeParamEdit(indexGroup, headerOffs, values)
  local activeProg = self.programList:getActiveProgram()
  if activeProg ~= nil then
    if indexGroup == 0 then
      -- Program param
      activeProg:setPdataByte(mod:getModulatorName(), values[1])
    else
      -- Key Group param
      local activeKg = activeProg:getActiveKeyGroup()
      activeKg:storeNibbles(mod:getModulatorName(), midiService:toNibbles(values[1]))
    end
  end
end
