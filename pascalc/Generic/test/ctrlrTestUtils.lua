require("ctrlrsdk")
require 'lunity'
require 'cutils'

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

  --panel:debugPrint()
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

--  panel:debugPrint()
  for k,v in pairs(expectedModulatorMap) do
    lunity.assertEqual(panel:getModulatorByName(k):getValue(), v)
  end
end

function compareLoadedBankWithFile(controllerInst, file, panel, numPatches)
  local sa = StringArray()
  sa:add(file)
  onFilesDroppedToPanel(sa, 0, 0)

  for i = 0, numPatches - 1 do
    controllerInst:onPatchSelect(panel:getModulatorByName("patchSelect"), i)
  end

  for i = 0, numPatches - 1 do
    controllerInst:onPatchSelect(panel:getModulatorByName("patchSelect"), numPatches - 1 - i)
  end

  local data = MemoryBlock()
  File(file):loadFileAsData(data)
  local expected = data:toHexString(1)
  local actual = controllerInst.bank:toStandaloneData():toHexString(1)
  lunity.assertEqual(expected:len(), actual:len())
  local i = 0
  while i < expected:len() do
    lunity.assertEqual(expected:sub(i, 110), actual:sub(i, 110))
    i = i + 110
  end  
end

function compareEditedBankWithFile(controllerInst, origFile, panel, editModMap, expectedFile)
  local sa = StringArray()
  sa:add(origFile)
  onFilesDroppedToPanel(sa, 0, 0)
  
  for k, v in pairs(editModMap) do
    panel:getModulatorByName(k):setValue(v)
  end
  
  local patch = controllerInst.bank:getSelectedPatch()
  controllerInst:v2p(patch)

  local data = MemoryBlock()
  File(expectedFile):loadFileAsData(data)
  local expected = data:toHexString(1)
  local actual = controllerInst.bank:toStandaloneData():toHexString(1)
  cutils.writeToFile("../actual.txt", actual)
  cutils.writeToFile("../expected.txt", expected)
  lunity.assertEqual(expected, actual)
  os.remove("../actual.txt")
  os.remove("../expected.txt")
end
