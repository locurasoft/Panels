require("ctrlrTestUtils")
require("Dispatcher")
require 'lunity'
require 'lemock'
module( 'DispatcherTest', lunity )

function setup()
  -- code here will be run before each test
  --console("setup")
  underTest = Dispatcher()
  mc = lemock.controller()
  listener = mc:mock()
  listener2 = mc:mock()
end

function teardown()
  -- code here will be run after each test
  --console("teardown")
end

function testDispatcher_AddListener()
  listener:notify(underTest);mc:times(2)
  listener2:notify(underTest);mc:times(1)
  mc:replay()
  underTest:addListener(listener, "notify")
  underTest:notifyListeners()
  underTest:addListener(listener2, "notify")
  underTest:notifyListeners()
  mc:verify()
end

function testDispatcher_RemoveListener()
  listener:notify(underTest);mc:times(1)
  mc:replay()
  local index = underTest:addListener(listener, "notify")
  assertEqual(1, table.getn(underTest.listeners))
  underTest:notifyListeners()
  
  underTest:removeListener(index)
  assertEqual(0, table.getn(underTest.listeners))
  underTest:notifyListeners()
  mc:verify()
end

runTests{useANSI = false}