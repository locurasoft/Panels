require("ctrlrTestUtils")
require 'test/lunity'
module( 'TEST_RUNTIME', lunity )


function setup()
  -- code here will be run before each test
  --console("setup")

end

function teardown()
  -- code here will be run after each test
  --console("teardown")
end

function test1_foo()
  -- Tests to run must either start with or end with 'test'
  assertTrue( 42 == 40 + 2 )
  assertFalse( 42 == 40 )
  assertEqual( 42, 40 + 2 )
  assertNotEqual( 42, 40, "These better not be the same!" )
  assertTableEquals( { a=42 }, { ["a"]=6*7 } )
  -- See library for more assertions available
end

runTests{useANSI = false}