function onProgramChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programList:setActiveProgram(value)
end

function onKeyGroupChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:changeKeyGroup(value)
end

function onVssChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:storeKgParamEdit(KG_VSS, mod, value)
end

function onKgDefaultParamChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:storeKgParamEdit(KG_DEFAULT, mod, value + math.abs(mod:getMinNonMapped()))
end

function onProgDefaultParamChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:storeProgParamEdit(PROG_DEFAULT, mod, value + math.abs(mod:getMinNonMapped()))
end

function onKgTuneChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:storeKgParamEdit(KG_TUNE, mod, value)

  local ll, mm = midiService:toTuneBytes(value)
  programController:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function onProgTuneChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:storeProgParamEdit(PROG_TUNE, mod, value)

  local ll, mm = midiService:toTuneBytes(value)
  programController:updateTuneLabel(mod:getProperty("name"), mm, ll)
end

function onKgStringChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:storeKgParamEdit(KG_STRING, mod, value)
end

function onProgStringChange(mod, value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  programController:storeProgParamEdit(PROG_STRING, mod, value)
end
