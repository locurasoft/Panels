require("LuaObject")
require("Logger")
require("lutils")
require("mutils")

local log = Logger("PatchService")

local PATCH_NAME_OFFSET = 384
local PATCH_NAME_LENGTH = 18

local UPPER_TONE_OFFSET = 128
local LOWER_TONE_OFFSET = 320
local TONE_NAME_LENGTH = 10

PatchService = {}
PatchService.__index = PatchService

setmetatable(PatchService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
--@module __PatchService
function PatchService:_init()
  LuaObject._init(self)
  self.VoiceBankData = nil
  self.VoiceReverbData = nil
end

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
function PatchService:getPatchName(data, patchNameStart, patchNameSize)
  local name = ""
  local symbols = {" ","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0","-"}
  for i = patchNameStart,(patchNameStart + patchNameSize - 1) do -- gets the voice name
    local midiParam = data:getByte(i)
    name = string.format("%s%s", name, symbols[midiParam + 1]) -- Lua tables are base 1 indexed
  end
  return name
end

-- This method set the values of the hidden char modulators
-- to match the given name
function PatchService:setPatchName(mod, patchName)
  local modulatorName = mod:getOwner():getModulatorName()

  local start = 0
  local length = 0
  if modulatorName == "Name1" then
    start = PATCH_NAME_OFFSET
    length = PATCH_NAME_LENGTH
  elseif modulatorName == "VoiceName12" then
    start = UPPER_TONE_OFFSET
    length = TONE_NAME_LENGTH
  elseif modulatorName == "VoiceName123" then
    start = LOWER_TONE_OFFSET
    length = TONE_NAME_LENGTH
  end

  local patchNameLength = string.len(patchName)
  local symbols = {[" "] = 0,["-"] = 63,["0"] = 62,["1"] = 53,["2"] = 54,["3"] = 55,["4"] = 56,["5"] = 57,["6"] = 58,["7"] = 59,["8"] = 60,["9"] = 61,["A"] = 1,["B"] = 2,["C"] = 3,["D"] = 4,["E"] = 5,["F"] = 6,["G"] = 7,["H"] = 8,["I"] = 9,["J"] = 10,["K"] = 11,["L"] = 12,["M"] = 13,["N"] = 14,["O"] = 15,["P"] = 16,["Q"] = 17,["R"] = 18,["S"] = 19,["T"] = 20,["U"] = 21,["V"] = 22,["W"] = 23,["X"] = 24,["Y"] = 25,["Z"] = 26,["a"] = 27,["b"] = 28,["c"] = 29,["d"] = 30,["e"] = 31,["f"] = 32,["g"] = 33,["h"] = 34,["i"] = 35,["j"] = 36,["k"] = 37,["l"] = 38,["m"] = 39,["n"] = 40,["o"] = 41,["p"] = 42,["q"] = 43,["r"] = 44,["s"] = 45,["t"] = 46,["u"] = 47,["v"] = 48,["w"] = 49,["x"] = 50,["y"] = 51,["z"] = 52}
  local emptyChar = symbols[" "]
  local patchNameEnd = start + length - 1
  local patchNameIndex = 0
  for i = start, patchNameEnd do
    local name = "Voice"..i
    local mod = panel:getModulatorWithProperty("modulatorCustomName", name)
    if patchNameLength > patchNameIndex then
      local caracter = string.sub(patchName, patchNameIndex + 1, patchNameIndex + 1)
      mod:setValue(symbols[caracter], true)
    else
      mod:setValue(emptyChar, true)
    end
    patchNameIndex = patchNameIndex + 1
  end

  local patchSelectMod = panel:getModulatorByName("Voice_PatchSelectControl")
  local patchSelect = patchSelectMod:getComponent()
  if modulatorName == "Name1"
    and VoiceBankData ~= nil
    and patchSelect:getProperty("componentDisabled") == 0
    and Voice_SelectedPatchIndex >= 0
    and table.getn(VoicePatchNames) > 0
    and VoicePatchNames[Voice_SelectedPatchIndex + 1] ~= patchName  then
    VoicePatchNames[Voice_SelectedPatchIndex + 1] = patchName
  end
end

function PatchService:getNumberedPatchNamesList(bank)
  local patchNames = ""
  for i = 0, 63 do
    if i > 0 then
      patchNames = string.format("%s\n", patchNames)
    end
    patchNames = string.format("%s%d %s=%d", patchNames, i, self:getPatch(bank, i):getPatchName(), i)
  end
  return patchNames:gsub("'", "")
end

function PatchService:getPatch(bank, patchNum)
  local patch = Patch(bank, patchNum)

  local pData = MemoryBlock(Voice_singleSize, true)
  self.data:copyTo(pData, patchNum * Voice_singleSize, Voice_singleSize)
  return Patch(pData)
end

function PatchService:putPatch(bank, single, patchNum)
  if single:getSize() < Voice_singleSize then
    log:warn("[WARN] single data %d is less than Voice_singleSize %d", single:getSize(), Voice_singleSize)
    return
  end

  local patchOffset = patchNum * Voice_singleSize
  log:warn("[Voice_putPatch] VoiceBankData %d, patchOffset %d", bank:getSize(), patchOffset)
  local trimmedData = single:getRange(0, Voice_singleSize)
  log:warn("[Voice_putPatch] trimmedDate %d", trimmedData:getSize())
  bank:copyFrom(trimmedData, patchOffset, Voice_singleSize)
end

function PatchService:isSingleSizeData(data)
end

function PatchService:newBank(bankData)
  local data = midiService:trimSyxData(bankData)
  assert(data:getSize() ~= Voice_singleSize * 64, string.format("Data does not contain a Roland D50 bank"))
  return Bank(data)
end

function PatchService:newPatch(patchData)
  local data = midiService:trimSyxData(patchData)
  assert(data:getSize() ~= Voice_singleSize, string.format("midiSize %d is invalid and cannot be assigned to controllers", data:getSize()))
  return Patch(data)
end
