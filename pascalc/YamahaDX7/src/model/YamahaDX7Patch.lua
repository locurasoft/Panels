require("LuaObject")
require("Logger")
require("lutils")

local log = Logger("YamahaDX7Patch")

local symbols = {"|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|","|"," ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local patchNameStart = 151
local patchNameSize = 10
local Voice_offsets={[26]=7, [47]=7, [68]=7, [89]=7, [110]=7, [131]=7}

YamahaDX7Patch = {}
YamahaDX7Patch.__index = YamahaDX7Patch

setmetatable(YamahaDX7Patch, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function YamahaDX7Patch:_init(patchData)
  LuaObject._init(self)

  self.patchOffset = 5
  if patchData == nil then
    self.data = MemoryBlock(Voice_singleSize, true)
    self.data:setByte(0, 0xF0)
    self.data:setByte(1, 0x43)
    self.data:setByte(2, 0x00)
    self.data:setByte(3, 0x00)
    self.data:setByte(4, 0x01)
    self.data:setByte(5, 0x1B)
    self.data:setByte(Voice_singleSize - 1, 0xF7)
    self:setPatchName("INIT")
  else
    assert(patchData:getSize() == PATCH_BUFFER_SIZE, string.format("midiSize %d is invalid and cannot be assigned to controllers", patchData:getSize()))
    self.data = patchData
  end

end

function YamahaDX7Patch:getValueOffset(relativeOffset)
  return self.patchOffset + relativeOffset
end

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
function YamahaDX7Patch:getPatchName()
  local name = ""

  for i = patchNameStart,(patchNameStart + patchNameSize - 1) do -- gets the voice name
    local midiParam = self.data:getByte(i)
    if symbols[midiParam + 1] == nil then
      log:warn("Weird char: %d, %d", midiParam, i)
    else
      name = string.format("%s%s", name, symbols[midiParam + 1]) -- Lua tables are base 1 indexed
    end
  end
  return name
end

-- This method set the values of the hidden char modulators
-- to match the given name
function YamahaDX7Patch:setPatchName(patchName)
  for i = 1, patchNameSize do
    local char = patchName:byte(i, i + 1)
    if char == nil then
      char = 32
    end
    self.data:setByte(patchNameStart + i - 1, char)
  end
end

function YamahaDX7Patch:setValue(index, value)
  if Voice_offsets[index] ~= nil then
    value = value + Voice_offsets[index]
  end
  self.data:setByte(index, value)
end

function YamahaDX7Patch:getValue(index)
  local midiParam = self.data:getByte(index)
  if Voice_offsets[index] ~= nil then
    midiParam = midiParam - Voice_offsets[index]
  end
  return midiParam
end

function YamahaDX7Patch:toSyxMsg()
  local msg = Esq1SyxMsg(1, SINGLE_DATA_SIZE)
  local tmp = MemoryBlock(SINGLE_DATA_SIZE, true)
  tmp:copyFrom(self.data, self:getValueOffset(0), SINGLE_DATA_SIZE)
  msg:setPayload(tmp)
  return msg
end
