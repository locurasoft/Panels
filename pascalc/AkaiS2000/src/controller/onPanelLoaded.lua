function onPanelLoaded()
  panel:getModulatorByName("editorSelector"):setValue(0, true)
  globalController:toggleLayerVisibility("Debug", false)
end