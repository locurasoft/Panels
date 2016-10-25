
local requireDirs = {}

function is_dir(path)
    local f = io.open(path)
    if f == nil then return true end
    return not f:read(0) and f:seek("end") ~= 0
end

function isUnitTest(path)
  return string.sub(path, -string.len("Test.lua")) == "Test.lua"
end

function isIntegrationTest(path)
--  return string.sub(path, -string.len("IT.lua")) == "IT.lua"
-- Disable integration tests
  return false
end

function runAllScriptsInFolder(dirName)
  local dir = io.popen(string.format("dir %s /b", dirName))
  local lines = dir:lines()
  for mod in lines do
    local absPath = string.format("%s%s%s", dirName, package.config:sub(1,1), mod)
    if is_dir(absPath) then
      table.insert(requireDirs, mod)
      runAllScriptsInFolder(absPath)
      table.remove(requireDirs)
    elseif absPath ~= arg[0] and (isUnitTest(absPath) or isIntegrationTest(absPath)) then
      local modPath = ""
      for k, v in pairs(requireDirs) do
        modPath = string.format("%s/%s", modPath, v)
      end
      modPath = string.format("%s/%s", modPath, mod)
      modPath = string.gsub(modPath, ".lua", "")
      require(modPath)
    end
  end
end

local currentDir = io.popen("cd"):read('*l')
print(string.format("Executing all tests in folder %s", currentDir))
runAllScriptsInFolder(currentDir)
