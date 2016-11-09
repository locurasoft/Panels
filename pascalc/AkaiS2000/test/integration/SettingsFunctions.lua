function onFloppyImageCleared()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  floppyImgPath = nil
  panel:getComponent("loadFloppyImageLabel"):setText("")

  local launchButtonState = drumMap:getLaunchButtonState()

  drumMapController:toggleActivation("transferSamples", launchButtonState ~= "")

  if launchButtonState  ~= "" then
    drumMapController:updateStatus(launchButtonState)
  end
end

function onFloppyImageSelected()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local floppyImgPath = utils.openFileWindow("Select floppy image", File.getSpecialLocation(File.userHomeDirectory), "*.img", true)
  settingsController:selectFloppyImage(floppyImgPath)
end

function onTransferMethodChange(value)
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end
  
  settingsController:changeTransferMethod(value)
end

function onSetfdprmPathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local setfdprmPath = utils.openFileWindow("Select setfdprm path", File.getSpecialLocation(File.userHomeDirectory), "*", true)
  settingsController:changeSetfdprmPath(setfdprmPath)
end

function onHxcPathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local filePatternsAllowed = "*"
  if operatingsystem == "win" then
    filePatternsAllowed = "*.exe"
  end

  local hxcPath = utils.openFileWindow("Select hxcfe executable", File.getSpecialLocation(File.userHomeDirectory),
    filePatternsAllowed, true)
  settingsController:changeHxcPath(hxcPath)
end

function onS2kDiePathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local s2kDiePath = utils.openFileWindow("Select s2kDie folder", File.getSpecialLocation(File.userHomeDirectory), "*.php", true)
  settingsController:changeS2kDiePath(s2kDiePath)
end

function onWorkPathChange()
  -- This variable stops index issues during panel bootup
  if panel:getBootstrapState() or panel:getProgramState() then
    return
  end

  local workFolder = utils.getDirectoryWindow("Select work folder", File.getSpecialLocation(File.userHomeDirectory))
  settingsController:changeWorkPath(workFolder)
end
