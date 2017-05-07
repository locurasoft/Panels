require("controller/AbstractS2kController")
require("Logger")
require("cutils")

local log = Logger("ProgramController")

ProgramController = {}
ProgramController.__index = ProgramController

setmetatable(ProgramController, {
  __index = AbstractS2kController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ProgramController:_init()
  AbstractS2kController._init(self)
end

function ProgramController:setProgramList(programList)
  self.programList = programList
  programList:addListener(self, "updateProgramList")
end

function ProgramController:updateTuneLabel(modName, value)
  local cent, semi = midiService:toTuneBytes(value)
  local sign = ""
  if semi == 0 and value < 0 then
    sign = "-"
  end
  self:setText(string.format("%s-LBL", modName), string.format("%s%02d.%02d", sign, semi, cent))
end

function ProgramController:updateProgramList(pl)
  -- update program and keygroup selectors
  local numPrograms = pl:getNumPrograms()
  if numPrograms < 1 then
    self:toggleActivation("programSelector", false)
    self:updateStatus("Please load a program")
    return
  elseif pl:getActiveProgram() == nil then
    pl:setActiveProgram(1)
  end

  self:setMax("programSelector", numPrograms)
  self:changeProgram(pl:getActiveProgram())
end

function ProgramController:changeProgram(newProgram)
  if self.activeProgram == nil then
    log:info("Active program is nil! Disabling prog selector.")
    self:toggleActivation("programSelector", false)
    self:updateStatus("Please load a program")
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

  for k,v in pairs(KEY_GROUP_BLOCK) do
    local mod = panel:getModulatorByName(k)
    if mod ~= nil then
      local value = keyGroup:getParamValue(k)
      if type(value) == "string" then
        mod:getComponent():setText(value, true)
      else
        local minValue = mod:getMinNonMapped()
        mod:setValue(programService:getAbsoluteParamValue(k, value, minValue), true)
      end
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
    log:warn(cutils.getErrorMessage(phead))
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
    log:warn(cutils.getErrorMessage(khead))
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
    self:updateStatus("Please load a program")
  else
    self.activeProgram:setActiveKeyGroupIndex(value)
    self:assignKeyGroupValues(self.activeProgram, self.activeProgram:getActiveKeyGroupIndex())
  end
end

function ProgramController:onVssChange(mod, value)
  self:storeKgParamEdit(KG_VSS, mod, value)
end

function ProgramController:onKgDefaultParamChange(mod, value)
  if mod:getMinNonMapped() > 0 then
    value = value - mod:getMinNonMapped()
  elseif mod:getProperty("name") == "LONOTE" or mod:getProperty("name") == "HINOTE" then
    value = value + 24
  end
  self:storeKgParamEdit(KG_DEFAULT, mod, value)
end

function ProgramController:onProgDefaultParamChange(mod, value)
  if mod:getMinNonMapped() > 0 then
    value = value - mod:getMinNonMapped()
  end
  self:storeProgParamEdit(PROG_DEFAULT, mod, value)
end

function ProgramController:onKgTuneChange(mod, value)
  self:storeKgParamEdit(KG_TUNE, mod, value)

  self:updateTuneLabel(mod:getProperty("name"), value)
end

function ProgramController:onProgTuneChange(mod, value)
  self:storeProgParamEdit(PROG_TUNE, mod, value)

  self:updateTuneLabel(mod:getProperty("name"), value)
end

function ProgramController:onKgStringChange(mod, value)
  self:storeKgParamEdit(KG_STRING, mod, value)
end

function ProgramController:onKgFilqChange(mod, value)
  self:storeKgParamEdit(KG_FILQ, mod, value)
end

function ProgramController:onProgStringChange(mod, value)
  self:storeProgParamEdit(PROG_STRING, mod, value)
end

function ProgramController:rpListProcessUpdate(process)
  self:toggleActivation("receiveSampleList", not process:isRunning())
  if process:getState() == RECEIVING_PROGRAMS then
    self:updateStatus("Receiving programs...")
  elseif process:getState() == PROGRAMS_RECEIVED then
    local progs = process:getPrograms()
    programList:clear()
    for k, v in ipairs(progs) do
      programList:addProgram(v)
    end
    self:updateStatus("Programs received.")
  elseif process:getState() == RECEIVING_PROGRAMS_FAILED then
    self:updateStatus("Receiving programs failed!")
  end
end

function ProgramController:onRpList(mod, value)
  local q = utils.questionWindow("Clear memory", "This action will clear the panel's program list", "OK", "Cancel")
  if q then
    local proc = ReceivedProgramsProcess()
    proc:addListener(self, "rpListProcessUpdate")

    local status, err = pcall(ProcessController.execute, processController, proc)
    if not status then
      self:updateStatus(cutils.getErrorMessage(err))
    end
  end
end
