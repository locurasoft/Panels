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

local msblsbParams = {
  [37]   = 1,
  [39]   = 1,
  [41]   = 1,
  [43]   = 1,
  [50]   = 1,
  [66]   = 1,
  [68]   = 1,
  [70]   = 1,
  [72]   = 1,
  [74]   = 1,
  [76]   = 1,
  [78]   = 1,
  [80]   = 1,
  [82]   = 1,
  [109]  = 1,
  [161]  = 1,
  [213]  = 1,
  [265]  = 1
}

local nibbleParams = {
  [114]  = 1,
  [166]  = 1,
  [219]  = 1,
  [270]  = 1
}

local PARAM_OFFSETS = {
  [45] = 32,  [46] = 32,  [47] = 32,  [48] = 32,  [49] = 32,  [80] = 64,  [83] = 24,  [84] = 64,
  [95] = 24,  [100] = 64,  [110] = 63,  [111] = 63,  [112] = 63,  [114] = 64,  [115] = 63,  [116] = 63,
  [117] = 64,  [120] = 64,  [121] = 63,  [123] = 31,  [124] = 63,  [125] = 15,  [126] = 63,  [127] = 63,
  [128] = 64,  [129] = 63,  [130] = 64,  [131] = 63,  [138] = 24,  [143] = 64,  [153] = 63,  [154] = 63,
  [155] = 63,  [157] = 64,  [158] = 63,  [159] = 63,  [160] = 64,  [163] = 64,  [164] = 63,  [166] = 31,
  [167] = 63,  [168] = 15,  [169] = 63,  [170] = 63,  [171] = 64,  [172] = 63,  [173] = 64,  [174] = 63,
  [181] = 24,  [186] = 64,  [196] = 63,  [197] = 63,  [198] = 63,  [200] = 64,  [201] = 63,  [202] = 63,
  [203] = 64,  [206] = 64,  [207] = 63,  [209] = 31,  [210] = 63,  [211] = 15,  [212] = 63,  [213] = 63,
  [214] = 64,  [215] = 63,  [216] = 64,  [217] = 63,  [224] = 24,  [229] = 64,  [239] = 63,  [240] = 63,
  [241] = 63,  [243] = 64,  [244] = 63,  [245] = 63,  [246] = 64,  [249] = 64,  [250] = 63,  [252] = 31,
  [253] = 63,  [254] = 15,  [255] = 63,  [256] = 63,  [257] = 64,  [258] = 63,  [259] = 64,  [260] = 63,
}

local PARAM_INDEXES = {
  [18] = "1-9", [50] = "1-29", [52] = "1-2B", [53] = "1-2C", [54] = "1-2D",
  [65] = "2-0", [67] = "2-2", [69] = "2-4", [71] = "2-6", [73] = "2-8", [75] = "2-A", [77] = "2-C", [79] = "2-E", [81] = "2-10", [84] = "2-20", [85] = "2-21", [86] = "2-22",
  [103] = "3-7", [104] = "3-8",
  [115] = "4-0", [117] = "4-2", [118] = "4-3", [119] = "4-4", [120] = "4-5", [122] = "4-7", [123] = "4-8", [124] = "4-9", [125] = "4-A", [126] = "4-B", [127] = "4-C", [128] = "4-D", [129] = "4-E", [130] = "4-F", [131] = "4-10", [132] = "4-11", [133] = "4-12", [134] = "4-13", [135] = "4-14", [136] = "4-15", [137] = "4-16", [138] = "4-17", [139] = "4-18", [140] = "4-19", [141] = "4-1A", [142] = "4-1B", [143] = "4-1C", [144] = "4-1D", [145] = "4-1E", [146] = "4-1F", [147] = "4-20", [148] = "4-21", [149] = "4-22", [150] = "4-23", [151] = "4-24", [152] = "4-25", [153] = "4-26", [154] = "4-27", [155] = "4-28",
  [166] = "5-0", [168] = "5-2", [169] = "5-3", [170] = "5-4", [171] = "5-5", [173] = "5-7", [174] = "5-8", [175] = "5-9", [176] = "5-A", [177] = "5-B", [178] = "5-C", [179] = "5-D", [180] = "5-E", [181] = "5-F", [182] = "5-10", [183] = "5-11", [184] = "5-12", [185] = "5-13", [186] = "5-14", [187] = "5-15", [188] = "5-16", [189] = "5-17", [190] = "5-18", [191] = "5-19", [192] = "5-1A", [193] = "5-1B", [194] = "5-1C", [195] = "5-1D", [196] = "5-1E", [197] = "5-1F", [198] = "5-20", [199] = "5-21", [200] = "5-22", [201] = "5-23", [202] = "5-24", [203] = "5-25", [204] = "5-26", [205] = "5-27", [206] = "5-28",
  [217] = "6-0", [219] = "6-2", [220] = "6-3", [221] = "6-4", [222] = "6-5", [224] = "6-7", [225] = "6-8", [226] = "6-9", [227] = "6-A", [228] = "6-B", [229] = "6-C", [230] = "6-D", [231] = "6-E", [232] = "6-F", [233] = "6-10", [234] = "6-11", [235] = "6-12", [236] = "6-13", [237] = "6-14", [238] = "6-15", [239] = "6-16", [240] = "6-17", [241] = "6-18", [242] = "6-19", [243] = "6-1A", [244] = "6-1B", [245] = "6-1C", [246] = "6-1D", [247] = "6-1E", [248] = "6-1F", [249] = "6-20", [250] = "6-21", [251] = "6-22", [252] = "6-23", [253] = "6-24", [254] = "6-25", [255] = "6-26", [256] = "6-27", [257] = "6-28",
  [268] = "7-0", [270] = "7-2", [271] = "7-3", [272] = "7-4", [273] = "7-5", [275] = "7-7", [276] = "7-8", [277] = "7-9", [278] = "7-A", [279] = "7-B", [280] = "7-C", [281] = "7-D", [282] = "7-E", [283] = "7-F", [284] = "7-10", [285] = "7-11", [286] = "7-12", [287] = "7-13", [288] = "7-14", [289] = "7-15", [290] = "7-16", [291] = "7-17", [292] = "7-18", [293] = "7-19", [294] = "7-1A", [295] = "7-1B", [296] = "7-1C", [297] = "7-1D", [298] = "7-1E", [299] = "7-1F", [300] = "7-20", [301] = "7-21", [302] = "7-22", [303] = "7-23", [304] = "7-24", [305] = "7-25", [306] = "7-26", [307] = "7-27", [308] = "7-28"  
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
    assert(patchData:getSize() == SinglePerformanceSize, string.format("midiSize %d is invalid and cannot be assigned to controllers", patchData:getSize()))
    self.data = MemoryBlock(SinglePerformanceSize, true)
    self.data:copyFrom(patchData, 0, SinglePerformanceSize)
  end
end

-- This method fetches the patch name from the hidden
-- char modulators and returns it as a string
function YamahaCS1xPatch:getPatchName()
  local perfName = ""
  for i = PATCH_NAME_START, PATCH_NAME_SIZE do
    perfName = string.format("%s%c", perfName, self.data:getByte(i))
  end
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
  elseif nibbleParams[index] == 1 then
    local b = mutils.d2n2(value)
    self.data:setByte(index, b:getByte(0))
    self.data:setByte(index + 1, b:getByte(1))
  else
    self.data:setByte(index, value)
  end
end

function YamahaCS1xPatch:getValue(index)
  local value = 0
  if msblsbParams[index] == 1 then
    value = mutils.b2d(self.data:getByte(index), self.data:getByte(index + 1))
  elseif nibbleParams[index] == 1 then
    value = mutils.n2d2(self.data:getByte(index), self.data:getByte(index + 1))
  else
    value = self.data:getByte(index)
  end
  if PARAM_OFFSETS[index] ~= nil then
    value = value - PARAM_OFFSETS[index]
  end
  return value
end

function YamahaCS1xPatch:isValidParamIndex(index)
  return PARAM_INDEXES[index] ~= nil
end

function YamahaCS1xPatch:getCustName(index)
  return PARAM_INDEXES[index]
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
