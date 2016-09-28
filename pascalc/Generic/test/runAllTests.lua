
local requireDirs = {}

function is_dir(path)
    local f = io.open(path)
    if f == nil then return true end
    return not f:read(0) and f:seek("end") ~= 0
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
    elseif absPath ~= arg[0] and string.sub(absPath, -string.len("Test.lua")) == "Test.lua" then
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

local current_dir=io.popen("cd"):read('*l')
print(string.format("Executing all tests in folder %s", current_dir))
runAllScriptsInFolder(current_dir)
