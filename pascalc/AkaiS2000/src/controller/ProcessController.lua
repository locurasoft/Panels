require("AbstractController")
require("Logger")
require("cutils")

local log = Logger("ProcessController")

ProcessController = {}
ProcessController.__index = ProcessController

setmetatable(ProcessController, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ProcessController:_init()
  AbstractController._init(self)
  self.currProc = nil
end

function ProcessController:processStateChanged(proc)
  if proc:isRunning() then
    self:toggleActivation("cancelTransfer", true)
  else
    self:toggleActivation("cancelTransfer", false)
    self.currProc = nil
  end
end

function ProcessController:execute(proc)
  assert(self.currProc == nil, "You cannot run processes in parallell.\nPlease cancel all previous processes.")
  self.currProc = proc
  self.currProc:addListener(self, "processStateChanged")
  self.currProc:execute()
end

function ProcessController:abort()
  assert(self.currProc ~= nil, "No active process to cancel!")
  self.currProc:abort()
end
