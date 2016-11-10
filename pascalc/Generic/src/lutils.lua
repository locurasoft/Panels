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

function getErrorMessage(err)
  base.debug.traceback()
  if base.type(err) == "string" then
    return err:gsub(".*:%d+:%s*", "")
  else
    return "Unknown error occurred"
  end
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