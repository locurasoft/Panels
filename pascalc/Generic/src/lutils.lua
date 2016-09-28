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
