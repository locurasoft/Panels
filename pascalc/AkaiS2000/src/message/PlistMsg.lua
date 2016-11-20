require("SyxMsg")

PlistMsg = {}
PlistMsg.__index = PlistMsg

setmetatable(PlistMsg, {
  __index = SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

local numProgramsOffs = 5
local programNameOffs = 7

function PlistMsg:_init(bytes)
  SyxMsg._init(self)
  assert(bytes:getByte(3) == 0x03, "Invalid plist message")
  self.data = bytes
  local offset = programNameOffs
  local numPrograms = self:getNumPrograms()
  local buf = MemoryBlock(PROGRAM_NAME_LENG, true)
  self.programNames = {}

  while offset + PROGRAM_NAME_LENG < self.data:getSize() do
    self.data:copyTo(buf, offset, PROGRAM_NAME_LENG)
    offset = offset + PROGRAM_NAME_LENG
    local name = midiService:fromAkaiStringBytes(buf)
    table.insert(self.programNames, name)
  end
  self[LUA_CONTRUCTOR_NAME] = "Plist"
end

function PlistMsg:getNumPrograms()
  return self.data:getByte(numProgramsOffs)
end

function PlistMsg:getProgramNames()
  return self.programNames
end

function PlistMsg:getProgramIndex(name)
  for k, v in ipairs(self.programNames) do
    if v == name then
      return k
    end
  end
  return -1
end
