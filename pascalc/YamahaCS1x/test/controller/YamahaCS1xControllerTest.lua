require("ctrlrTestUtils")
require("Logger")
require("MockPanel")
require("controller/YamahaCS1xController")
require("controller/YamahaCS1xControllerAutogen")
require("controller/onPanelBeforeLoad")
require("service/MidiService")
require 'lunity'
require 'lemock'
module( 'YamahaCS1xControllerTest', lunity )

local log = Logger("YamahaCS1xControllerTest")

function setup()
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)

  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
  end
  regGlobal("panel", MockPanel("Yamaha-CS1x.panel", midiListener))
  onPanelBeforeLoad()
end

function teardown()
  delGlobal("midiService")
end

function testOnEffectTypeChanged()
  local mod = MockModulator()
  mod:setValueMapped(256)
  mod:setValue(3)
  mod:setProperty("modulatorCustomNameGroup", "reverbParam")
  yamahaCS1xController:onEffectTypeChanged(mod, 3)
end

function testOnPatchDroppedToPanel()
  loadPatchFromFile("c:/ctrlr/syxfiles/CS1x/BA_303 Wave.SYX", panel, modulatorMap, "Name1", "303 Wave")
end

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

runTests{useANSI = false}
