function onProgramChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if value == 0 then
    value = 1
  end

  if programListModel:getNumPrograms() == 0 then
    return
  end

  programListModel:setActiveProgram(value)
end

function onKeyGroupChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  if value == 0 then
    value = 1
  end
  programCtrl:changeKeyGroup(value)
end

function onVssChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programListModel:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = keyGroupBlock[mod:getProperty("name")]
  local valueBlock = midiSrvc:toVssBlock(value)
  local khead = Khead(prog, kg, offset, valueBlock)

  midiSrvc:sendMidiMessage(khead)
  programSrvc:storeKgParamEdit(khead)
end

function onKgDefaultParamChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programListModel:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = keyGroupBlock[mod:getProperty("name")]
  local valueBlock = midiSrvc:toDefaultBlock(value + math.abs(mod:getMinNonMapped()))
  local khead = Khead(prog, kg, offset, valueBlock)

  --LOGGER:info("onKgDefaultParamChange %d => %s (%s)", value, mod:getProperty("name"), khead:toString())

  midiSrvc:sendMidiMessage(khead)
  programSrvc:storeKgParamEdit(khead)
end

function onProgDefaultParamChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programListModel:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local offset = programBlock[mod:getProperty("name")]
  local valueBlock = midiService:toDefaultBlock(value + math.abs(mod:getMinNonMapped()))
  local phead = PheadMsg(prog, offset, valueBlock)
  midiService:sendMidiMessage(phead)

  programSrvc:storeProgParamEdit(phead)
end

function onKgTuneChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programListModel:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = keyGroupBlock[mod:getProperty("name")]
  local valueBlock = midiSrvc:toTuneBlock(value)
  local khead = Khead(prog, kg, offset, valueBlock)

  midiSrvc:sendMidiMessage(khead)
  programSrvc:storeKgParamEdit(khead)
  local ll, mm = midiSrvc:toTuneBytes(value)
  programCtrl:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function onProgTuneChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programListModel:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local offset = programBlock[mod:getProperty("name")]
  local valueBlock = midiService:toTuneBlock(value)
  local phead = PheadMsg(prog, offset, valueBlock)

  midiService:sendMidiMessage(phead)

  programSrvc:storeProgParamEdit(phead)
  local ll, mm = midiService:toTuneBytes(value)
  programCtrl:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function onKgStringChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programListModel:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local kg = activeProg:getActiveKeyGroupIndex()
  local offset = keyGroupBlock[mod:getProperty("name")]
  local valueBlock = midiSrvc:toStringBlock(value)
  local khead = Khead(prog, kg, offset, valueBlock)

  midiSrvc:sendMidiMessage(khead)

  programSrvc:storeKgParamEdit(khead)
end

function onProgStringChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local activeProg = programListModel:getActiveProgram()
  if activeProg == nil then
    return
  end

  local prog = activeProg:getProgramNumber()
  local offset = programBlock[mod:getProperty("name")]
  local valueBlock = midiSrvc:toStringBlock(value)
  local phead = Phead(prog, offset, valueBlock)

  midiSrvc:sendMidiMessage(phead)

  programSrvc:storeProgParamEdit(phead)
end
