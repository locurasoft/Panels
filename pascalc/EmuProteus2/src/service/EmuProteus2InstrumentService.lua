require("LuaObject")
require("Logger")
require("lutils")

local log = Logger("EmuProteus2InstrumentService")

local instruments = { "2-0", "2-1", "2-2", "2-3", "2-4", "2-5", "2-6", "2-7", "2-8", "2-9", "2-10", "2-13", "2-11", "2-12",
  "2-14", "4-1", "4-2", "4-3", "4-5", "4-6", "4-7", "4-8", "4-4", "4-9", "4-10", "4-11", "4-12", "4-13", "2-15",
  "2-63", "2-65", "2-16", "4-14", "4-15", "4-16", "4-17", "4-18", "4-19", "4-20", "4-30", "4-79", "4-21", "2-17", "2-64",
  "2-18", "2-19", "4-22", "2-20", "2-21", "2-22", "2-23", "2-24", "2-25", "2-26", "2-27", "2-28", "2-29", "2-30", "2-31", "2-32",
  "2-33", "2-34", "2-35", "2-36", "2-37", "4-23", "4-24", "4-25", "4-26", "4-27", "4-28", "4-29", "2-38", "2-39", "2-40",
  "2-41", "2-42", "2-43", "2-44", "2-45", "2-46", "2-47", "2-48", "2-49", "2-50", "2-51", "2-52", "2-53", "2-54", "2-55",
  "2-56", "2-57", "2-58", "2-59", "4-32", "4-33", "4-34", "4-35", "4-36", "4-37", "4-38", "4-39", "4-40", "4-41", "4-42",
  "4-43", "4-44", "4-45", "4-46", "4-47", "4-48", "4-49", "4-50", "4-51", "4-52", "4-53", "4-54", "4-55", "4-56", "4-57",
  "4-58", "4-59", "4-60", "4-61", "4-62", "4-63", "4-64", "4-65", "4-66", "4-67", "4-68", "4-69", "4-70", "4-71", "4-72",
  "4-73", "4-74", "4-75", "4-76", "4-77", "4-78", "4-31", "2-60", "2-61", "2-62" }
  
local instrumentsInverted = lutils.flipTable(instruments)

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

EmuProteus2InstrumentService = {}
EmuProteus2InstrumentService.__index = EmuProteus2InstrumentService

setmetatable(EmuProteus2InstrumentService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function EmuProteus2InstrumentService:_init()
  LuaObject._init(self)
end


function EmuProteus2InstrumentService:c2m(value)
  local voiceString = instruments[value]
  if voiceString == nil or voiceString == "" then
    return 0
  end

  local splitString = split(voiceString, "-")
  local bank = splitString[1]
  local voiceNbr = splitString[2]
  local retval = bank * 128 + voiceNbr
  log:warn("c2m %d => %d", value, retval)
  return retval
end

function EmuProteus2InstrumentService:m2c(value)
  local bank = math.floor(value / 128)
  local voiceNbr = value - (bank * 128)
  local stringValue = string.format("%d-%d", bank, voiceNbr)
  local result = instrumentsInverted[stringValue]
  if result == nil then
    return 0
  else
    return result - 1
  end
end
