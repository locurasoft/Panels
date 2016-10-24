function onProgramChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if value == 0 then
    value = 1
  end

  if programList:getNumPrograms() == 0 then
    return
  end

  programList:setActiveProgram(value)
end

function onKeyGroupChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if value == 0 then
    value = 1
  end
  programController:changeKeyGroup(value)
end

function onVssChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programList:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = KEY_GROUP_BLOCK[mod:getProperty("name")]
  local valueBlock = midiService:toVssBlock(value)
  local khead = Khead(prog, kg, offset, valueBlock)

  midiService:sendMidiMessage(khead)
  programService:storeKgParamEdit(khead)
end

function onKgDefaultParamChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programList:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = KEY_GROUP_BLOCK[mod:getProperty("name")]
  local valueBlock = midiService:toDefaultBlock(value + math.abs(mod:getMinNonMapped()))
  local khead = Khead(prog, kg, offset, valueBlock)

  --LOGGER:info("onKgDefaultParamChange %d => %s (%s)", value, mod:getProperty("name"), khead:toString())

  midiService:sendMidiMessage(khead)
  programService:storeKgParamEdit(khead)
end

function onProgDefaultParamChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programList:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local offset = PROGRAM_BLOCK[mod:getProperty("name")]
  local valueBlock = midiService:toDefaultBlock(value + math.abs(mod:getMinNonMapped()))
  local phead = PheadMsg(prog, offset, valueBlock)
  midiService:sendMidiMessage(phead)

  programService:storeProgParamEdit(phead)
end

function onKgTuneChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programList:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = KEY_GROUP_BLOCK[mod:getProperty("name")]
  local valueBlock = midiService:toTuneBlock(value)
  local khead = Khead(prog, kg, offset, valueBlock)

  midiService:sendMidiMessage(khead)
  programService:storeKgParamEdit(khead)
  local ll, mm = midiService:toTuneBytes(value)
  programController:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function onProgTuneChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programList:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local offset = PROGRAM_BLOCK[mod:getProperty("name")]
  local valueBlock = midiService:toTuneBlock(value)
  local phead = PheadMsg(prog, offset, valueBlock)

  midiService:sendMidiMessage(phead)

  programService:storeProgParamEdit(phead)
  local ll, mm = midiService:toTuneBytes(value)
  programController:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function onKgStringChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programList:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = KEY_GROUP_BLOCK[mod:getProperty("name")]
  local valueBlock = midiService:toStringBlock(value)
  local khead = Khead(prog, kg, offset, valueBlock)

  midiService:sendMidiMessage(khead)

  programService:storeKgParamEdit(khead)
end

function onProgStringChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programList:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local offset = PROGRAM_BLOCK[mod:getProperty("name")]
  local valueBlock = midiService:toStringBlock(value)
  local phead = Phead(prog, offset, valueBlock)

  midiService:sendMidiMessage(phead)

  programService:storeProgParamEdit(phead)
end
