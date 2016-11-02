require("AbstractController")
require("Logger")

local log = Logger("DrumMapController")

local disablePad = function(comp)
  comp:setProperty("uiButtonColourOff", "ff93b4ff", false)
  comp:setProperty("uiButtonColourOn", "ff93b4ff", false)
end

local enablePad = function(comp)
  comp:setProperty("uiButtonColourOff", "0xff0000ff", false)
  comp:setProperty("uiButtonColourOn", "0xff0000ff", false)
end

local setPadValue = function(padName, value)
  local pad = panel:getComponent(padName)

  if value == nil or value == "" then
    pad:setProperty("componentVisibleName", "", true)
    pad:setProperty("componentLabelVisible", 0, true)
  else
    pad:setProperty("componentLabelVisible", 1, true)
    pad:setProperty("componentVisibleName", value, true)
  end
end

local getKeyGroupName = function(comp)
  local grpName = comp:getProperty("componentGroupName")
  local kgIndex = string.sub(grpName, 9, string.find(grpName, "-grp") - 1)
  return string.format("KeyGroup %s", kgIndex)
end

DrumMapController = {}
DrumMapController.__index = DrumMapController

setmetatable(DrumMapController, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function DrumMapController:_init(drumMap, sampleList)
  AbstractController._init(self)
  self.drumMap = drumMap
  drumMap:addListener(self, "updateDrumMap")
  self.sampleList = sampleList
  sampleList:addListener(self, "updateSampleList")
end

function DrumMapController:updateDrumMap(drumMap)
  --
  -- Update pads
  --
  panel:getComponent("drumMapSelectionLabel"):setProperty("uiLabelText", "", false)

  local numPads = drumMap:getNumKeyGroups()

  for i = 1,16 do
    local padName = string.format("drumMap-%d", i)
    if drumMap:isSelectedKeyGroup(i) then
      local comp = panel:getComponent(padName)
      enablePad(comp)

      local kgName = getKeyGroupName(comp)
      panel:getComponent("drumMapSelectionLabel"):setProperty("uiLabelText", kgName, false)
    else
      disablePad(panel:getComponent(padName))
    end
    local samplesOfPad = drumMap:getSamplesOfKeyGroup(i)
    setPadValue(padName, samplesOfPad)

    self:toggleVisibility(padName, i <= numPads)
  end

  --
  -- Update floppy info
  --
  local numFloppies = drumMap:getNumFloppies()
  local numFloppiesText = string.format("# Floppies to be transfered: %d", numFloppies)
  panel:getComponent("numFloppiesLabel"):setText(numFloppiesText)

  local floppyUsagePercent = drumMapService:getFloppyUsagePercent(drumMap)
  local floppyUsageBar = panel:getModulatorByName("floppyUsageBar")
  floppyUsageBar:setValue(floppyUsagePercent, false)

  local color = "FF99CE65"
  if floppyUsagePercent > 90 then
    color = "FFCC3824"
  elseif floppyUsagePercent > 75 then
    color = "FFCCAA24"
  end
  floppyUsageBar:getComponent():setProperty("uiSliderThumbColour", color, false)

  --
  -- Update assignment controls
  --
  self:toggleActivation("assignSample", drumMap:isReadyForAssignment())
  self:toggleActivation("clearSample", not drumMap:isClear())
  self:toggleActivation("clearAllSamples", not drumMap:isClear())
  self:toggleActivation("transferSamples", not drumMap:isClear())

  --
  -- Update range controls
  --
  local isPadSelected = drumMap:getSelectedKeyGroup() ~= nil
  self:toggleActivation("drumMapLowKey", isPadSelected)
  self:toggleActivation("drumMapHighKey", isPadSelected)
  self:toggleActivation("defaultDrumMapButton", isPadSelected)

  if isPadSelected then
    local keyRanges = drumMap:getSelectedKeyRangeValues()
    local lowKeyMod = panel:getModulatorByName("drumMapLowKey")
    lowKeyMod:setValue(keyRanges[1], false)
    lowKeyMod:setProperty("modulatorMax", keyRanges[2], false)

    local highKeyMod = panel:getModulatorByName("drumMapHighKey")
    highKeyMod:setValue(keyRanges[2], false)
    highKeyMod:setProperty("modulatorMin", keyRanges[1], false)
  end
end

function DrumMapController:updateStatus(message)
  panel:getComponent("lcdLabel"):setText(message)
end

function DrumMapController:transferSamples()
  local logFilePath
  local numSamplesBefore = -1
  local expectedNumSamples = -1

  local rslistFunc = function()
    midiService:sendMidiMessage(RslistMsg())
  end

  local midiCallbackFunc = function(data)
    local msg = SlistMsg(data)
    if msg ~= nil then
      local numSamples = msg:getNumSamples()
      if numSamplesBefore == -1 then
        numSamplesBefore = numSamples
      elseif expectedNumSamples == -1 then
        expectedNumSamples = s2kDieService:getNumGeneratedSamples(logFilePath)
      elseif numSamples == numSamplesBefore + expectedNumSamples then
        sampleList:addSamples(msg)
        processController:abort()

        local wavList = drumMap:retrieveNextFloppy()
        if wavList == nil then
          self:updateStatus("Data transfer done.")
        else
          self:updateStatus(string.format("Transfering 1:st floppy to Akai S2000..."))
          executeTransfer(wavList)
        end
      else
      end
    end
  end

  local executeTransfer = function(wavList)
    local transferProc = Process()
      :withPath(settings:getWorkFolder())
      :withLaunchVariable("wavFiles", wavList)
      :withLaunchGenerator(s2kDieService:s2kDieLauncher())
      :withLaunchGenerator(hxcService:getHxcLauncher())
      :withAbortGenerator(hxcService:getHxcAborter())
      :withMidiCallback(midiCallbackFunc)
      :withMidiSender(rslistFunc, 1000)
      :build()

    logFilePath = transferProc:getLogFilePath()

    local result = processController:execute(transferProc)
    if result then
      utils.infoWindow("Load samples", "Please select to load all from\nfloppy on the Akai S2000.")
      self:updateStatus("Transfering samples...")
    else
      self:updateStatus("Failed to transfer data.\nPlease cancel process")
    end
  end

  local wavList = drumMap:retrieveNextFloppy()
  if wavList == nil then
    drumMapController:updateStatus("Data transfer done.")
  else
    drumMapController:updateStatus(string.format("Transfering 1:st floppy to Akai S2000..."))
    executeTransfer(wavList)
  end
end

function DrumMapController:transferFloppyImage()
  self:updateStatus(string.format("Transfering floppy image\nto Akai S2000..."))

  local transferProc = Process()
    :withPath(settings:getWorkFolder())
    :withLaunchVariable("imgPath", settings:getFloppyImgPath())
    :withLaunchGenerator(hxcService:getHxcLauncher())
    :withAbortGenerator(hxcService:getHxcAborter())
    :build()

  local result = processController:execute(transferProc)
  if result then
    utils.infoWindow("Load samples", "Please select to load all from\nfloppy on the Akai S2000.\n\nPress OK when done.")
    processController:abort()
  else
    self:updateStatus("Failed to transfer data.\nPlease cancel process")
  end
end

function DrumMapController:requestSampleList()
  local rslistFunc = function()
    midiService:sendMidiMessage(RslistMsg())
  end

  local midiCallbackFunc = function(data)
    local slist = SlistMsg(data)
    if slist then
      processController:abort()
      sampleList:addSamples(slist)
    end
  end

  local rslistProc = Process()
    :withMidiCallback(midiCallbackFunc)
    :withMidiSender(rslistFunc, 100)
    :build()

  local result = processController:execute(rslistProc)
  if result then
    self:updateStatus("Receiving sample list...")
  else
    self:updateStatus("Failed to receive data.\nPlease cancel process")
  end

end

function DrumMapController:loadOs()
  local statCount = 0

  local rstatFunc = function()
    midiService:sendMidiMessage(Rstat())
  end

  local statFunc = function(data)
    local statMsg = StatMsg(data)
    if statMsg ~= nil then
      if statCount > 20 then
        statCount = statCount + 1
      else
        processController:abort()
        self:updateStatus("Akai S2000 OS loaded.")
        self:toggleActivation("loadOsButton", true)
      end
    end
  end

  local transferProc = Process()
    :withPath(settings:getWorkFolder())
    :withLaunchVariable("imgPath", cutils.toFilePath(settings:getWorkFolder(), "osimage.img"))
    :withLaunchGenerator(hxcService:getHxcLauncher())
    :withAbortGenerator(hxcService:getHxcAborter())
    :withMidiCallback(statFunc)
    :withMidiSender(rstatFunc, 1000)

  self:toggleActivation("loadOsButton", false)

  local result = processController:execute(transferProc)
  if result then
    self:updateStatus("Loading Akai S2000 OS...")
  else
    self:updateStatus("Failed to load OS.\nPlease cancel process")
  end
end

function DrumMapController:updateSampleList(sl)
  local keyGroups = self.drumMap:getKeyGroups()
  local list = sl:getSampleList()
  local stereoSampleList = drumMapService:generateStereoSampleList(list)
  for k, stereoSample in pairs(stereoSampleList) do
    for l, keyGroup in pairs(keyGroups) do
      local matchingZoneIndex = 0
      if type(stereoSample) == "string" then
        -- Mono sample
        matchingZoneIndex = drumMapService:getUnloadedMatchingZoneIndex(keyGroup, stereoSample)
      else
        -- Stereo sample
        matchingZoneIndex = drumMapService:getUnloadedMatchingZoneIndex(keyGroup, string.sub(stereoSample[1], 1, #stereoSample[1] - 2))
      end
      if matchingZoneIndex > 0 then
        self.drumMap:replaceKeyGroupZoneWithSample(l, matchingZoneIndex, stereoSample)
      end
    end
  end
end

function DrumMapController:assignFile(file)
  if file ~= nil then
    if not drumMapService:isValidSampleFile(file) then
      self:toggleActivation("assignSample", 1)
      self:updateStatus("Please select a wav file")
      return
    end

    drumMap:setSelectedSample(file)
  end

  if not drumMap:isReadyForAssignment() then
    self:updateStatus("Select a sample and a key group.")
    return
  end

  local result = drumMapService:assignSample(self.drumMap)
  self:updateStatus(result)
end

function DrumMapController:assignSample(sampleName)
  if sampleName ~= nil then
    drumMap:setSelectedSample(sampleName)
  end

  if not drumMap:isReadyForAssignment() then
    self:updateStatus("Select a sample and a key group.")
    return
  end

  local result = drumMapService:assignSample(self.drumMap)
  self:updateStatus(result)
end
