-----------------------------------------------------------------------------
-- lutils: Lua Utils module
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
local table = require("table")
local package = require("package")

local base = _G

-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
module("lutils")

-- Private functions


-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------

function flipTable(t)
  local r = { }
  for k, v in base.pairs(t) do
    r[v] = k -- overrides duplicate values if any
  end
  return r
end

function trim(s)
  return s:match "^%s*(.-)%s*$"
end

function strStarts(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

function strEnds(str, suffix)
  return suffix == '' or string.sub(str, -string.len(suffix)) == suffix
end

function strNotEmpty(str)
  return str ~= nil and trim(str) ~= ""
end

function split(text, delimiter)
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
