function onPanelLoaded()
  panel:getModulatorByName("editorSelector"):setValue(0, true)
  globalController:toggleLayerVisibility("Debug", false)
  globalController:toggleVisibility("settingsData", false)
  globalController:setValue("panelState", cutils.STATE_PROD)
  globalController:setValue("logLevelCombo", WARN)

  local settingsData = globalController:getText("settingsData")
  if lutils.strNotEmpty(settingsData) then
    settings = cson.decode(settingsData)
  end
  
  hxcService:setSettings(settings)
  s2kDieService:setSettings(settings)
  settingsController:setSettings(settings)

end
