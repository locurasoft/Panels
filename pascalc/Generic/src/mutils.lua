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

function f2n(value)
  local nibbles = base.MemoryBlock(4, true)
  local n = math.floor(math.abs(value) * 256 + 0.13)
  n = value < 0 and 0x10000 - n or n
  for pos = 0, 3 do
    nibbles:setByte(pos, n % 16)
    n = math.floor(n / 16)
  end
  return nibbles
end

function n2f(memBlock, offset)
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
-- @function [parent=#mutils] n2d
--
function n2d(ls, ms)
  local bi = base.BigInteger(0)
  bi:setBitRangeAsInt(0, 4, ls)
  bi:setBitRangeAsInt(4, 4, ms)
  local retval = bi:getBitRangeAsInt(0, 8)
  if retval > 127 then
    return retval - 256
  else
    return retval
  end
end

---
-- @function [parent=#__MidiService] d2n
--
function d2n(x)
  local internalX = x
  if x < 0 then
    local hex = bit.tohex(x, 2)
    internalX = base.tonumber(hex, 16)
  end
  local bi = base.BigInteger(internalX)

  local nibbles = base.MemoryBlock(2, true)
  nibbles:setByte(0, bi:getBitRangeAsInt(0, 4))
  nibbles:setByte(1, bi:getBitRangeAsInt(4, 4))
  return nibbles
end

---
-- @function [parent=#mutils] a2n
-- calculate the akai-splitted parameter value,returns table named split with two values
function a2n(byteBlock)
  local nibblizedBlock = base.MemoryBlock(byteBlock:getSize() * 2, true)
  for i = 1, byteBlock:getSize() do
    local nibbles = d2n(byteBlock:getByte(i - 1))
    nibblizedBlock:copyFrom(nibbles, (i - 1) * 2, 2)
  end
  return nibblizedBlock
end

---
-- @function [parent=#mutils] n2a
--
function n2a(nibblizedBlock)
  local byteBlock = base.MemoryBlock(nibblizedBlock:getSize() / 2, true)
  for i = 0, nibblizedBlock:getSize() - 1, 2 do
    byteBlock:setByte(i / 2, n2d(nibblizedBlock:getByte(i), nibblizedBlock:getByte(i + 1)))
  end
  return byteBlock
end

---
-- @function [parent=#mutils] d2b
--
function d2b(value)
  local MS = math.floor(value / 128)

  local bytes = base.MemoryBlock(2, true)
  bytes:setByte(0, value - (MS * 128))
  bytes:setByte(1, MS)
  return bytes
end
