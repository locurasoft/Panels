require("Process")
require("Logger")
require("cutils")

TRANSFERING_FLOPPY = 9

local log = Logger("TransferFloppyProcess")

TransferFloppyProcess = {}
TransferFloppyProcess.__index = TransferFloppyProcess

setmetatable(TransferFloppyProcess, {
  __index = Process, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function TransferFloppyProcess:_init()
  Process._init(self)
end

function TransferFloppyProcess:execute()
  self:launchExternalProcess(
    { hxcService:getHxcLauncher() },
    { ["imgPath"] = settings:getFloppyImgPath() },
    { hxcService:getHxcAborter() })

  self.state = TRANSFERING_FLOPPY
  self:notifyListeners()
end
