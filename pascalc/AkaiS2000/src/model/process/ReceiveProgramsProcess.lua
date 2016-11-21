require("model/process/Process")
require("message/RpdataMsg")
require("message/RkdataMsg")
require("Logger")
require("cutils")

local log = Logger("ReceivedProgramsProcess")

RECEIVING_PROGRAMS = 25
PROGRAMS_RECEIVED  = 24
RECEIVING_PROGRAMS_FAILED = 26

ReceivedProgramsProcess = {}
ReceivedProgramsProcess.__index = ReceivedProgramsProcess

setmetatable(ReceivedProgramsProcess, {
  __index = Process, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function ReceivedProgramsProcess:_init()
  Process._init(self)
  self.requestQueue = Queue()
  self.programs     = {}
end

function ReceivedProgramsProcess:getPrograms()
  return self.programs
end

function ReceivedProgramsProcess:execute()
  local midiCallback
  local request
  local errorCount = 0

  local executeNextTransfer = function()
    self:registerMidiCallback(midiCallback)
    request = self.requestQueue:popFirst()
    if request ~= nil then
      midiService:sendMidiMessage(request)
    else
      self.state = PROGRAMS_RECEIVED
      self:stopAll()
      self:notifyListeners()
    end
  end

  midiCallback = function(data)
    self:stopMidiThreads()
    local status, plist = pcall(PlistMsg, data)
    if status then
      self.plist = plist
      log:info("Adding %d programs to message queue", plist:getNumPrograms())
      for i = 1, plist:getNumPrograms() do
        self.requestQueue:pushLast(RpdataMsg(i - 1))
      end
      executeNextTransfer()
      return
    end

    local status, pdata = pcall(PdataMsg, data)
    if status then
      if self.plist == nil then
        error("Data process failed.")
      end
      local p = Program(pdata)
      table.insert(self.programs, p)
      local programIndex = self.plist:getProgramIndex(p:getName())
      log:info("Adding %d keygroups to message queue for prog %d (%s)", pdata:getNumKeyGroups(), programIndex - 1, p:getName())
      for i = 1, pdata:getNumKeyGroups() do
        self.requestQueue:pushLast(RkdataMsg(programIndex - 1, i - 1))
      end
      executeNextTransfer()
      return
    end

    local status, kdata = pcall(KdataMsg, data)
    if status then
      local prog = self.programs[kdata:getProgramNumber() + 1]
      prog:addKeyGroup(KeyGroup(kdata))
      executeNextTransfer()
      return
    end

    if request ~= nil then
      -- Something went wrong resend last message
      if errorCount < 5 then
        errorCount = errorCount + 1
        self.requestQueue:pushFirst(request)
        executeNextTransfer()
      else
        self.state = RECEIVING_PROGRAMS_FAILED
        self:stopAll()
        self:notifyListeners()
      end
    end
  end

  self.requestQueue:pushLast(RplistMsg())
  self.state = RECEIVING_PROGRAMS
  self:notifyListeners()
  executeNextTransfer()
end
