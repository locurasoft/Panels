require("ctrlrsdk")
require 'lunity'

LUA_CONTRUCTOR_NAME = "LUA_CLASS_NAME"

function console(var)
  print(var)
end

function regGlobal(name, value)
  _G[name] = value
end

function delGlobal(name)
  _G[name] = nil
end

function loadPatchFromFile(file, panel, expectedModulatorMap, patchNameMod, expectedPatchName)
  local sa = StringArray()
  sa:add(file)
  onFilesDroppedToPanel(sa, 0, 0)

  for k,v in pairs(expectedModulatorMap) do
    lunity.assertEqual(panel:getModulatorByName(k):getValue(), v)
  end
  local nameMod = panel:getModulatorByName(patchNameMod)
  lunity.assertEqual(nameMod:getComponent():getText(), expectedPatchName)
end

function loadBankFromFile(controllerInst, file, panel, expectedModulatorMap, patchNameMod, expectedPatchNameMap)
  local sa = StringArray()
  sa:add(file)
  onFilesDroppedToPanel(sa, 0, 0)
  
  controllerInst:onPatchSelect(panel:getModulatorByName("patchSelect"), 1)
  local nameMod = panel:getModulatorByName(patchNameMod)
  lunity.assertEqual(nameMod:getComponent():getText(), expectedPatchNameMap[2])

  controllerInst:onPatchSelect(panel:getModulatorByName("patchSelect"), 0)
  local nameMod = panel:getModulatorByName(patchNameMod)
  lunity.assertEqual(nameMod:getComponent():getText(), expectedPatchNameMap[1])

  --panel:debugPrint()
  for k,v in pairs(expectedModulatorMap) do
    lunity.assertEqual(panel:getModulatorByName(k):getValue(), v)
  end

end

