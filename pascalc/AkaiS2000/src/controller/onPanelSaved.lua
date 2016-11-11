function onPanelSaved(saveType, destinationFile)
  local modelState = cson.encode(settings)
  globalController:setText("settingsData", modelState)
end