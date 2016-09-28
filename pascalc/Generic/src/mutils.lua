-----------------------------------------------------------------------------
-- mutils: Midi Utils module
-- lutils Module.
-- Author: Pascal Collberg
-- This module is released under the MIT License (MIT).
--
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Imports and dependencies
-----------------------------------------------------------------------------
local math = require('math')
local string = require("string")
local bit = require("bit")
local package = require("package")

local base = _G

-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
module("mutils")

-- Private functions


-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------

function float2nibbles(value)
  local nibbles = base.MemoryBlock(4, true)
  local n = math.floor(math.abs(value) * 256 + 0.13)
  n = value < 0 and 0x10000 - n or n
  for pos = 0, 3 do
    nibbles:setByte(pos, n % 16)
    n = math.floor(n / 16)
  end
  return nibbles
end

function nibbles2float(memBlock, offset)
  local bi = base.BigInteger(0)
  bi:setBitRangeAsInt(0, 4, memBlock:getByte(offset))
  bi:setBitRangeAsInt(4, 4, memBlock:getByte(offset + 1))
  bi:setBitRangeAsInt(8, 4, memBlock:getByte(offset + 2))
  bi:setBitRangeAsInt(12, 4, memBlock:getByte(offset + 3))
  local n = 0
  for i = 0, 15 do
    local factor = math.pow(2, i - 8)
    n = n + bi:getBitRangeAsInt(i, 1) * factor
  end
  return memBlock:getByte(offset + 3) >= 0x8 and n - 256 or n
end

---
-- @function [parent=#__MidiService] fromNibbles
-- 
function fromNibbles(ls, ms)
  local bi = base.BigInteger(0)
  bi:setBitRangeAsInt(0, 4, ls)
  bi:setBitRangeAsInt(4, 7, ms)
  return bi:getBitRangeAsInt(0, 15)
end

---
-- @function [parent=#__MidiService] toNibbles
-- 
function toNibbles(x)
  local nibbles = base.MemoryBlock(2, true)

  local internalX = x
  if x < 0 then
    local hex = bit.tohex(x, 2)
    internalX = base.tonumber(hex, 16)
  end
  local bi = base.BigInteger(internalX)
  local LS = bi:getBitRangeAsInt(0, 4)
  local MS = bi:getBitRangeAsInt(4, 7)

  nibbles:setByte(0, LS)
  nibbles:setByte(1, MS)
  return nibbles
end