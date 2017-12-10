require("LuaObject")
require("Logger")
require("lutils")

local getSliderContentFromSequence = function(min, max)
  local contents = ""
  for i = min, max do
    contents = string.format("%s\n%d", contents, i)
  end
  return contents
end

local getSliderContentFromArray = function(array)
  local contents = ""
  for i = 1, table.getn(array) do
    contents = string.format("%s\n%s", contents, array[i])
  end
  return contents
end

---
-- @field [parent=#EffectParamService] log
--
local log = Logger("EffectParamService")

EffectParamService = {}
EffectParamService.__index = EffectParamService

setmetatable(EffectParamService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#EffectParamService] _init
--
function EffectParamService:_init(effectParams, effectParamValues, defaultEffectIndex)
  LuaObject._init(self)
  self.effectParams       = effectParams
  self.effectParamValues  = effectParamValues
  self.defaultEffectIndex = defaultEffectIndex
end

---
-- @function [parent=#EffectParamService] onEffectTypeChanged
--
function EffectParamService:getEffectData(effectIndex, paramIndex)
  local effectParamList = self.effectParams[self.defaultEffectIndex]
  if effectIndex > 0 then
    effectParamList = self.effectParams[string.format("0x%.2X", effectIndex)]
  end
  if effectParamList == nil then
    effectParamList = self.effectParams[self.defaultEffectIndex]
  end

  local paramValues = lutils.split(effectParamList[paramIndex], ":")
  if table.getn(paramValues) ~= 5 then
    error(string.format("Invalid param value string '%s'", effectParamList[paramIndex]))
  end

  local name = paramValues[1]
  if name == "" then
    return nil
  else
    local dataArrayIndex = paramValues[2]
    local min = paramValues[3]
    local max = paramValues[4]
    -- TODO: Take offset into account
    local offset = paramValues[5]

    local sliderContents = ""
    if dataArrayIndex == "" then
      sliderContents = getSliderContentFromSequence(min, max)
    else
      sliderContents = getSliderContentFromArray(self.effectParamValues[tonumber(dataArrayIndex)])
    end
    return { name, sliderContents }
  end
end
