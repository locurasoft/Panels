-----------------------------------------------------------------------------
-- cutils: Ctrlr Utils module
-- cutils Module.
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
local os = require("os")
local io = require("io")

local base = _G

-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
module("cutils")

STATE_PROD, STATE_DEV = 0, 1

-- Private functions


-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------

function getPathSeparator()
  return package.config:sub(1,1)
end

--- Returns the opertaing system name as string.
-- @return the opertaing system name as string
function getOsName()
  local osName = "win"
  if getPathSeparator() == "/" then
    local osName = "mac"
  end
  return osName
end

---
-- @return the EOL character based on os
function getEolChar()
  if getOsName() == "win" then
    return "\r\n"
  else
    return "\n"
  end
end

function getUserHome()
  if getOsName() == "win" then
    return os.getenv("HOMEDRIVE")
  else
    return "/"
  end
end

function getFileSize(file)
  local wavFile = io.open(file:getFullPathName(), "r")
  local size = wavFile:seek("end")    -- get file size
  wavFile:close()
  return size
end

function getFileContents(filepath)
  local f = io.open(filepath, "rb")
  local content = ""
  if f ~= nil then
    content = f:read("*all")
    f:close()
  end

  return content
end

function writeToFile(fileName, contents)
  file = io.open(fileName, "w+")
  file:write(contents)
  file:close()
end

function toFilePath(fileDir, fileName)
  return string.format("%s%s%s", fileDir, getPathSeparator(), fileName)
end

function getFileName(filePath)
  local pathSeparator = getPathSeparator()
  local lastSlash = string.find(filePath, string.format("%s[^%s]*$", pathSeparator, pathSeparator))
  return string.sub(filePath, lastSlash + 1)
end

function getRotationTransform(angle, x, y, w, h)
  local timesPi = angle / 180
  local xRot = x + w / 2
  local yRot = y + h / 2
  transform = AffineTransform.rotation(timesPi * 3.1415926536, xRot, yRot)

  if transform:isSingularity() ~= true then
    return transform
  else
    return nil
  end
end

function getErrorMessage(err)
  if base.PANEL_STATE == STATE_DEBUG then
    base.debug.traceback()
  end

  if base.type(err) == "string" then
    return err:gsub(".*:%d+:%s*", "")
  else
    return "Unknown error occurred"
  end
end
