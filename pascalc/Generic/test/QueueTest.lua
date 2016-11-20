require("ctrlrTestUtils")
require("Queue")
require 'lunity'
require 'lemock'
module( 'QueueTest', lunity )

function testQueue()
  local tested = Queue()
  assertNil(tested:popFirst())
  assertNil(tested:popLast())
  
  tested:pushLast(1)
  assertEqual(1, tested:popFirst())
  assertNil(tested:popFirst())

  tested:pushLast(1)
  tested:pushLast(2)
  assertEqual(1, tested:popFirst())
  assertEqual(2, tested:popFirst())

  tested:pushLast(1)
  tested:pushLast(2)
  tested:pushLast(3)
  assertEqual(3, tested:popLast())
  assertEqual(1, tested:popFirst())
end

runTests{useANSI = false}
