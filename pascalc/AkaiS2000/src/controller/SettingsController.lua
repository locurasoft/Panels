require("AbstractController")
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
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SettingsController:_init(settings)
  AbstractController._init(self)
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
  markGroup("workPathGroup", not self.settings:workFolderExists())

  -- Reset all values
  markGroup("hxcPathGroup", false)
  markGroup("setfdprmPathGroup", false)
  markGroup("transferMethodGroup", false)

  local loadMethod = panel:getModulatorByName("transferMethod"):getValue()

  if loadMethod == 0 then
    -- Floppy
    markGroup("setfdprmPathGroup", not self.settings:setfdprmPathExists())
  elseif loadMethod == 1 then
    -- HxC
    markGroup("hxcPathGroup", not self.settings:hxcPathExists())
  else
    -- MIDI -> unsupported
    markGroup("transferMethodGroup", true)
  end
  return retval
end

function SettingsController:selectFloppyImage(floppyImgPath)
  self.settings:setFloppyImgPath(floppyImgPath)
end

function SettingsController:changeTransferMethod(xferMethod)
  self.settings:setTransferMethod(xferMethod)
end

function SettingsController:changeSetfdprmPath(setfdprmPath)
  self.settings:setSetfdprmPath(setfdprmPath)
end

function SettingsController:changeHxcPath(hxcPath)
  self.settings:setHxcPath(hxcPath)
end

function SettingsController:changeS2kDiePath(s2kDiePath)
  self.settings:setS2kDiePath(s2kDiePath)
end

function SettingsController:changeWorkPath(workPath)
  self.settings:setWorkFolder(workPath)
end
