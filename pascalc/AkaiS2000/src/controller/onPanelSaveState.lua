--
-- Called when data needs saving
--
function onPanelSaveState(stateData)
  for key, modelName in ipairs(MODEL_NAMES) do
    local varName = modelName:sub(1, 1):lower() .. modelName:sub(2)
    local modelState = cson.encode(_G[varName])
    stateData:setProperty(varName, modelState, nil)
  end
end
