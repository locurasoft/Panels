require("AbstractController")
require("Logger")
require("cutils")

local log = Logger("BehringerModulizerController")

local variations = { "LFO Speed::::*", "LFO Speed::::*", "HP Shape::::",
  "Mode:L1,L2,A1,A2", "Mode:L1,L2,A1,A2", "Mode:L1,L2,A1,A2",
  "LFO Speed::::*", "LFO Speed::::*", "LFO Speed::::", "Xover Freq.::::",
  "In / Out::1:2:-1", "Gate Thresh.::::", "Pre Delay::::",
  "Bass Freq.::::", "Ratio:::24:", "Ratio:::24:", "Threshold::::",
  "Mode:L,E,R0,R1,R2,R3,R4,R5,R6,R7,S0,S1,S2,S3,S4,S5,S6,S7",
  "Clicks Level::::", "Tube Type::1:3:-1", "Type::1:3:-1",
  "Speaker Type::1:3:-1", "Frequency::::",
  "Mode:L,E,R0,R1,R2,R3,R4,R5,R6,R7" }

local editA = { "Intensity::1:8:", "Intensity::1:8:", "Tune::::",
  "Frequency::::", "Frequency::::", "Frequency::::", "Delay::1:128:-1",
  "Delay::1:128:-1", "Delay::1:128:-1", "Gain::-6:6:6", "Gain::-6:6:6",
  "Gate Hold::::", "Size::::", "Gain::-6:6:6", "Threshold::-60:0:60",
  "Threshold::-60:0:60", "Hold::::", "Carrier Freq.::::", "Noise Level::::",
  "In Gain::::", "In Gain::::", "Peak Freq.::::", "Density::::", "Frequency::::" }

local editB = { "Depth::::", "Depth::::", "Harmonics::::", "Resonance::::",
  "Resonance::::", "Resonance::::", "Depth::::", "Depth::::", "Depth::::",
  "Spread::::", "Spread::::", "Gate Rel.::::", "Wall Damp::::",
  "Bass Pan.:2:-100:100:50", "Out Gain::-24:24:24", "Out Gain::-24:24:24",
  "Range::::", "LFO / Speed::::*", "Noise BP.::::", "Low Cut::::", "Drive::::",
  "Peak Q:::100:", "Ratio:::6:", "LFO / Speed::::*" }

local editC = { "Feedback::::", "Feedback::::", "::::", "Mod. Depth::::", "Mod. Depth::::",
  "Mod. Depth::::", "Feedback:2:-100:100:50", "Feedback:2:-100:100:50", "Stereo Width::::",
  "Mono Pan.:2:-100:100:50", "Xover Freq.::::", "LP Freq.::::", "Stereo Width::::",
  "Treble Pan.:2:-100:100:50", "Attack::::", "Attack::::", "Attack::::",
  "Mod. Depth::::", "Buzz Level::::", "High Cut::::", "Presence::::",
  "Peak Gain::-12:12:12", "Bass Level::::", "Mod. Depth::::",  }

local editD = { "::::", "::::", "::::", "Env. / LFO Speed::::*", "Env. / LFO Speed::::*",
  "Env. / LFO Speed::::*", "Band Limit::::", "Band Limit::::", "Wideness::::",
  "St. Center:2:-100:100:50", "::::", "LP Depth::::", "Reflections::1:15:-1",
  "::::", "Release::::", "Release::::", "Release::::", "Band Limit::::",
  "Signal BP.::::", "Band Limit::::", "Speaker::1:3:-1", "HF Cut::::", "::::",
  "Feedback:2:-100:100:50" }


BehringerModulizerController = {}
BehringerModulizerController.__index = BehringerModulizerController

local split = function(text, delimiter)
  local list = {}
  local pos = 1
  if string.find("", delimiter, 1) then -- this would result in endless loops
    error("delimiter matches empty string!")
  end
  while 1 do
    local first, last = string.find(text, delimiter, pos)
    if first then -- found?
      table.insert(list, string.sub(text, pos, first-1))
      pos = last+1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end
  return list
end

local setComponentProperties = function(mod, dataString)
  local comp = mod:getComponent()
  local splitData = split(dataString, ":")

  local variationBtnGrp = panel:getModulatorByName("variationBtnGrp"):getComponent()
  local variationGrp = panel:getModulatorByName("variationGrp"):getComponent()
  local splitLength = table.getn(splitData)
  if splitLength == 2 then
    variationGrp:setProperty("componentVisibility", 0, false)
    variationBtnGrp:setProperty("componentVisibility", 1, false)
    comp = panel:getModulatorByName("variationBtn"):getComponent()
  elseif splitLength == 5 and mod:getProperty("name") == "variation" then
    variationBtnGrp:setProperty("componentVisibility", 0, false)
    variationGrp:setProperty("componentVisibility", 1, false)
  elseif splitLength ~= 5 then
    error(string.format("Invalid data string: '%s'", dataString))
    return
  end

  local name = splitData[1]

  comp:setProperty("componentVisibleName", name:upper(), false)
  comp:setProperty("componentVisibility", 1, false)
  if name == "" then
    comp:setProperty("componentVisibility", 0, false)
  end

  local increment = 1
  local min = 0
  local max = 127
  if splitLength == 2 then
    local values = split(splitData[2], ",")
    local valuesLength = table.getn(values)
    local valueStr = values[1]
    for i = 2, valuesLength do
      valueStr = string.format("%s\n%s", valueStr, values[i])
    end
    comp:setProperty("uiFixedSliderContent", valueStr, false)
  else
    if splitData[2] ~= "" then
      increment = splitData[2]
    end
    comp:setProperty("uiSliderInterval", increment, false)

    if splitData[3] ~= "" then
      min = splitData[3]
    end
    comp:setProperty("uiSliderMin", min, false)

    if splitData[4] ~= "" then
      max = splitData[4]
    end
    comp:setProperty("uiSliderMax", max, false)

    if splitData[5] ~= "*" then
      local exprSuffix = ""
      local exprRevSuffix = ""
      local exprSign = "+"
      local exprRevSign = "-"
      if increment ~= 1 then
        exprSuffix = string.format(" / %d", increment)
        exprRevSuffix = string.format(" * %d", increment)
      end

      if splitData[5] ~= "" then
        local offset = tonumber(splitData[5])
        if offset < 0 then
          offset = offset * -1
          exprSuffix = string.format("%s - %d", exprSuffix, offset)
          exprRevSuffix = string.format("%s + %d", exprRevSuffix, offset)
        else
          exprSuffix = string.format("%s + %d", exprSuffix, offset)
          exprRevSuffix = string.format("%s - %d", exprRevSuffix, offset)
        end
      end
      mod:setProperty("modulatorValueExpression", string.format("modulatorValue%s", exprSuffix), false)
      mod:setProperty("modulatorValueExpressionReverse", string.format("midiValue%s", exprRevSuffix), false)
    end
  end
end


setmetatable(BehringerModulizerController, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#EnsoniqEsq1Controller] _init
--
function BehringerModulizerController:_init()
  AbstractController._init(self)
end

---
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function BehringerModulizerController:onEffectChange(mod, value)

  --console(string.format("[onEffectChange] %d", value))
  -- name:increment:min:max:offset

  local varMod = panel:getModulatorByName("variation")
  local editAMod = panel:getModulatorByName("editA")
  local editBMod = panel:getModulatorByName("editB")
  local editCMod = panel:getModulatorByName("editC")
  local editDMod = panel:getModulatorByName("editD")

  setComponentProperties(varMod, variations[value + 1])
  setComponentProperties(editAMod, editA[value + 1])
  setComponentProperties(editBMod, editB[value + 1])
  setComponentProperties(editCMod, editC[value + 1])
  setComponentProperties(editDMod, editD[value + 1])
end

function BehringerModulizerController:onLoadVoice(mod, value)
  local file = utils.openFileWindow ("Open Patch", File(""), "*.syx", true)
  if file:existsAsFile() then
    local data = MemoryBlock()
    file:loadFileAsData(data)
    if data:getSize() ~= 10 then
      error("The loaded file does not contain a Behringer Modulizer patch")
      return
    end

    -- Assign values
    self:setValue("variation", data:getByte(0))
    self:setValue("editA", data:getByte(1))
    self:setValue("editB", data:getByte(2))
    self:setValue("editC", data:getByte(3))
    self:setValue("editD", data:getByte(4))
    self:setValue("effect", data:getByte(5))
    self:setValue("eqLow", data:getByte(6))
    self:setValue("eqHigh", data:getByte(7))
    self:setValue("mix", data:getByte(8))
    self:setValue("inOut", data:getByte(9))

  end
end

function BehringerModulizerController:onSaveVoice()
  local f = utils.saveFileWindow ("Save patch", File(""), "*.syx", true)
  if f:isValid() == false then
    return
  end
  f:create()
  if f:existsAsFile() then
    -- Fetch values
    local data = MemoryBlock(10, true)
    data:setByte(0, self:getValue("variation"))
    data:setByte(1, self:getValue("editA"))
    data:setByte(2, self:getValue("editB"))
    data:setByte(3, self:getValue("editC"))
    data:setByte(4, self:getValue("editD"))
    data:setByte(5, self:getValue("effect"))
    data:setByte(6, self:getValue("eqLow"))
    data:setByte(7, self:getValue("eqHigh"))
    data:setByte(8, self:getValue("mix"))
    data:setByte(9, self:getValue("inOut"))

    -- Check if the file exists
    if f:existsAsFile() == false then
      -- If file does not exist, then create it
      if f:create() == false then
        -- If file cannot be created, then fail here
        utils.warnWindow ("\n\nSorry, the Editor failed to\nsave the patch to disk!", "The file does not exist.")
        return
      end
    end
    -- If we reached this point, we have a valid file we can try to write to
    if f:replaceWithData (data) == false then
      utils.warnWindow ("File write", "Sorry, the Editor failed to\nwrite the data to file!")
    end
    console ("File save complete, Editor patch saved to disk")
  end
end
