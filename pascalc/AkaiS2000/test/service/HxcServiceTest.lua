require("akaiS2kTestUtils")
require("service.HxcService")
require 'lunity'
require 'lemock'
module( 'HxcServiceTest', lunity )

function setup()
  -- code here will be run before each test
  --console("setup")
  hxcPath = "c:\\temp\\hxc.exe"
  regGlobal("EOL", "\r\n")
  underTest = HxcService(hxcPath)
  scriptPath = "my_script.bat"
end

function teardown()
  os.remove(scriptPath)
end

function testWindowsLauncher()
  local imgPath = "c:\\temp\\my_image.img"
  
  local windowsLauncher = underTest:getWindowsLauncher()
  windowsLauncher({
    ["scriptPath"] = scriptPath,
    ["imgPath"] = imgPath
  })
  local result = io.open(scriptPath,"r")
  assertNotNil(result)
  local content = result:read("*all")
  io.close(result)
  
  assertNotNil(content:find(imgPath))
  assertNotNil(content:find("-uselayout:AKAIS3000_HD"))
  assertNotNil(content:find("-finput:"))
  assertNotNil(content:find("-usb:"))
end

function testMacOsXLauncher()
  local imgPath = "/User/test/my_image.img"
  
  local macOsXLauncher = underTest:getMacOsXLauncher()
  macOsXLauncher({
    ["scriptPath"] = scriptPath,
    ["imgPath"] = imgPath
  })
  local result = io.open(scriptPath,"r")
  assertNotNil(result)
  local content = result:read("*all")
  io.close(result)
  
  assertNotNil(content:find(imgPath))
  assertNotNil(content:find("-uselayout:AKAIS3000_HD"))
  assertNotNil(content:find("HXC_PIPE"))
  assertNotNil(content:find("-usb:"))
end

function testWindowsAborter()
  local imgPath = "c:\\temp\\my_image.img"
  
  local windowsAborter = underTest:getWindowsAborter()
  windowsAborter(scriptPath)
  local result = io.open(scriptPath,"r")
  assertNotNil(result)
  local content = result:read("*all")
  io.close(result)
  
  assertNotNil(content:find("tokens=2"))
end

function testMacOsXAborter()
  local imgPath = "/User/test/my_image.img"
  
  local macOsXAborter = underTest:getMacOsXAborter()
  macOsXAborter(scriptPath)
  local result = io.open(scriptPath,"r")
  assertNotNil(result)
  local content = result:read("*all")
  io.close(result)
  
  assertNotNil(content:find("> HXC_PIPE"))
end

runTests{useANSI = false}
