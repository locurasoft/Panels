require("Process")
require("Logger")
require("cutils")

local log = Logger("TransferSamplesProcess")

SAMPLES_FLOPPY_TRANSFER_DONE = 16
TRANSFERRING_SAMPLES_FLOPPY  = 17

local midiSender = function()
  midiService:sendMidiMessage(RslistMsg())
end

TransferSamplesProcess = {}
TransferSamplesProcess.__index = TransferSamplesProcess

setmetatable(TransferSamplesProcess, {
  __index = Process, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function TransferSamplesProcess:_init(drumMap, sampleList)
  Process._init(self)
  self.drumMap = drumMap
  self.sampleList = sampleList
end

function TransferSamplesProcess:execute()
  local midiCallback
  local numSamplesBefore = -1
  local expectedNumSamples = -1

  local executeTransfer = function(wavList)
    self:registerMidiCallback(midiCallback)
    self:launchMidiSender(midiSender, 1000)
    self:launchExternalProcess(
      { s2kDieService:s2kDieLauncher(), hxcService:getHxcLauncher() },
      { ["wavFiles"] = wavList },
      { hxcService:getHxcAborter() })

    self.state = TRANSFERRING_SAMPLES_FLOPPY
    self:notifyListeners()
  end

  midiCallback = function(data)
    local status, slist = pcall(SlistMsg, data)
    if status then
      local numSamples = slist:getNumSamples()
      if numSamplesBefore == -1 then
        numSamplesBefore = numSamples
      elseif expectedNumSamples == -1 then
        expectedNumSamples = s2kDieService:getNumGeneratedSamples(self:getLogFilePath())
      elseif numSamples == numSamplesBefore + expectedNumSamples then
        self.sampleList:addSamples(slist)

        local wavList = self.drumMap:retrieveNextFloppy()
        if wavList == nil then
          self:stopAll()
          self.state = SAMPLES_FLOPPY_TRANSFER_DONE
          self:notifyListeners()
        else
          self:stopExternalProcess()
          numSamplesBefore = -1
          expectedNumSamples = -1
          executeTransfer(wavList)
        end
      end
    end
  end

  local wavList = drumMap:retrieveNextFloppy()
  if wavList == nil then
    self:stopAll()
    self.state = SAMPLES_FLOPPY_TRANSFER_DONE
    self:notifyListeners()
  else
    executeTransfer(wavList)
  end
end
