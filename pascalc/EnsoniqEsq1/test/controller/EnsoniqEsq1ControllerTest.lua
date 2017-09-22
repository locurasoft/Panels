require("ctrlrTestUtils")
require("Logger")
require("MockPanel")
require("controller/EnsoniqEsq1Controller")
require("controller/EnsoniqEsq1ControllerAutogen")
require("controller/onFilesDroppedToPanel")
require 'lunity'
require 'lemock'
module( 'EnsoniqEsq1ControllerTest', lunity )

local BANK_BUFFER_SIZE = 36048

local log = Logger("EnsoniqEsq1ControllerTest")

function setup()
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)
  
  midiMessages = {}
  local midiListener = function(midiMessage)
    table.insert(midiMessages, midiMessage)
  end
  regGlobal("panel", MockPanel("Ensoniq-ESQ1.panel", midiListener))
--  regGlobal("midiService", MidiService())
  regGlobal("BANK_BUFFER_SIZE", 8166)
  regGlobal("PATCH_BUFFER_SIZE", 210)
  regGlobal("LUA_CONTRUCTOR_NAME", "LUA_CLASS_NAME")
  regGlobal("SINGLE_DATA_SIZE", 204)
  regGlobal("NUM_PATCHES", 40)
  regGlobal("ESQ1_EXCL_HEADER", MemoryBlock({ 0xF0, 0x0F, 0x02, 0x00 }))
  regGlobal("HEADER_SIZE", ESQ1_EXCL_HEADER:getSize())
  regGlobal("COMPLETE_HEADER_SIZE", HEADER_SIZE + 1)
  
  regGlobal("ensoniqEsq1Controller", EnsoniqEsq1Controller())
end

function teardown()
  delGlobal("midiService")
end

function testOnFilesDroppedToPanel()
  local sa = StringArray()
  sa:add("test/data/SNADRM-ESQ1.syx")
  onFilesDroppedToPanel(sa, 0, 0)
  panel:debugPrint()
end

function testOnMidiReceived()
  local tested = EnsoniqEsq1Controller()
  tested:onMidiReceived(CtrlrMidiMessage(MemoryBlock("f0 0f 02 00 01 0d 04 09 04 08 05 05 04 04 04 00 02 0e 07 02 08 00 00 00 00 0f 00 07 02 07 02 02 00 00 00 09 00 0e 07 00 00 00 00 00 00 06 02 01 00 0a 02 00 00 00 00 00 00 0e 07 0e 07 0e 07 0e 00 02 03 0f 03 0b 02 00 00 00 00 09 00 0a 07 08 07 0e 06 09 01 08 01 0f 03 04 02 06 03 01 01 00 00 08 01 00 08 0f 0f 00 04 05 01 00 00 0f 03 0f 07 0a 00 0f 0f 0f 0f 0f 07 04 02 00 02 01 00 02 00 02 00 0b 00 08 0f 04 0f 0e 07 00 00 04 02 08 01 01 00 04 00 06 00 0b 00 08 0f 0f 0f 00 00 00 00 04 02 00 00 01 00 0e 0f 04 00 0b 00 08 0f 0f 0f 00 00 00 00 0c 06 00 00 00 00 06 05 0b 0a 0f 03 06 05 00 00 0e 03 03 06 0e 06 00 00 02 08 0e 01 f7")))
end

runTests{useANSI = false}
