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

--function PatchService:getPatch(bank, patchNum)
--  local patch = Patch(bank, patchNum)
--
--  local pData = MemoryBlock(Voice_singleSize, true)
--  self.data:copyTo(pData, patchNum * Voice_singleSize, Voice_singleSize)
--  return Patch(pData)
--end

--function PatchService:putPatch(bank, single, patchNum)
--  if single:getSize() < Voice_singleSize then
--    log:warn("[WARN] single data %d is less than Voice_singleSize %d", single:getSize(), Voice_singleSize)
--    return
--  end
--
--  local patchOffset = patchNum * Voice_singleSize
--  log:warn("[Voice_putPatch] VoiceBankData %d, patchOffset %d", bank:getSize(), patchOffset)
--  local trimmedData = single:getRange(0, Voice_singleSize)
--  log:warn("[Voice_putPatch] trimmedDate %d", trimmedData:getSize())
--  bank:copyFrom(trimmedData, patchOffset, Voice_singleSize)
--end
