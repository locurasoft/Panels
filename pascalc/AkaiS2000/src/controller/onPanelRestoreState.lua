--
-- Called when data is restored
--
function onPanelRestoreState(stateData)
  for key, modelName in ipairs(MODEL_NAMES) do
    local varName = modelName:sub(1, 1):lower() .. modelName:sub(2)
    local data = stateData:getProperty(varName)
    if lutils.strNotEmpty(data) then
      _G[varName] = cson.decode(data)
    end
  end

  hxcService:setSettings(settings)
  s2kDieService:setSettings(settings)

  drumMapController:setDrumMap(drumMap)
  drumMapController:setSampleList(sampleList)
  programController:setProgramList(programList)
  sampleListController:setSampleList(sampleList)
  settingsController:setSettings(settings)

  onPanelLoaded()
end
