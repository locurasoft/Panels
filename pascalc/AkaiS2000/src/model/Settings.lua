require("Dispatcher")
require("Logger")
require("model/KeyGroup")
require("model/Zone")
require("message/KdataMsg")

local log = Logger("Settings")

local getPath = function(value)
  if value == nil then
    return ""
  else
    return value:getFullPathName()
  end
end

local pathExists = function(value)
  if value == nil then
    return false
  else
    return value:exists()
  end
end

Settings = {}
Settings.__index = Settings

setmetatable(Settings, {
  __index = Dispatcher, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Settings:_init()
  Dispatcher._init(self)
  self[LUA_CONTRUCTOR_NAME] = "Settings"
  self.transferMethod = 1
end

function Settings:getWorkFolder()
  return getPath(self.workFolder)
end

function Settings:setWorkFolder(workFolder)
    self.workFolder = workFolder
    self:notifyListeners()
end

function Settings:workFolderExists()
  return pathExists(self.workFolder)
end

function Settings:getHxcPath()
  return getPath(self.hxcPath)
end

function Settings:getHxcRoot()
  if self.hxcPath == nil then
    return ""
  else
    return getPath(self.hxcPath:getParentDirectory())
  end
end

function Settings:setHxcPath(hxcPath)
  self.hxcPath = hxcPath
  self:notifyListeners()
end

function Settings:hxcPathExists()
  return pathExists(self.hxcPath)
end

function Settings:getS2kDiePath()
  return getPath(self.s2kDiePath)
end

function Settings:setS2kDiePath(s2kDiePath)
    self.s2kDiePath = s2kDiePath
    self:notifyListeners()
end

function Settings:s2kDiePathExists()
  return pathExists(self.s2kDiePath)
end

function Settings:getSetfdprmPath()
  return getPath(self.setfdprmPath)
end

function Settings:setSetfdprmPath(setfdprmPath)
    self.setfdprmPath = setfdprmPath
    self:notifyListeners()
end

function Settings:setfdprmPathExists()
  return pathExists(self.setfdprmPath)
end

function Settings:getFloppyImgPath()
  return getPath(self.floppyImgPath)
end

function Settings:setFloppyImgPath(floppyImgPath)
  self.floppyImgPath = floppyImgPath
  self:notifyListeners()
end

function Settings:floppyImgPathExists()
  return pathExists(self.floppyImgPath)
end

function Settings:getTransferMethod()
  return self.transferMethod
end

function Settings:setTransferMethod(transferMethod)
  self.transferMethod = transferMethod
  self:notifyListeners()
end
