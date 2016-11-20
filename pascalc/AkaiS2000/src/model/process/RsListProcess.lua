require("Process")
require("Logger")
require("cutils")

local log = Logger("RsListProcess")

SAMPLE_LIST_RECEIVED  = 48
RECEIVING_SAMPLE_LIST = 49

local midiSender = function()
  midiService:sendMidiMessage(RslistMsg())
end

RsListProcess = {}
RsListProcess.__index = RsListProcess

setmetatable(RsListProcess, {
  __index = Process, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RsListProcess:_init(sampleList)
  Process._init(self)
  self.sampleList = sampleList
end

function RsListProcess:execute()
  self.state = RECEIVING_SAMPLE_LIST
  self:notifyListeners()
  
  local midiCallback = function(data)
    local status, slist = pcall(SlistMsg, data)
    if status then
      self.sampleList:addSamples(slist)
      self:stopAll()
      self.state = SAMPLE_LIST_RECEIVED
      self:notifyListeners()
    end
  end

  self:registerMidiCallback(midiCallback)
  self:launchMidiSender(midiSender, 100)
end
