require("ctrlrTestUtils")
require("Logger")
require("MockPanel")
require("service/EmuProteus2InstrumentService")
require 'lunity'
require 'lemock'
module( 'EmuProteus2InstrumentServiceTest', lunity )

local log = Logger("EmuProteus2InstrumentServiceTest")

function setup()
  tested = EmuProteus2InstrumentService()
end

function testC2m()
  local result = tested:c2m(2)
  assertEqual(result, 257)
  
  result = tested:c2m(33)
  assertEqual(result, 526)
end


runTests{useANSI = false}
