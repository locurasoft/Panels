require("controller/AbstractS2kController")
require("Logger")

local log = Logger("SettingsController")
local markGroup = function(groupName, error)
  local color = "FF7A7269"
  if error then
    color = "FFEA402A"
  end
  
  panel:getComponent(groupName):setProperty("uiGroupOutlineColour1", color, false)
end

SettingsController = {}
SettingsController.__index = SettingsController

setmetatable(SettingsController, {
  __index = AbstractS2kController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SettingsController:_init()
  AbstractS2kController._init(self)
end

function SettingsController:setSettings(settings)
  self.settings = settings
  settings:addListener(self, "updateSettings")
end

function SettingsController:updateSettings(settings)
  local FLOPPY, HXCFE, MIDI = 0, 1, 2

  local xferMethod = settings:getTransferMethod()
  self:toggleActivation("hxcPathGroup", xferMethod == HXCFE)
  self:toggleActivation("loadOsButton", xferMethod == HXCFE)
  self:toggleActivation("loadFloppyImageGroup", xferMethod == HXCFE)
  self:toggleActivation("setfdprmPathGroup", xferMethod == FLOPPY)

  local floppyImgPath = settings:getFloppyImgPath()
  self:setText("loadFloppyImageLabel", floppyImgPath)
  self:setText("setfdprmPathLabel", settings:getSetfdprmPath())
  self:setText("hxcPathLabel", settings:getHxcPath())
  self:setText("s2kDiePathLabel", settings:getS2kDiePath())
  self:setText("workPathLabel", settings:getWorkFolder())

  if floppyImgPath ~= nil and floppyImgPath ~= "" then
    drumMapController:toggleActivation("transferSamples", drumMap:getLaunchButtonState())
  end

end

function SettingsController:verifyTransferSettings()
  local retval = true
  
  markGroup("s2kDiePathGroup", not self.settings:s2kDiePathExists())
  retval = retval and self.settings:s2kDiePathExists()
  markGroup("workPathGroup", not self.settings:workFolderExists())
  retval = retval and self.settings:workFolderExists()

  -- Reset all values
  markGroup("hxcPathGroup", false)
  markGroup("setfdprmPathGroup", false)
  markGroup("transferMethodGroup", false)

  local transferMethod = self.settings:getTransferMethod()

  if transferMethod == 0 then
    -- Floppy
    markGroup("setfdprmPathGroup", not self.settings:setfdprmPathExists())
    retval = retval and self.settings:setfdprmPathExists()
  elseif transferMethod == 1 then
    -- HxC
    markGroup("hxcPathGroup", not self.settings:hxcPathExists())
    retval = retval and self.settings:hxcPathExists()
  else
    -- MIDI -> unsupported
    markGroup("transferMethodGroup", true)
  end
  return retval
end

function SettingsController:onFloppyImageCleared(mod, value)
  self.settings:setFloppyImgPath(nil)
end

function SettingsController:onFloppyImageSelected(mod, value)
  local floppyImgPath = utils.openFileWindow("Select floppy image", File.getSpecialLocation(File.userHomeDirectory), "*.img", true)
  self.settings:setFloppyImgPath(floppyImgPath)
end

function SettingsController:onTransferMethodChange(mod, value)
  self.settings:setTransferMethod(value)
end

function SettingsController:onSetfdprmPathChange(mod, value)
  local setfdprmPath = utils.openFileWindow("Select setfdprm path", File.getSpecialLocation(File.userHomeDirectory), "*", true)
  self.settings:setSetfdprmPath(setfdprmPath)
end

function SettingsController:onHxcPathChange(mod, value)
  local filePatternsAllowed = "*"
  if operatingsystem == "win" then
    filePatternsAllowed = "*.exe"
  end

  local hxcPath = utils.openFileWindow("Select hxcfe executable", File.getSpecialLocation(File.userHomeDirectory),
    filePatternsAllowed, true)
  self.settings:setHxcPath(hxcPath)
end

function SettingsController:onS2kDiePathChange(mod, value)
  local s2kDiePath = utils.openFileWindow("Select s2kDie folder", File.getSpecialLocation(File.userHomeDirectory), "*.php", true)
  self.settings:setS2kDiePath(s2kDiePath)
end

function SettingsController:onWorkPathChange(mod, value)
  local workFolder = utils.getDirectoryWindow("Select work folder", File.getSpecialLocation(File.userHomeDirectory))
  self.settings:setWorkFolder(workFolder)
end
