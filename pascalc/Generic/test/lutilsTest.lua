require("ctrlrTestUtils")
require("lutils")
require 'lunity'
require 'lemock'
module( 'lutilsTest', lunity )

function testFlipTable()
  local t1 = { "a", "b", "c", "d", "e", "f" }
  local result = lutils.flipTable(t1)

  assertEqual(t1[1], "a")
  assertEqual(t1[2], "b")
  assertEqual(t1[3], "c")
  assertEqual(t1[4], "d")
  assertEqual(t1[5], "e")
  assertEqual(t1[6], "f")
  
  assertEqual(t1["a"], nil)
  assertEqual(t1["b"], nil)
  assertEqual(t1["c"], nil)
  assertEqual(t1["d"], nil)
  assertEqual(t1["e"], nil)
  assertEqual(t1["f"], nil)

  assertEqual(result[1], nil)
  assertEqual(result[2], nil)
  assertEqual(result[3], nil)
  assertEqual(result[4], nil)
  assertEqual(result[5], nil)
  assertEqual(result[6], nil)
  
  assertEqual(result["a"], 1)
  assertEqual(result["b"], 2)
  assertEqual(result["c"], 3)
  assertEqual(result["d"], 4)
  assertEqual(result["e"], 5)
  assertEqual(result["f"], 6)
end

runTests{useANSI = false}
