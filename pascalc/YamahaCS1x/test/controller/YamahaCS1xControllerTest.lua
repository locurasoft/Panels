require("ctrlrTestUtils")
require("Logger")
require("MockPanel")
require("MockTimer")
require("MockPopupMenu")
require("MockImage")
require("controller/YamahaCS1xController")
require("controller/YamahaCS1xControllerAutogen")
require("controller/onPanelBeforeLoad")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'YamahaCS1xControllerTest', lunity )

local log = Logger("YamahaCS1xControllerTest")

local modulatorMap = {
  ["l1LfoWave-2"] = 64,
  ["l2FilterResonance"] = 0,
  ["l3LowLimit"] = 0,
  ["layer1Enable"] = 64,
  ["l1PitchDecTime-3"] = 64,
  ["l3LfoPMod"] = 64,
  ["l1AmplifierGroup-3"] = 0,
  ["chorusParam15"] = 0,
  ["l1FilterRelease-1"] = 64,
  ["knob6Param3"] = 0,
  ["l1AmplifierGroup"] = 0,
  ["l1AmpPan-1"] = 0,
  ["knob6Param1"] = 0,
  ["l2NoteShift"] = 0,
  ["l1PitchRelTime-2"] = 64,
  ["l1FilterDecay"] = 64,
  ["l1VoiceBank"] = 50,
  ["variationParam2-1"] = 28,
  ["l2GeneralGroup"] = 0,
  ["l3FilterResonance"] = 0,
  ["layer2"] = 0,
  ["chorusParam16"] = 0,
  ["l1FilterCutoff"] = 0,
  ["l3PolyMode"] = 61,
  ["l4VelLimitHigh"] = 0,
  ["l1PitchRelTime-1"] = 64,
  ["layer4"] = 0,
  ["l1AmpVolume-2"] = 37,
  ["portaTime"] = 0,
  ["modulator-1"] = 0,
  ["l2VoiceBank"] = 739,
  ["variationParam12"] = 0,
  ["scene2Knob2"] = 0,
  ["l1FilterAttack-1"] = -60,
  ["variationGroup"] = 0,
  ["l1GeneralGroup"] = 0,
  ["l1AmpRelease"] = 64,
  ["variationParam4-1"] = 47,
  ["l1FilterAttack-3"] = 64,
  ["reverbParam9"] = 70,
  ["l1AmpAttack-2"] = 0,
  ["l1LfoSync-2"] = 64,
  ["l1PitchAttLvl-2"] = 1,
  ["reverbParam1"] = 0,
  ["knob6Sens-3"] = 0,
  ["l1LfoFMod-2"] = 127,
  ["l1SendsGroup-3"] = 0,
  ["l1SendsGroup-2"] = 0,
  ["chorusParam13"] = 0,
  ["l3VoiceBank"] = -63,
  ["l1AmpAttack-1"] = 1,
  ["l1AmpVolume-1"] = -63,
  ["l1FilterDecay-1"] = 1,
  ["l1LfoSync"] = -63,
  ["l1ReverbSend"] = -63,
  ["variationParam3-1"] = 0,
  ["l2LfoWave"] = -62,
  ["l1FilterDecay-3"] = 64,
  ["masterVolume"] = 127,
  ["chorusParam6"] = 0,
  ["l1NoteShift"] = 4,
  ["l4VelSensDepth"] = 61,
  ["l1AmpRelease-2"] = 2,
  ["scene1Knob1"] = 0,
  ["l1AmpVolume-3"] = 7,
  ["l1LfoPMod"] = 64,
  ["chorusParam8"] = 0,
  ["l1PitchInitLvl-3"] = 64,
  ["l1PitchInitLvl"] = 40,
  ["l1VelLimitHigh"] = 0,
  ["l1VariSend"] = 63,
  ["loadButton"] = 0,
  ["perfName7"] = 0,
  ["variationParam4"] = 0,
  ["reverbParam14"] = 0,
  ["perfName8"] = 0,
  ["l2FilterCutoffLabel"] = -64,
  ["variationParam5-1"] = 0,
  ["modulator-3"] = 0,
  ["knob3Value"] = 0,
  ["l1PitchRelTime-3"] = 64,
  ["l1AmpDecay-1"] = -62,
  ["l1FilterGroup-3"] = 0,
  ["perfName2"] = 0,
  ["l3LfoSync"] = 0,
  ["l2LfoGrp"] = 0,
  ["reverbType-1"] = 48,
  ["l1PitchRelLvl"] = 64,
  ["l1FilterGroup-2"] = 0,
  ["l3LfoSpeed"] = 64,
  ["reverbParam5"] = 0,
  ["l1FilterSustain-1"] = 0,
  ["l1VariSend-1"] = -24,
  ["l1FilterCutoffLabel"] = -64,
  ["performanceSelector"] = 0,
  ["chorusParam2"] = 0,
  ["l1PitchInitLvl-1"] = 64,
  ["variationParam1-1"] = 0,
  ["l1ChorusSend-3"] = 127,
  ["perfName4"] = 0,
  ["l4FilterResonance"] = 127,
  ["layer1"] = 0,
  ["chorusSendToReverb-6"] = 0,
  ["l2LfoSync"] = 127,
  ["l3VelLimitHigh"] = 1,
  ["l1LfoGrp"] = 0,
  ["variationParam16"] = 0,
  ["l2LfoSpeed"] = 1,
  ["variationParam10-1"] = 0,
  ["l4NoteShift"] = 61,
  ["l1AmpRelease-3"] = 1,
  ["arpegSubdivide"] = 7,
  ["reverbParam6"] = 0,
  ["l2VelocityGrp"] = 0,
  ["portaOn"] = 0,
  ["scene1Knob5"] = 0,
  ["l2Detune"] = -59,
  ["l1PitchAttTime-3"] = 64,
  ["l1FilterXY"] = 0,
  ["l2VelLimitHigh"] = 64,
  ["l1PitchDecTime"] = 1,
  ["l1PitchGroup"] = 0,
  ["layer2Enable"] = 64,
  ["l1AmpPan-3"] = 64,
  ["arpegSplit"] = 0,
  ["fcVariCtrlDepth"] = 0,
  ["variationParam11"] = 0,
  ["l1LfoSpeed"] = 1,
  ["l2VelLimitLow"] = 64,
  ["l1PitchDecTime-2"] = 0,
  ["l1AmpDecay-3"] = 0,
  ["reverbParam7"] = 0,
  ["scene2Knob1"] = 0,
  ["l1PitchRelLvl-1"] = 0,
  ["knob4Value"] = 0,
  ["l1HighLimit"] = 1,
  ["l1PitchAttTime-1"] = 64,
  ["Arpeggiator"] = 0,
  ["l2FilterResonanceLabel"] = -64,
  ["l1FilterGroup"] = 0,
  ["mwFilterCtrl"] = 0,
  ["l4VelocityGrp"] = 0,
  ["l2LfoFMod"] = 0,
  ["knob2Value"] = 0,
  ["l3VelLimitLow"] = -63,
  ["l1AmpDecay"] = 64,
  ["singlePatchName"] = 0,
  ["knob6Param4"] = 0,
  ["scene1Knob2"] = 0,
  ["l1SendsGroup"] = 0,
  ["knob6Value"] = 0,
  ["l1AmplifierGroup-1"] = 0,
  ["reverbParam11"] = 0,
  ["l1AmpPan-2"] = 8,
  ["l4Voice"] = 772,
  ["mwLFOPmodDepth"] = 0,
  ["knob6Sens-1"] = 0,
  ["l2LfoAMod"] = 64,
  ["l1AmpVolume"] = 52,
  ["l1AmpPan"] = 85,
  ["l1ReverbSend-2"] = 64,
  ["l1ReverbSend-1"] = 64,
  ["l1VariSend-2"] = 64,
  ["l1LfoFMod"] = 3,
  ["CommonUpper-7"] = 0,
  ["layer3"] = 0,
  ["variationParam10"] = 0,
  ["perfName1"] = 0,
  ["l1AmplifierGroup-2"] = 0,
  ["scene2Knob3"] = 0,
  ["l4FilterCutoffLabel"] = -64,
  ["modulator-2"] = 0,
  ["reverbParam2"] = 0,
  ["processingLabel"] = 0,
  ["l3VelSensDepth"] = 1,
  ["l4FilterResonanceLabel"] = 63,
  ["variationParam5"] = 69,
  ["variationParam9"] = 0,
  ["variationType-3"] = 0,
  ["chorusType-2"] = 0,
  ["l1PitchAttLvl"] = 1,
  ["chorusParam12"] = 0,
  ["reverbParam16"] = 0,
  ["l4HighLimit"] = 0,
  ["l1PitchAttTime-2"] = 1,
  ["layer3Enable"] = 1,
  ["reverbParam15"] = 0,
  ["variationSendToReverb"] = 64,
  ["l4GeneralGroup"] = 0,
  ["l1VelLimitLow"] = 64,
  ["chorusSendToReverb-5"] = 0,
  ["chorusSendToReverb-4"] = 0,
  ["chorusSendToReverb-3"] = 0,
  ["chorusSendToReverb-2"] = 0,
  ["l1AmpSustain-2"] = 0,
  ["chorusSendToReverb-1"] = 0,
  ["variationParam2"] = 0,
  ["l1FilterResonance"] = 1,
  ["modulator-5"] = 0,
  ["l1PitchGroup-1"] = 0,
  ["l1LfoAMod-2"] = 64,
  ["variationParam7"] = 0,
  ["variationParam14"] = 0,
  ["l3FilterResonanceLabel"] = -64,
  ["chorusParam1"] = 0,
  ["reverbParam3"] = 0,
  ["l1ChorusSend-1"] = 64,
  ["chorusParam10"] = 0,
  ["variationParam3"] = 0,
  ["reverbParam4"] = 0,
  ["variationParam13"] = 0,
  ["l3LfoFMod"] = 64,
  ["reverbParam10"] = 0,
  ["chorusType-1"] = 0,
  ["variationParam6"] = 0,
  ["reverbParam13"] = 0,
  ["l1Voice"] = -64,
  ["l1FilterGroup-1"] = 0,
  ["chorusParam3"] = 0,
  ["l1FilterRelease"] = 1,
  ["chorusParam4"] = 0,
  ["scene2Knob6"] = 0,
  ["l1VariSend-3"] = 64,
  ["l1LfoWave"] = 127,
  ["variationParam1"] = 0,
  ["chorusParam5"] = 0,
  ["l1FilterXY-3"] = 0,
  ["variationType-2"] = 0,
  ["chorusParam7"] = 0,
  ["l1AmpRelease-1"] = 64,
  ["l1ReverbSend-3"] = 64,
  ["l1LfoAMod"] = 64,
  ["l1AmpSustain-3"] = 64,
  ["variationParam8"] = 0,
  ["l1AmpAttack-3"] = 0,
  ["reverbType"] = 0,
  ["l1FilterAttack-2"] = 33,
  ["masterGroup"] = 0,
  ["reserved-2"] = 0,
  ["l1LfoSpeed-2"] = 64,
  ["knob6Param2"] = 0,
  ["fcFilterCtrl"] = 0,
  ["fcLFOFmodDepth"] = 0,
  ["arpegOn"] = 4,
  ["bendPitchCtrl"] = 0,
  ["mwLFOFmodDepth"] = 0,
  ["knob3Param"] = 0,
  ["l2LowLimit"] = 127,
  ["knob6Sens-2"] = 0,
  ["l2HighLimit"] = 64,
  ["knob6Sens-4"] = 0,
  ["variationSendToChorus"] = 0,
  ["l1Detune"] = -3,
  ["l1PitchAttLvl-1"] = 64,
  ["l3LfoGrp"] = 0,
  ["l4PolyMode"] = 116,
  ["l1FilterSustain"] = 64,
  ["l1AmpAttack"] = 2,
  ["l1VelSensOffs"] = -63,
  ["l3FilterCutoffLabel"] = 63,
  ["l1AmpSustain-1"] = 64,
  ["scene2Knob4"] = 0,
  ["l1VelSensDepth"] = -23,
  ["l1PitchRelLvl-2"] = 0,
  ["knob5Value"] = 0,
  ["l1FilterAttack"] = 64,
  ["sendsGroup"] = 0,
  ["l4Detune"] = 0,
  ["l1FilterXY-2"] = 0,
  ["scene2Knob5"] = 0,
  ["reverbParam8"] = 0,
  ["l1FilterSustain-3"] = 3,
  ["Voice154-23"] = 0,
  ["amplifierGroup"] = 0,
  ["scene1Knob4"] = 0,
  ["voiceGroup"] = 0,
  ["performanceCategory"] = 0,
  ["l1FilterRelease-3"] = 64,
  ["scene1Knob3"] = 0,
  ["l2VelSensDepth"] = 1,
  ["l1LowLimit"] = 1,
  ["l4VelLimitLow"] = 64,
  ["l3HighLimit"] = 63,
  ["l1LfoPMod-2"] = 1,
  ["l1PitchRelLvl-3"] = 64,
  ["l1FilterResonanceLabel"] = -63,
  ["l1AmpSustain"] = 64,
  ["l3NoteShift"] = 0,
  ["perfName5"] = 0,
  ["l2FilterCutoff"] = 0,
  ["l2PolyMode"] = -63,
  ["l3VelSensOffs"] = 64,
  ["layer4Enable"] = 2,
  ["l3VelocityGrp"] = 0,
  ["l4FilterCutoff"] = 0,
  ["knob1Value"] = 0,
  ["l1PitchInitLvl-2"] = 1,
  ["l3LfoAMod"] = -63,
  ["pitchGroup"] = 0,
  ["l3FilterCutoff"] = 127,
  ["l3LfoWave"] = 64,
  ["l1PitchRelTime"] = 1,
  ["l4VelSensOffs"] = 1,
  ["arpegHold"] = 0,
  ["perfName6"] = 0,
  ["modulator-4"] = 0,
  ["l2LfoPMod"] = 64,
  ["l1PitchGroup-2"] = 0,
  ["l1FilterRelease-2"] = 1,
  ["saveButton"] = 0,
  ["arpegTempo"] = 101,
  ["variationParam15"] = 0,
  ["l1AmpDecay-2"] = 1,
  ["l4LowLimit"] = 8,
  ["chorusSendToReverb"] = 0,
  ["l1PitchAttLvl-3"] = 64,
  ["arpegType"] = 9,
  ["l4VoiceBank"] = 75,
  ["l1ChorusSend-2"] = 64,
  ["lfoGroup"] = 0,
  ["l4LfoGrp"] = 0,
  ["l1PolyMode"] = 63,
  ["l3GeneralGroup"] = 0,
  ["l1SendsGroup-1"] = 0,
  ["l2VelSensOffs"] = 8,
  ["chorusParam11"] = 0,
  ["chorusParam9"] = 0,
  ["l1FilterSustain-2"] = 49,
  ["l1FilterDecay-2"] = -60,
  ["scene1Knob6"] = 0,
  ["l1PitchAttTime"] = 64,
  ["chorusParam14"] = 0,
  ["l1ChorusSend"] = 0,
  ["l1FilterXY-1"] = 0,
  ["perfName3"] = 0,
  ["l1PitchGroup-3"] = 0,
  ["filterGroup"] = 0,
  ["l3Voice"] = 1901,
  ["reverbParam12"] = 0,
  ["l3Detune"] = 63,
  ["l2Voice"] = 46,
  ["l1VelocityGrp"] = 0,
  ["l1PitchDecTime-1"] = 0
}

local midiCallback = nil

function setup()
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)
  regGlobal("timer", MockTimer())
  regGlobal("PopupMenu", MockPopupMenu)
  regGlobal("Image", MockImage)

  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
    if midiCallback ~= nil then
      midiCallback(midiMessage)
    end
  end
  regGlobal("panel", MockPanel("Yamaha-CS1x.panel", midiListener))
  onPanelBeforeLoad()
end

function teardown()
  delGlobal("midiService")
end

--function testOnPatchDroppedToPanel()
--  loadPatchFromFile("c:/ctrlr/syxfiles/CS1x/BA_303 Wave.SYX", panel, modulatorMap, "singlePatchName", "303 Wave")
--end

--function testOnBankDroppedToPanel()
--  loadBankFromFile(ensoniqEsq1Controller, "C:/ctrlr/syxfiles/EnsoniqESQ1/Esqhits^2.syx", panel, digpnoMap, "Name1", {"PIANO2", "DIGPNO"})
--end
--
--function testLoadAndSendBank()
--  compareLoadedBankWithFile(ensoniqEsq1Controller, "C:/ctrlr/syxfiles/EnsoniqESQ1/Esqhits^2.syx", panel, NUM_PATCHES)
--end
--
--function testEditAndSendBank()
--  compareEditedBankWithFile(ensoniqEsq1Controller, "C:/ctrlr/syxfiles/EnsoniqESQ1/Esqhits^2.syx", panel,
--    {  ["DCA1-Level"] = 0 }, "C:/ctrlr/syxfiles/EnsoniqESQ1/Esqhits^2-2.syx")
--end

--function testOnMidiReceived()
--  local t = {}
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 2E 60 00 00 39 30 39 20 45 51 64 20 11 7F 00 7F 7F 2B 7F 7F 40 70 7F 56 5C 7F 00 79 40 7F 40 40 00 05 00 00 02 00 03 00 60 40 40 40 13 00 5B 0C 07 04 18 F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 17 60 00 30 13 00 43 00 4C 00 00 44 00 22 00 4C 00 78 00 44 00 7F 40 40 30 40 1E 3C F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 09 60 00 50 29 00 00 50 40 00 00 00 00 0E F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 01 00 3F 0C 05 01 40 08 00 7F 42 34 40 00 7F 1E 40 01 02 40 40 40 40 40 01 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 44 F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 02 00 3F 05 00 01 40 08 00 64 40 40 40 00 7F 1E 40 01 02 40 40 40 40 40 00 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 61 F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 03 00 3F 06 00 01 40 08 00 64 40 40 40 00 7F 1E 40 01 02 40 40 40 40 40 00 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 5F F7"))
--  yamahaCS1xController.receivedMidiData = t
--  yamahaCS1xController.midiDump = true
--	yamahaCS1xController:onMidiReceived(CtrlrMidiMessage(MemoryBlock("F0 43 00 4B 00 29 60 04 00 3F 07 00 01 40 08 00 64 40 40 40 00 7F 1E 40 01 02 40 40 40 40 40 00 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 5D F7")))
--end
--
--function testOnMidiReceived2()
--  local t = {}
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 2E 60 00 00 44 69 73 74 20 4B 69 6B 14 70 40 40 37 40 40 36 40 3E 00 40 40 7F 40 40 40 40 40 40 01 0B 01 0A 01 16 01 15 29 20 40 40 10 00 51 00 04 04 3B F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 17 60 00 30 01 00 41 00 49 00 00 32 00 28 00 4B 00 37 00 4B 00 63 40 40 00 00 13 31 F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 09 60 00 50 7A 00 00 58 40 00 00 00 04 31 F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 01 00 3F 04 7E 01 40 08 00 5F 42 34 40 24 24 13 00 01 02 40 40 40 40 40 01 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 75 F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 02 00 3F 05 7E 00 34 08 00 3C 42 34 40 25 7F 13 00 01 02 40 40 40 40 40 01 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 47 F7"))
--  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 03 00 3F 06 7E 01 40 08 00 64 42 34 40 00 23 13 00 01 02 40 40 40 40 40 01 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 11 F7"))
--  yamahaCS1xController.receivedMidiData = t
--  yamahaCS1xController.midiDump = true
--  yamahaCS1xController:onMidiReceived(CtrlrMidiMessage(MemoryBlock("F0 43 00 4B 00 29 60 04 00 3F 07 7E 01 40 08 00 64 40 40 40 00 7F 13 00 01 02 40 40 40 40 40 00 40 40 40 40 01 7F 40 40 03 40 40 40 40 40 40 40 40 40 2A F7")))
--end

function testRequestDump()
  regGlobal("POPUP_MENU_SELECT_VALUE", 3)
  local t = {}
  table.insert(t, MemoryBlock("F0 43 00 4B 00 2E 60 00 00 44 69 73 74 20 4B 69 6B 14 70 40 40 37 40 40 36 40 3E 00 40 40 7F 40 40 40 40 40 40 01 0B 01 0A 01 16 01 15 29 20 40 40 10 00 51 00 04 01 3E F7"))
  table.insert(t, MemoryBlock("F0 43 00 4B 00 17 60 00 30 01 00 41 00 49 00 00 28 00 14 00 48 00 35 00 30 00 7F 40 40 00 00 13 53 F7"))
  table.insert(t, MemoryBlock("F0 43 00 4B 00 09 60 00 50 7A 00 00 58 40 00 00 00 04 31 F7"))
  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 01 00 3F 04 7E 01 40 08 00 1F 42 74 40 24 24 25 7F 01 02 40 7F 40 40 40 01 40 40 40 40 01 3F 40 40 00 40 40 40 40 40 40 40 40 40 68 F7"))
  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 02 00 3F 05 55 00 58 00 00 08 00 3C 42 34 40 25 7F 01 01 40 40 40 40 40 01 40 01 40 40 40 40 01 7F 03 40 03 40 40 40 40 40 40 40 5C F7"))
  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 03 00 3F 06 7E 01 58 00 01 08 00 64 42 34 40 25 7F 01 00 40 7F 40 40 40 01 40 01 40 40 40 40 01 7F 03 40 03 40 40 40 40 40 40 40 49 F7"))
  table.insert(t, MemoryBlock("F0 43 00 4B 00 29 60 04 00 3F 07 7E 01 58 00 01 08 00 64 40 40 40 25 7F 01 00 40 7F 40 40 40 00 40 01 40 40 40 40 01 7F 03 40 03 40 40 40 40 40 40 40 3E F7"))

  midiCallback = function(midiMessage)
    yamahaCS1xController.midiFunction(table.remove(t, 1))
  end
  yamahaCS1xController:onLoadMenu()
end

function testOnEffectTypeChanged()
  local mod = MockModulator()
  mod:setValueMapped(2561)
  mod:setValue(3)
  mod:setProperty("modulatorCustomNameGroup", "variationParam")
--  yamahaCS1xController:onEffectTypeChanged(mod, 3)

  mod:setValueMapped(9728)
  mod:setValue(40)
  mod:setProperty("modulatorCustomNameGroup", "variationParam")
  yamahaCS1xController:onEffectTypeChanged(mod, 40)
end

runTests{useANSI = false}
