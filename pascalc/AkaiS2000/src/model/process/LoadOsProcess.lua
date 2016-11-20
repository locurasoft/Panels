require("model/process/Process")
require("Logger")
require("cutils")

local log = Logger("LoadOsProcess")

OS_LOADING = 33
OS_LOADED  = 32

LoadOsProcess = {}
LoadOsProcess.__index = LoadOsProcess

setmetatable(LoadOsProcess, {
  __index = Process, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function LoadOsProcess:_init()
  Process._init(self)
end

function LoadOsProcess:execute()
  self.state = OS_LOADING
  self:notifyListeners()

  local statCount = 0
  local midiSender = function()
    midiService:sendMidiMessage(RstatMsg())
  end

  local midiCallback = function(data)
    local status, statMsg = pcall(StatMsg, data)
    if status then
      if statCount > 40 then
        statCount = statCount + 1
      else
        self.state = OS_LOADED
        self:stopAll()
        self:notifyListeners()
      end
    end
  end
  
  self:registerMidiCallback(midiCallback)
  self:launchMidiSender(midiSender, 1000)

  self:launchExternalProcess(
    { hxcService:getHxcLauncher() }, 
    { ["imgPath"] = cutils.toFilePath(settings:getWorkFolder(), "osimage.img") }, 
    { hxcService:getHxcAborter() })
end
