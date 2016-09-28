require("ctest")
require("ctrlr")
require("mutils")
require 'test/lunity'
module( 'TEST_RUNTIME', lunity )


function setup()
  -- code here will be run before each test
  console("setup")

end

function teardown()
  -- code here will be run after each test
  console("teardown")
end

function f2NString(value)
  return mutils.float2nibbles(value):toHexString(1)
end

function nString2f(value)
  return mutils.nibbles2float(MemoryBlock(value), 0)
end

function testFloat2nibbles()
  local a = MemoryBlock("00 00 01 00")
  assertEqual(f2NString(1), "00 00 01 00")
  assertEqual(f2NString(2), "00 00 02 00")
  
  assertEqual(nString2f("00 00 01 00"), 1)
  assertEqual(nString2f("00 00 02 00"), 2)
end

function testNibbleConversion()
  local result = mutils.toNibbles(1)
  assertEqual(result:getByte(0), 1)
  assertEqual(result:getByte(1), 0)
  result = mutils.toNibbles(2)
  assertEqual(result:getByte(0), 2)
  assertEqual(result:getByte(1), 0)
    
  assertEqual(mutils.fromNibbles(1, 0), 1)
  assertEqual(mutils.fromNibbles(2, 0), 2)
  
end

runTests{useANSI = false}