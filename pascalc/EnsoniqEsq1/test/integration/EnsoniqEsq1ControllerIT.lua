require("ctrlrTestUtils")
require("PopupMenu")
require("MockPanel")
require("json4ctrlr")
require("cutils")

require("model/Bank")
require("model/Patch")

require("controller/onPanelBeforeLoad")
require("controller/EnsoniqEsq1Controller")
require("controller/EnsoniqEsq1ControllerAutogen")

require("service/MidiService")

require 'lunity'
require 'lemock'
module( 'EnsoniqEsq1ControllerIT', lunity )

local bankData = nil

local saveBank = function(bank, filename)
  local dataToWrite = bank:toStandaloneData()
  cutils.writeDataToFile(filename, dataToWrite)
end

function assertText(compName, expectedText)
  assertEqual(panel:getComponent(compName):getText(), expectedText)
end

function assertEnabled(compName)
  assertTrue(panel:getComponent(compName):isEnabled())
end

function assertDisabled(compName)
  assertFalse(panel:getComponent(compName):isEnabled())
end

function setup()
  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
  end
  
  openedAlertWindows = {}
  _G["AlertWindow"] = {
    InfoIcon = "APA",
    showOkCancelBox = function(title, message) 
      table.insert(openedAlertWindows, message)
      return true
    end
  }
  

  regGlobal("panel", MockPanel("Ensoniq-ESQ1.panel", midiListener))
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)

  regGlobal("midiService", MidiService())
  regGlobal("ensoniqEsq1Controller", EnsoniqEsq1Controller())

  local f = io.open("test/data/Clav_Shootout_Results.txt", "rb")
  local content = f:read("*all")
  f:close()
  bankData = MemoryBlock(content)

end

function teardown()
  delGlobal("midiService")
  delGlobal("panel")
  delGlobal("ensoniqEsq1Controller")

  bankData = nil
end

--function testOnPatchSelected()
--  local mod = panel:getModulatorByName("patchSelect")
--
--  local bank = Bank(bankData)
--  ensoniqEsq1Controller:assignBank(bank)
--
--  assertEqual(bank:getSelectedPatchIndex(), 0)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice1"), 2)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice31"), 2)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice80"), 2)
--  assertEqual(ensoniqEsq1Controller:getText("Name1"), "CLAV #")
--
--  ensoniqEsq1Controller:onPatchSelect(mod, 3)
--  assertEqual(bank:getSelectedPatchIndex(), 3)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice1"), 2)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice31"), 2)
--  assertEqual(ensoniqEsq1Controller:getText("Name1"), "CLAV*%")
--
--  ensoniqEsq1Controller:onPatchSelect(mod, 4)
--  assertEqual(bank:getSelectedPatchIndex(), 4)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice31"), 0)
--  assertEqual(ensoniqEsq1Controller:getText("Name1"), "CLAV-2")
--
--  ensoniqEsq1Controller:onPatchSelect(mod, 0)
--  assertEqual(bank:getSelectedPatchIndex(), 0)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice1"), 2)
--  assertEqual(ensoniqEsq1Controller:getValueByCustomName("Voice31"), 2)
--  assertEqual(ensoniqEsq1Controller:getText("Name1"), "CLAV #")
--end

--function testV2p()
--  local max = 5
--  local mod = panel:getModulatorByName("patchSelect")
--
--  local bank = Bank(bankData)
--  ensoniqEsq1Controller:assignBank(bank)
--
--  assertEqual(bank:getSelectedPatchIndex(), 0)
--
--  for i = 0, max do
--    ensoniqEsq1Controller:onPatchSelect(mod, i)
--    assertEqual(bank:getSelectedPatchIndex(), i)
--    --    ensoniqEsq1Controller:v2p(bank:getSelectedPatch())
--  end
--  
--  saveBank(bank, "syx1.syx")
--
--  for i = 0, max do
--    ensoniqEsq1Controller:onPatchSelect(mod, 39 - i)
--    assertEqual(bank:getSelectedPatchIndex(), 39 - i)
--    --    ensoniqEsq1Controller:v2p(bank:getSelectedPatch())
--  end
--  
--  saveBank(bank, "syx2.syx")
--end

function testReceiveBank()
  _G["POPUP_MENU_SHOW_RETVAL"] = 3
  ensoniqEsq1Controller:onLoadMenu()
  assertEqual(table.getn(midiMessages), 1)
  ensoniqEsq1Controller:onMidiReceived(CtrlrMidiMessage(bankData))
end

runTests{useANSI = false}
