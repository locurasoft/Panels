require("ctrlrTestUtils")
require("Logger")
require("MockPanel")
require("controller/YamahaDX7Controller")
require("controller/YamahaDX7ControllerAutogen")
require("controller/onPanelBeforeLoad")
require 'lunity'
require 'lemock'
module( 'YamahaDX7ControllerTest', lunity )

local BANK_BUFFER_SIZE = 36048

local log = Logger("YamahaDX7ControllerTest")

local percSpaceMap = {
  ["vp30"] = 41,
  ["modulator-88"] = 0,
  ["pp5"] = 0,
  ["op2EgLevel1"] = 99,
  ["pitchegrate3"] = 0,
  ["op2EgLevel2"] = -7,
  ["vp153"] = 114,
  ["pp26"] = 0,
  ["op5EgRate2"] = 75,
  ["op4freqcoarse"] = 1,
  ["transpose"] = 28,
  ["modulator-50"] = 0,
  ["op4EgLevel3"] = 90,
  ["op4EgRate2"] = 98,
  ["vp35"] = 15,
  ["op6EgLevel2"] = 27,
  ["vp72"] = 35,
  ["op1EgLevel1"] = 0,
  ["op1level"] = 0,
  ["modulator-5"] = 0,
  ["vp154"] = 99,
  ["vp78"] = 0,
  ["op1EgRate3"] = 0,
  ["vp119"] = 0,
  ["op2EgLevel4"] = 77,
  ["pitchegrate4"] = 4,
  ["vp115"] = 99,
  ["vp145"] = 0,
  ["modulator-14"] = 0,
  ["vp53"] = 27,
  ["op3mode"] = 0,
  ["vp116"] = 0,
  ["main_grp1-1"] = 0,
  ["sendPatch"] = 0,
  ["info-lbl"] = 0,
  ["info-lbl-box"] = 0,
  ["main_grp5-1"] = 0,
  ["op1EgRate1"] = 4,
  ["pitchmodsense"] = 5,
  ["vp117"] = 0,
  ["main_grp2"] = 0,
  ["Name1"] = 0,
  ["vp96"] = 0,
  ["vp152"] = 101,
  ["vp141-1"] = 0,
  ["vp150"] = 12,
  ["vp149"] = 3,
  ["op1mode"] = 0,
  ["modulator-28"] = 0,
  ["vp148"] = 4,
  ["vp147"] = 0,
  ["vp146"] = 80,
  ["op4mode"] = 0,
  ["pp4"] = 0,
  ["op1EgRate4"] = 22,
  ["vp34"] = 34,
  ["op2detune"] = 0,
  ["pitchdepth"] = 50,
  ["Voice_PatchSelectControl-8"] = 0,
  ["vp98"] = 0,
  ["modulator-31"] = 0,
  ["op5mode"] = 0,
  ["modulator-44"] = 0,
  ["op3detune"] = 0,
  ["op2EgRate2"] = 99,
  ["modulator-57"] = 0,
  ["main_grp1-2"] = 0,
  ["op5level"] = 0,
  ["op6EgLevel1"] = 1,
  ["op6freqcoarse"] = 1,
  ["modulator-30"] = 0,
  ["op1EgLevel2"] = 0,
  ["modulator-20"] = 0,
  ["pitcheglevel2"] = 0,
  ["pp13"] = 0,
  ["op4EgRate4"] = 2,
  ["vp94"] = 99,
  ["main_grp7-1"] = 0,
  ["main_grp3"] = 0,
  ["modulator-1"] = 0,
  ["disableMemProt"] = 0,
  ["op6EgRate2"] = 67,
  ["modulator-13"] = 0,
  ["op4freqfine"] = 6,
  ["vp151"] = 80,
  ["op6EgRate1"] = 240,
  ["pitcheglevel4"] = 4,
  ["pp15-2"] = 0,
  ["modulator-65"] = 0,
  ["op3EgLevel2"] = 3,
  ["modulator-51"] = 0,
  ["pitchegrate1"] = 2,
  ["vp77"] = 15,
  ["pp15-1"] = 0,
  ["op2EgRate1"] = 2,
  ["op3"] = 0,
  ["pp3"] = 0,
  ["vp11"] = 97,
  ["op5EgLevel3"] = 74,
  ["modulator-68"] = 0,
  ["vp10"] = 99,
  ["vp9"] = 41,
  ["vp31"] = 87,
  ["op5"] = 0,
  ["modulator-97"] = 0,
  ["modulator-12"] = 0,
  ["vp14"] = 15,
  ["op5EgLevel1"] = 3,
  ["vp13"] = 25,
  ["op1EgLevel4"] = 47,
  ["op2EgLevel3"] = 99,
  ["pp64"] = 0,
  ["vp99"] = 0,
  ["op1"] = 0,
  ["vp15"] = 0,
  ["vp92"] = 42,
  ["op5EgRate4"] = 0,
  ["modulator-96"] = 0,
  ["op3EgLevel4"] = 30,
  ["op6EgRate3"] = 0,
  ["op6EgLevel4"] = 77,
  ["vp52"] = 96,
  ["pp9"] = 0,
  ["modulator-89"] = 0,
  ["vp114"] = 39,
  ["vp75"] = 16,
  ["op6mode"] = 0,
  ["op6freqfine"] = 7,
  ["op3freqcoarse"] = 1,
  ["modulator-3"] = 0,
  ["op6detune"] = 0,
  ["feedback"] = 62,
  ["pp15"] = 0,
  ["op6level"] = 0,
  ["Voice_PatchSelectControl-6"] = 0,
  ["vp8"] = 50,
  ["op2mode"] = 0,
  ["vp120"] = 0,
  ["op2EgRate3"] = 0,
  ["vp55"] = 50,
  ["op4EgRate1"] = 3,
  ["main_grp1"] = 0,
  ["pitcheglevel3"] = 9,
  ["vp95"] = 50,
  ["vp54"] = 0,
  ["op4detune"] = 0,
  ["vp51"] = 99,
  ["vp33"] = 0,
  ["vp113"] = 46,
  ["op3level"] = 0,
  ["op3EgRate1"] = 4,
  ["modulator-86"] = 0,
  ["op4level"] = 0,
  ["modulator-66"] = 0,
  ["op5EgRate3"] = 0,
  ["vp118"] = 0,
  ["op3freqfine"] = 3,
  ["op3EgLevel1"] = 2,
  ["lfosync"] = 5,
  ["vp136"] = 50,
  ["op5EgRate1"] = 3,
  ["modulator-78"] = 0,
  ["vp74"] = 0,
  ["main_grp2-1"] = 0,
  ["op3EgRate4"] = 2,
  ["op1EgLevel3"] = 88,
  ["op5EgLevel2"] = 1,
  ["pp2"] = 0,
  ["op2"] = 0,
  ["op5EgLevel4"] = 87,
  ["modulator-77"] = 0,
  ["op5detune"] = 0,
  ["pitcheglevel1"] = 0,
  ["pp16"] = 0,
  ["op5freqfine"] = 7,
  ["pp14"] = 0,
  ["modulator-76"] = 0,
  ["patchSelect"] = 0,
  ["op5freqcoarse"] = 1,
  ["op3EgLevel3"] = 83,
  ["op6EgLevel3"] = 56,
  ["vp36"] = 0,
  ["op4EgLevel1"] = 4,
  ["pitchegrate2"] = 99,
  ["op4EgRate3"] = 0,
  ["vp57"] = 0,
  ["vp56"] = 15,
  ["modulator-75"] = 0,
  ["modulator-74"] = 0,
  ["vp50"] = 50,
  ["op4EgLevel4"] = 58,
  ["op4EgLevel2"] = -1,
  ["main_grp5"] = 0,
  ["algorithm"] = 19,
  ["op1EgRate2"] = 99,
  ["vp29"] = 50,
  ["modulator-39"] = 0,
  ["ampdepth"] = 13,
  ["modulator-85"] = 0,
  ["lfowave"] = 1,
  ["op1freqfine"] = 3,
  ["vp32"] = 27,
  ["vp73"] = 99,
  ["vp71"] = 50,
  ["modulator-60"] = 0,
  ["modulator-58"] = 0,
  ["modulator-17"] = 0,
  ["pp11"] = 0,
  ["op3EgRate2"] = 98,
  ["modulator-29"] = 0,
  ["op1detune"] = 0,
  ["main_grp6"] = 0,
  ["vp76"] = 0,
  ["vp93"] = 30,
  ["vp97"] = 0,
  ["lfospd"] = 50,
  ["modulator-87"] = 0,
  ["op3EgRate3"] = 0,
  ["vp12"] = 59,
  ["op6EgRate4"] = 0,
  ["pp7"] = 0,
  ["op2EgRate4"] = 0,
  ["pp10"] = 0,
  ["main_grp7"] = 0,
  ["pp12"] = 0,
  ["op2level"] = 0,
  ["op6"] = 0,
  ["pp6"] = 0,
  ["op4"] = 0,
  ["op2freqfine"] = 0,
  ["modulator-67"] = 0,
  ["op1freqcoarse"] = 0,
  ["modulator-16"] = 0,
  ["op2freqcoarse"] = 0,
  ["lfodelay"] = 50
}

local modulatorMap = {
  ["vp30"] = 99,
  ["modulator-88"] = 0,
  ["pp5"] = 0,
  ["op2EgLevel1"] = 0,
  ["pitchegrate3"] = 0,
  ["op2EgLevel2"] = 0,
  ["vp153"] = 119,
  ["pp26"] = 0,
  ["op5EgRate2"] = 99,
  ["op4freqcoarse"] = 0,
  ["transpose"] = 0,
  ["modulator-50"] = 0,
  ["op4EgLevel3"] = 99,
  ["op4EgRate2"] = 0,
  ["vp35"] = 0,
  ["op6EgLevel2"] = 27,
  ["vp72"] = 99,
  ["op1EgLevel1"] = 0,
  ["op1level"] = 0,
  ["modulator-5"] = 0,
  ["vp154"] = 32,
  ["vp78"] = 0,
  ["op1EgRate3"] = 0,
  ["vp119"] = 0,
  ["op2EgLevel4"] = 99,
  ["pitchegrate4"] = 1,
  ["vp115"] = 99,
  ["vp145"] = 0,
  ["modulator-14"] = 0,
  ["vp53"] = 99,
  ["op3mode"] = 0,
  ["vp116"] = 99,
  ["main_grp1-1"] = 0,
  ["sendPatch"] = 0,
  ["info-lbl"] = 0,
  ["info-lbl-box"] = 0,
  ["main_grp5-1"] = 0,
  ["op1EgRate1"] = 0,
  ["pitchmodsense"] = 35,
  ["vp117"] = 99,
  ["main_grp2"] = 0,
  ["Name1"] = 0,
  ["vp96"] = 99,
  ["vp152"] = 101,
  ["vp141-1"] = 0,
  ["vp150"] = 24,
  ["vp149"] = 3,
  ["op1mode"] = 0,
  ["modulator-28"] = 0,
  ["vp148"] = 0,
  ["vp147"] = 1,
  ["vp146"] = 0,
  ["op4mode"] = 0,
  ["pp4"] = 0,
  ["op1EgRate4"] = 1,
  ["vp34"] = 0,
  ["op2detune"] = 0,
  ["pitchdepth"] = 50,
  ["Voice_PatchSelectControl-8"] = 0,
  ["vp98"] = 0,
  ["modulator-31"] = 0,
  ["op5mode"] = 0,
  ["modulator-44"] = 0,
  ["op3detune"] = 0,
  ["op2EgRate2"] = 0,
  ["modulator-57"] = 0,
  ["main_grp1-2"] = 0,
  ["op5level"] = 0,
  ["op6EgLevel1"] = 1,
  ["op6freqcoarse"] = 0,
  ["modulator-30"] = 0,
  ["op1EgLevel2"] = 0,
  ["modulator-20"] = 0,
  ["pitcheglevel2"] = 0,
  ["pp13"] = 0,
  ["op4EgRate4"] = 1,
  ["vp94"] = 99,
  ["main_grp7-1"] = 0,
  ["main_grp3"] = 0,
  ["modulator-1"] = 0,
  ["disableMemProt"] = 0,
  ["op6EgRate2"] = 67,
  ["modulator-13"] = 0,
  ["op4freqfine"] = 0,
  ["vp151"] = 78,
  ["op6EgRate1"] = 240,
  ["pitcheglevel4"] = 99,
  ["pp15-2"] = 0,
  ["modulator-65"] = 0,
  ["op3EgLevel2"] = 0,
  ["modulator-51"] = 0,
  ["pitchegrate1"] = 0,
  ["vp77"] = 0,
  ["pp15-1"] = 0,
  ["op2EgRate1"] = 0,
  ["op3"] = 0,
  ["pp3"] = 0,
  ["vp11"] = 99,
  ["op5EgLevel3"] = 99,
  ["modulator-68"] = 0,
  ["vp10"] = 99,
  ["vp9"] = 99,
  ["vp31"] = 99,
  ["op5"] = 0,
  ["modulator-97"] = 0,
  ["modulator-12"] = 0,
  ["vp14"] = 0,
  ["op5EgLevel1"] = 0,
  ["vp13"] = 0,
  ["op1EgLevel4"] = 99,
  ["op2EgLevel3"] = 99,
  ["pp64"] = 0,
  ["vp99"] = 0,
  ["op1"] = 0,
  ["vp15"] = 0,
  ["vp92"] = 99,
  ["op5EgRate4"] = 1,
  ["modulator-96"] = 0,
  ["op3EgLevel4"] = 99,
  ["op6EgRate3"] = 0,
  ["op6EgLevel4"] = 99,
  ["vp52"] = 99,
  ["pp9"] = 0,
  ["modulator-89"] = 0,
  ["vp114"] = 0,
  ["vp75"] = 99,
  ["op6mode"] = 0,
  ["op6freqfine"] = 0,
  ["op3freqcoarse"] = 0,
  ["modulator-3"] = 0,
  ["op6detune"] = 0,
  ["feedback"] = 99,
  ["pp15"] = 0,
  ["op6level"] = 0,
  ["Voice_PatchSelectControl-6"] = 0,
  ["vp8"] = 99,
  ["op2mode"] = 0,
  ["vp120"] = 0,
  ["op2EgRate3"] = 0,
  ["vp55"] = 0,
  ["op4EgRate1"] = 0,
  ["main_grp1"] = 0,
  ["pitcheglevel3"] = 99,
  ["vp95"] = 99,
  ["vp54"] = 99,
  ["op4detune"] = 0,
  ["vp51"] = 99,
  ["vp33"] = 99,
  ["vp113"] = 99,
  ["op3level"] = 0,
  ["op3EgRate1"] = 0,
  ["modulator-86"] = 0,
  ["op4level"] = 0,
  ["modulator-66"] = 0,
  ["op5EgRate3"] = 0,
  ["vp118"] = 99,
  ["op3freqfine"] = 0,
  ["op3EgLevel1"] = 0,
  ["lfosync"] = 0,
  ["vp136"] = 50,
  ["op5EgRate1"] = 0,
  ["modulator-78"] = 0,
  ["vp74"] = 99,
  ["main_grp2-1"] = 0,
  ["op3EgRate4"] = 1,
  ["op1EgLevel3"] = 99,
  ["op5EgLevel2"] = 0,
  ["pp2"] = 0,
  ["op2"] = 0,
  ["op5EgLevel4"] = 99,
  ["modulator-77"] = 0,
  ["op5detune"] = 0,
  ["pitcheglevel1"] = 99,
  ["pp16"] = 0,
  ["op5freqfine"] = 0,
  ["pp14"] = 0,
  ["modulator-76"] = 0,
  ["patchSelect"] = 0,
  ["op5freqcoarse"] = 0,
  ["op3EgLevel3"] = 99,
  ["op6EgLevel3"] = 99,
  ["vp36"] = 0,
  ["op4EgLevel1"] = 0,
  ["pitchegrate2"] = 99,
  ["op4EgRate3"] = 0,
  ["vp57"] = 0,
  ["vp56"] = 0,
  ["modulator-75"] = 0,
  ["modulator-74"] = 0,
  ["vp50"] = 99,
  ["op4EgLevel4"] = 99,
  ["op4EgLevel2"] = 0,
  ["main_grp5"] = 0,
  ["algorithm"] = 99,
  ["op1EgRate2"] = 0,
  ["vp29"] = 99,
  ["modulator-39"] = 0,
  ["ampdepth"] = 31,
  ["modulator-85"] = 0,
  ["lfowave"] = 1,
  ["op1freqfine"] = 0,
  ["vp32"] = 99,
  ["vp73"] = 99,
  ["vp71"] = 99,
  ["modulator-60"] = 0,
  ["modulator-58"] = 0,
  ["modulator-17"] = 0,
  ["pp11"] = 0,
  ["op3EgRate2"] = 0,
  ["modulator-29"] = 0,
  ["op1detune"] = 0,
  ["main_grp6"] = 0,
  ["vp76"] = 0,
  ["vp93"] = 99,
  ["vp97"] = 0,
  ["lfospd"] = 50,
  ["modulator-87"] = 0,
  ["op3EgRate3"] = 0,
  ["vp12"] = 99,
  ["op6EgRate4"] = 0,
  ["pp7"] = 0,
  ["op2EgRate4"] = 1,
  ["pp10"] = 0,
  ["main_grp7"] = 0,
  ["pp12"] = 0,
  ["op2level"] = 0,
  ["op6"] = 0,
  ["pp6"] = 0,
  ["op4"] = 0,
  ["op2freqfine"] = 0,
  ["modulator-67"] = 0,
  ["op1freqcoarse"] = 0,
  ["modulator-16"] = 0,
  ["op2freqcoarse"] = 0,
  ["lfodelay"] = 50
}


function setup()
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)

  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
  end
  regGlobal("panel", MockPanel("Yamaha-DX7.panel", midiListener))
  onPanelBeforeLoad()
end

function teardown()
  delGlobal("midiService")
end

function testOnPatchDroppedToPanel()
  loadPatchFromFile("C:/ctrlr/syxfiles/yamahadx7_single2.syx", panel, modulatorMap, "Name1", "New Patch ")
end

function testOnBankDroppedToPanel()
  loadBankFromFile(yamahaDX7Controller, "C:/ctrlr/syxfiles/dx7patch/DJW001.SYX", panel, percSpaceMap, "Name1", {"Perc*Bells", "Perc-space"})
end

function testLoadAndSendBank()
  loadBankFromFile(yamahaDX7Controller, "C:/ctrlr/syxfiles/dx7patch/DJW001.SYX", panel, percSpaceMap, "Name1", {"Perc*Bells", "Perc-space"})
--	yamahaDX7Controller
end

function testEditAndSendBank()
  compareEditedBankWithFile(yamahaDX7Controller, "C:/ctrlr/syxfiles/dx7patch/ROM1A.SYX", panel,
    {  ["op1level"] = 0 }, "C:/ctrlr/syxfiles/dx7patch/ROM1A-2.SYX")
end


runTests{useANSI = false}