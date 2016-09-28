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
  if bytes:getByte(3) == 0x03 then
    return __PlistMsg:new{ data = bytes }
  else
    console("MIDI is not a plist message")
    console(bytes:toHexString(1))
    return nil
  end
end

function PlistMsg:getNumPrograms()
  return self.data:getByte(numProgramsOffs)
end

function PlistMsg:getProgramNames()
  local offset = programNameOffs
  local numPrograms = self:getNumPrograms()
  local buf = MemoryBlock(PROGRAM_NAME_LENG, true)
  local programNames = {}

  while offset + PROGRAM_NAME_LENG < self.data:getSize() do
    self.data:copyTo(buf, offset, PROGRAM_NAME_LENG)
    offset = offset + PROGRAM_NAME_LENG
    local name = midiSrvc:fromAkaiString(buf)
    --console(string.format("Program Name: %s", name))
    table.insert(programNames, name)
  end
  return programNames

end
