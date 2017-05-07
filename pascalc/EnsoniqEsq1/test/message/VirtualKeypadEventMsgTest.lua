require("ctrlrTestUtils")
require("Logger")
require("message/VirtualKeypadEventMsg")
require 'lunity'
require 'lemock'
module( 'VirtualKeypadEventMsgTest', lunity )

local log = Logger("VirtualKeypadEventMsgTest")

function setup()
  _G["BANK_BUFFER_SIZE"] = 8166
  _G["PATCH_BUFFER_SIZE"] = 210
  _G["SINGLE_DATA_SIZE"] = 204
  _G["NUM_PATCHES"] = 40

  -- , 0x01
  _G["ESQ1_EXCL_HEADER"] = MemoryBlock({ 0xF0, 0x0F, 0x02, 0x00 })
  _G["HEADER_SIZE"] = ESQ1_EXCL_HEADER:getSize()
  _G["END_OF_EXCL"] = MemoryBlock({ 0xF7 })
  _G["END_OF_EXCL_SIZE"] = END_OF_EXCL:getSize()
end

function testConstructorData()
  local tested = VirtualKeypadEventMsg({"INTERNAL", "BANK 1", "SOFTKEY 0"})
  log:warn("Result: %s", tested:toString())
end

runTests{useANSI = false}
