require("LuaObject")
require("Logger")
require("lutils")

local log = Logger("YamahaCS1xPatch")
local PATCH_NAME_SIZE = 8
local PATCH_NAME_START = 9

local calculateChecksum = function(sysex, csStart, csEnd)
  local sum = 0
  if csEnd < 0 then
    csEnd = sysex:getSize() + csEnd
  end

  for i = csStart, csEnd do
    sum = sum + sysex:getByte(i)
  end

  return bit.band( - sum, 0x7f)
end

local detuneParams = {
  [123] = true,
  [175] = true,
  [227] = true,
  [279] = true
}

local msblsbParams = {
  [37]  = 1,
  [39]  = 1,
  [41]  = 1,
  [43]  = 1,
  [50]  = 1,
  [66]  = 1,
  [68]  = 1,
  [70]  = 1,
  [72]  = 1,
  [74]  = 1,
  [76]  = 1,
  [78]  = 1,
  [80]  = 1,
  [82]  = 1,
  [109] = 1,
  [118] = 1,
  [161] = 1,
  [170] = 1,
  [213] = 1,
  [222] = 1,
  [265] = 1,
  [274] = 1
}

local PARAM_OFFSETS = {
  [45] = 32, [46] = 32, [47] = 32, [48] = 32, [49] = 32,

  [80] = 64, [83] = 24, [84] = 64,
  [122] = 64, [127] = 64, [135] = 64, [136] = 64, [137] = 64, [138] = 64, [139] = 64, [141] = 64, [142] = 64, [143] = 64, [144] = 64, [147] = 64, [148] = 64, [150] = 64, [151] = 64, [152] = 64, [153] = 64, [154] = 64, [155] = 64, [156] = 64, [157] = 64, [158] = 64,
  [174] = 64, [179] = 64, [187] = 64, [188] = 64, [189] = 64, [190] = 64, [191] = 64, [193] = 64, [194] = 64, [195] = 64, [196] = 64, [199] = 64, [200] = 64, [202] = 64, [203] = 64, [204] = 64, [205] = 64, [206] = 64, [207] = 64, [208] = 64, [209] = 64, [210] = 64,
  [226] = 64, [231] = 64, [239] = 64, [240] = 64, [241] = 64, [242] = 64, [243] = 64, [245] = 64, [246] = 64, [247] = 64, [248] = 64, [251] = 64, [252] = 64, [254] = 64, [255] = 64, [256] = 64, [257] = 64, [258] = 64, [259] = 64, [260] = 64, [261] = 64, [262] = 64,
  [278] = 64, [283] = 64, [291] = 64, [292] = 64, [293] = 64, [294] = 64, [295] = 64, [297] = 64, [298] = 64, [299] = 64, [300] = 64, [303] = 64, [304] = 64, [306] = 64, [307] = 64, [308] = 64, [309] = 64, [310] = 64, [311] = 64, [312] = 64, [313] = 64, [314] = 64,
}

local HEADER_ARRAY = {
  MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x2E, 0x60, 0x00, 0x00 }),
  MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x15, 0x60, 0x00, 0x30 }),
  MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x09, 0x60, 0x00, 0x50 }),
  MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x29, 0x60, 0x01, 0x00 }),
  MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x29, 0x60, 0x02, 0x00 }),
  MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x29, 0x60, 0x03, 0x00}),
  MemoryBlock({ 0xF0, 0x43, 0x00, 0x4B, 0x00, 0x29, 0x60, 0x04, 0x00 })
}

YamahaCS1xPatch = {}
YamahaCS1xPatch.__index = YamahaCS1xPatch

setmetatable(YamahaCS1xPatch, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function YamahaCS1xPatch:_init(patchData)
  LuaObject._init(self)

  if patchData == nil then
    self.data = MemoryBlock(SinglePerformanceSize, true)
  else
    if patchData:getSize() == SinglePerformanceSize + 2 then
      local temp = MemoryBlock(SinglePerformanceSize, true)
      local temp2 = MemoryBlock(SinglePerformanceSize - 89, true)
      temp:copyFrom(patchData, 0, 89)
      patchData:copyTo(temp2, 89 + 2, temp2:getSize())
      temp:copyFrom(temp2, 89, temp2:getSize())
      patchData = temp
    end
    assert(patchData:getSize() == SinglePerformanceSize, string.format("midiSize %d is invalid and cannot be assigned to controllers", patchData:getSize()))
    self.data = MemoryBlock(SinglePerformanceSize, true)
    self.data:copyFrom(patchData, 0, SinglePerformanceSize)
  end
end

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
function YamahaCS1xPatch:getPatchName()
  local perfName = ""
  for i = 1, PATCH_NAME_SIZE do
    perfName = string.format("%s%c", perfName, self.data:getByte(PATCH_NAME_START + i - 1))
  end
  return perfName
end

-- This method set the values of the hidden char modulators
-- to match the given name
function YamahaCS1xPatch:setPatchName(patchName)
  for i = 1, PATCH_NAME_SIZE do
    local char = patchName:byte(i, i + 1)
    if char == nil then
      char = 32
    end
    self.data:setByte(PATCH_NAME_START + i - 1, char)
  end
end

function YamahaCS1xPatch:setValue(index, value)
  if PARAM_OFFSETS[index] ~= nil then
    value = value + PARAM_OFFSETS[index]
  end
  if msblsbParams[index] == 1 then
    local b = mutils.d2b(value, true)
    self.data:setByte(index, b:getByte(0))
    self.data:setByte(index + 1, b:getByte(1))
  elseif detuneParams[index] then
    local b = mutils.du2n(value, true)
    self.data:setByte(index, b:getByte(1))
    self.data:setByte(index + 1, b:getByte(0))
  else
    self.data:setByte(index, value)
  end
end

function YamahaCS1xPatch:getValue(index)
  local value = 0
  if msblsbParams[index] == 1 then
    value = mutils.b2d(self.data:getByte(index), self.data:getByte(index + 1))
    log:info("i %d, b1 %.2X, b2 %.2X = %d ", index, self.data:getByte(index), self.data:getByte(index + 1), value)
  elseif detuneParams[index] then
    value = mutils.n2du(self.data:getByte(index + 1), self.data:getByte(index))
  else
    value = self.data:getByte(index)
    log:info("i %d, b1 %.2X, = %d ", index, self.data:getByte(index), value)
  end
  if PARAM_OFFSETS[index] ~= nil then
    value = value - PARAM_OFFSETS[index]
  end
  return value
end

function YamahaCS1xPatch:toSyxMsg()
  local msgArray = {}
  local offs = 0
  for k, header in pairs(HEADER_ARRAY) do
    local blockSize = header:getSize() + header:getByte(5) + 2
    local memBlock = MemoryBlock(blockSize)
    memBlock:copyFrom(header, 0, header:getSize())
    memBlock:copyFrom(self.data, offs + header:getSize(), header:getByte(5))
    memBlock:setByte(memBlock:getSize() - 2, calculateChecksum(memBlock, header:getSize(), header:getByte(5)))
    memBlock:setByte(memBlock:getSize() - 1, 0xF7)
    table.insert(self.msgArray, memBlock)
    offs = offs + blockSize
  end
  return msgArray
end
