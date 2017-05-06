require("LuaObject")
require("Logger")
require("lutils")

local SPECIAL_OFFSETS = { [6]=64, [8]=64, [12]=64, [14]=64, [21]=64, [23]=64, [28]=64, [30]=64, [36]=64, [38]=64, [42]=64, [44]=64, [49]=64, [51]=64, [55]=64, [70]=64, [72]=64, [74]=64, [80]=64, [82]=64, [84]=64, [90]=64, [92]=64, [94]=64, [100]=64, [102]=64, [104]=64, }
local Voice_HeaderSize = 8
local Voice_FooterSize = 2
local paramSpecifications = {
  { 1, 0, 127, false, 0, 121 },
  { 2, 0, 127, false, 0, 121 },
  { 0, 3, 248, false, 128, 123 },
  { 0, 0, 255, false, 128, 131 },
  { 0, 0, 15, false, 8, 125 },
  { 0, 1, 254, true, 128, 127 },
  { 0, 4, 240, false, 128, 125 },
  { 0, 1, 254, true, 128, 129 },
  { 0, 1, 126, false, 64, 133 },
  { 0, 7, 128, false, 128, 133 },
  { 0, 0, 15, false, 8, 135 },
  { 0, 1, 254, true, 128, 137 },
  { 0, 4, 240, false, 128, 135 },
  { 0, 1, 254, true, 128, 139 },
  { 1, 0, 127, false, 0, 141 },
  { 2, 0, 127, false, 0, 141 },
  { 0, 3, 248, false, 128, 143 },
  { 0, 0, 255, false, 128, 151 },
  { 0, 7, 128, false, 128, 183 },
  { 0, 0, 15, false, 8, 145 },
  { 0, 1, 254, true, 128, 147 },
  { 0, 4, 240, false, 128, 145 },
  { 0, 1, 254, true, 128, 149 },
  { 0, 7, 128, false, 128, 181 },
  { 0, 1, 126, false, 64, 153 },
  { 0, 7, 128, false, 128, 153 },
  { 0, 0, 15, false, 8, 155 },
  { 0, 1, 254, true, 128, 157 },
  { 0, 4, 240, false, 128, 155 },
  { 0, 1, 254, true, 128, 159 },
  { 1, 0, 127, false, 0, 161 },
  { 2, 0, 127, false, 0, 161 },
  { 0, 3, 248, false, 128, 163 },
  { 0, 0, 255, false, 128, 171 },
  { 0, 0, 15, false, 8, 165 },
  { 0, 1, 254, true, 128, 167 },
  { 0, 4, 240, false, 128, 165 },
  { 0, 1, 254, true, 128, 169 },
  { 0, 1, 126, false, 64, 173 },
  { 0, 7, 128, false, 128, 173 },
  { 0, 0, 15, false, 8, 175 },
  { 0, 1, 254, true, 128, 177 },
  { 0, 4, 240, false, 128, 175 },
  { 0, 1, 254, true, 128, 179 },
  { 0, 0, 127, false, 64, 183 },
  { 0, 0, 31, false, 16, 185 },
  { 0, 1, 126, false, 64, 193 },
  { 0, 0, 15, false, 8, 187 },
  { 0, 0, 127, true, 64, 189 },
  { 0, 4, 240, false, 128, 187 },
  { 0, 0, 127, true, 64, 191 },
  { 0, 4, 240, false, 128, 205 },
  { 0, 0, 127, false, 64, 181 },
  { 0, 0, 15, false, 8, 205 },
  { 0, 0, 127, true, 64, 207 },
  { 0, 0, 63, false, 32, 195 },
  { 0, 7, 128, false, 128, 191 },
  { 0, 7, 128, false, 128, 189 },
  { 0, 7, 128, false, 128, 193 },
  { 0, 7, 128, false, 128, 195 },
  { 0, 7, 128, false, 128, 207 },
  { 4, 0, 127, false, 0, 197 },
  { 5, 0, 128, false, 0, 201 },
  { 0, 0, 127, false, 64, 201 },
  { 0, 7, 128, false, 128, 199 },
  { 0, 0, 127, false, 64, 199 },
  { 0, 7, 128, false, 128, 203 },
  { 0, 0, 127, false, 64, 203 },
  { 0, 0, 63, false, 32, 23 },
  { 0, 1, 254, true, 128, 17 },
  { 0, 0, 63, false, 32, 25 },
  { 0, 1, 254, true, 128, 19 },
  { 0, 0, 63, false, 32, 27 },
  { 0, 1, 254, true, 128, 21 },
  { 0, 0, 63, false, 32, 29 },
  { 0, 2, 252, false, 128, 31 },
  { 0, 0, 63, false, 32, 33 },
  { 0, 0, 63, false, 32, 35 },
  { 0, 0, 63, false, 32, 43 },
  { 0, 1, 254, true, 128, 37 },
  { 0, 0, 63, false, 32, 45 },
  { 0, 1, 254, true, 128, 39 },
  { 0, 0, 63, false, 32, 47 },
  { 0, 1, 254, true, 128, 41 },
  { 0, 0, 63, false, 32, 49 },
  { 0, 2, 252, false, 128, 51 },
  { 0, 0, 63, false, 32, 53 },
  { 0, 0, 63, false, 32, 55 },
  { 0, 0, 63, false, 32, 63 },
  { 0, 1, 254, true, 128, 57 },
  { 0, 0, 63, false, 32, 65 },
  { 0, 1, 254, true, 128, 59 },
  { 0, 0, 63, false, 32, 67 },
  { 0, 1, 254, true, 128, 61 },
  { 0, 0, 63, false, 32, 69 },
  { 0, 2, 252, false, 128, 71 },
  { 0, 0, 63, false, 32, 73 },
  { 0, 0, 63, false, 32, 75 },
  { 0, 0, 63, false, 32, 83 },
  { 0, 1, 254, true, 128, 77 },
  { 0, 0, 63, false, 32, 85 },
  { 0, 1, 254, true, 128, 79 },
  { 0, 0, 63, false, 32, 87 },
  { 0, 1, 254, true, 128, 81 },
  { 0, 0, 63, false, 32, 89 },
  { 0, 2, 252, false, 128, 91 },
  { 0, 0, 63, false, 32, 93 },
  { 0, 0, 63, false, 32, 95 },
  { 0, 0, 63, false, 32, 97 },
  { 0, 6, 192, false, 128, 97 },
  { 0, 6, 64, false, 64, 103 },
  { 0, 7, 128, false, 128, 103 },
  { 3, 0, 192, false, 0, 99 },
  { 0, 0, 63, false, 32, 99 },
  { 0, 0, 63, false, 32, 103 },
  { 0, 0, 63, false, 32, 101 },
  { 0, 0, 63, false, 32, 105 },
  { 0, 6, 192, false, 128, 105 },
  { 0, 6, 64, false, 64, 111 },
  { 0, 7, 128, false, 128, 111 },
  { 3, 0, 192, false, 0, 107 },
  { 0, 0, 63, false, 32, 107 },
  { 0, 0, 63, false, 32, 111 },
  { 0, 0, 63, false, 32, 109 },
  { 0, 0, 63, false, 32, 113 },
  { 0, 6, 192, false, 128, 113 },
  { 0, 6, 64, false, 64, 119 },
  { 0, 7, 128, false, 128, 119 },
  { 3, 0, 192, false, 0, 115 },
  { 0, 0, 63, false, 32, 115 },
  { 0, 0, 63, false, 32, 119 },
  { 0, 0, 63, false, 32, 117 }
}


local log = Logger("Patch")

Patch = {}
Patch.__index = Patch

setmetatable(Patch, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Patch:_init(bankData, patchOffset)
  LuaObject._init(self)

  if bankData ~= nil then
    self.data = bankData
    self.patchOffset = patchOffset
  end
end

function Patch:getValueOffset(relativeOffset)
  return self.patchOffset + relativeOffset
end

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
function Patch:getPatchName()
  -- This method fetches the patch name from the hidden

  local patchName = ""
  for i = 0, 5 do
    patchName = string.format("%s%c", patchName,
      self.data:getByte(self:getValueOffset(i * 2)) + self.data:getByte(self:getValueOffset(i * 2 + 1)) * 16)
  end
  return patchName
end

-- This method set the values of the hidden char modulators
-- to match the given name
function Patch:setPatchName(patchName)
  for i = 1, 6 do
    local char = patchName:byte(i, i + 1)
    if char == nil then
      char = 0
    end

    self.data:setByte(self:getValueOffset((i - 1) * 2), char % 16)
    self.data:setByte(self:getValueOffset((i - 1) * 2 + 1), math.floor(char / 16))
  end
end

function Patch:setValue(index, value)
  local spec = paramSpecifications[index]
  local type = spec[1]
  local shift = spec[2]
  local bitmask = spec[3]
  local signed = spec[4]
  local offset = self:getValueOffset(spec[6]) - 5

  if SPECIAL_OFFSETS[index] ~= nil then
    value = value - SPECIAL_OFFSETS[index]
  end

  log:warnIf(index == 18, "setValue off: %d ind: %d, val: %d (%.2X %.2X)", offset, index, value, self.data:getByte(offset), self.data:getByte(offset + 1))

  local j = self.data:getByte(offset) + self.data:getByte(offset + 1) * 16

  if type == 0 then
    -- The general case
    j = bit.bor(bit.lshift(value, shift), bit.band(j, bit.bnot(bitmask)));
  elseif type == 1 then
    -- Octave
    j = (value * 12) + (j % 12);
  elseif type == 2 then
    -- Semi
    j = value + math.floor(j / 12) * 12;
  elseif type == 3 then
    -- LFO Mod Src
    local k = self.data:getByte(offset + 2) + self.data:getByte(offset + 3) * 16
    j = bit.band(j, bit.bnot(bitmask)) + bit.band(value, 0x0C) * 16
    k = bit.band(k, bit.bnot(bitmask)) + bit.band(value, 0x03) * 64
    self.data:setByte(offset + 2, bit.band(k, 0x0F))
    self.data:setByte(offset + 3, bit.band(bit.rshift(k, 4), 0x0F))
  elseif type == 4 then
    -- Split Point
    j = value -- bit.band(j, bit.bnot(bitmask)) + value;
  elseif type == 5 then
    -- Split Direction
    local k = self.data:getByte(offset - 4) + self.data:getByte(offset - 3) * 16
    if value == 0 then
      -- Clear Split Flag, meaning OFF
      j = bit.band(j, bit.bnot(bitmask))
    elseif value == 1 then
      -- Set Split Flag
      j = bit.band(j, bit.bnot(bitmask)) + 0x80
      -- Clear Split Direction, meaning UPPER
      k = bit.band(k, bit.bnot(bitmask))
      self.data:setByte(offset - 4, bit.band(k, 0x0F))
      self.data:setByte(offset - 3, bit.band(bit.rshift(k, 4), 0x0F))
    elseif value == 2 then
      -- Set Split Flag
      j = bit.band(j, bit.bnot(bitmask)) + 0x80
      -- Set Split Direction, Meaning LOWER
      k = bit.band(k, bit.bnot(bitmask)) + 0x80
      self.data:setByte(offset - 4, bit.band(k, 0x0F))
      self.data:setByte(offset - 3, bit.band(bit.rshift(k, 4), 0x0F))
    else
      log:warn("Weird Split direction value %d", value)
    end
  else
    log:warn("Weird param type %d", type)
    return
  end

  self.data:setByte(offset, bit.band(j, 0x0F))
  self.data:setByte(offset + 1, bit.band(bit.rshift(j, 4), 0x0F))
end

function Patch:getValue(index)
  local spec = paramSpecifications[index]
  local type = spec[1]
  local shift = spec[2]
  local bitmask = spec[3]
  local signed = spec[4]
  local signmask = spec[5]
  local offset = self:getValueOffset(spec[6]) - 5

  local modValue = 0
  local j = self.data:getByte(offset) + self.data:getByte(offset + 1) * 16

  if type == 0 then
    -- The general case
    if signed and bit.band(j, signmask) ~= 0 then
      -- If the parameter is signed AND negative
      modValue = bit.arshift(bit.bor(bit.band(-1, bit.bnot(bitmask)), bit.band(j, bitmask)), shift)
    else
      -- If the parameter is positive or not signed
      modValue = bit.rshift(bit.band(j, bitmask), shift)
    end
  elseif type == 1 then
    -- Octave
    modValue = math.floor(j / 12)
  elseif type == 2 then
    -- Semi
    modValue = j % 12
  elseif type == 3 then
    -- LFO Mod Src
    local k = self.data:getByte(offset + 2) + self.data:getByte(offset + 3) * 16
    modValue = bit.rshift(bit.band(j, bitmask), 4) + bit.rshift(bit.band(k, bitmask), 6)
  elseif type == 4 then
    -- Split Point
    modValue = j --math.max(bit.band(j, bitmask), 21) - 21
  elseif type == 5 then
    -- Split Direction
    if bit.band(j, bitmask) == 0 then
      modValue = 0
    elseif bit.band(self.data:getByte(offset - 4) + self.data:getByte(offset - 3) * 16, bitmask) == 0 then
      modValue = 1
    else
      modValue = 2
    end

  else
    log:warn("Weird param type %d", type)
    return
  end

  if SPECIAL_OFFSETS[index] ~= nil then
    modValue = modValue + SPECIAL_OFFSETS[index]
  end
  
  log:warnIf(index == 18, "getValue off: %d ind: %d, val: %d (%.2X %.2X)", offset, index, modValue, self.data:getByte(offset), self.data:getByte(offset + 1))
  return modValue
end
