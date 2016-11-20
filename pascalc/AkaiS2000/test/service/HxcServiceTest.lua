require("akaiS2kTestUtils")
require("service/HxcService")
require("model/Settings")
require 'lunity'
require 'lemock'
module( 'HxcServiceTest', lunity )

function setup()
  local settings = Settings()
  settings:setWorkFolder(File("ctrlrwork"))
  settings:setS2kDiePath(File("c:\\ctrlr\\s2kdie\\s2kdie.php"))
  settings:setHxcPath(File("c:\\temp\\hxc.exe"))

  regGlobal("EOL", "\r\n")
  underTest = HxcService()
  underTest:setSettings(settings)
  scriptPath = "my_script.bat"
  packageConfigBak = package.config
end

function teardown()
  os.remove(scriptPath)
  package.config = packageConfigBak
end

function testWindowsLauncher()
  package.config = "\\"
  local imgPath = "c:\\temp\\my_image.img"
  
  local windowsLauncher = underTest:getHxcLauncher()
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
  package.config = "/"
  local imgPath = "/User/test/my_image.img"
  
  local macOsXLauncher = underTest:getHxcLauncher()
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
  package.config = "\\"
  local imgPath = "c:\\temp\\my_image.img"
  
  local windowsAborter = underTest:getHxcAborter()
  windowsAborter(scriptPath)
  local result = io.open(scriptPath,"r")
  assertNotNil(result)
  local content = result:read("*all")
  io.close(result)
  
  assertNotNil(content:find("tokens=2"))
end

function testMacOsXAborter()
  package.config = "/"
  local imgPath = "/User/test/my_image.img"
  
  local macOsXAborter = underTest:getHxcAborter()
  macOsXAborter(scriptPath)
  local result = io.open(scriptPath,"r")
  assertNotNil(result)
  local content = result:read("*all")
  io.close(result)
  
  assertNotNil(content:find("> HXC_PIPE"))
end

runTests{useANSI = false}
