require("message/Esq1SyxMsg")
require("Logger")

local log = Logger("VirtualKeypadEventMsg")


local BUTTON_CODES = {
  ["ENV 1"] = { 0x1, 0x34 },
  ["ENV 2"] = { 0x2, 0x35 },
  ["ENV 3"] = { 0x3, 0x36 },
  ["ENV 4"] = { 0x4, 0x37 },
  ["LFO 1"] = { 0x5, 0x38 },
  ["LFO 2"] = { 0x6, 0x39 },
  ["LFO 3"] = { 0x7, 0x3A },
  ["OSC 1"] = { 0x8, 0x3B },
  ["OSC 2"] = { 0x9, 0x3C },
  ["OSC 3"] = { 0xA, 0x3D },
  ["DCA 1"] = { 0xB, 0x3E },
  ["DCA 2"] = { 0xC, 0x3F },
  ["DCA 3"] = { 0xD, 0x40 },
  ["DCA 4"] = { 0xE, 0x41 },
  ["FILTER"] = { 0xF, 0x42 },
  ["MODES"] = { 0x10, 0x43 },
  ["SPLIT/LAYER"] = { 0x11, 0x44 },
  ["MASTER"] = { 0x12, 0x45 },
  ["MIDI"] = { 0x13, 0x46 },
  ["CONTROL"] = { 0x14, 0x47 },
  ["STORAGE"] = { 0x15, 0x48 },
  ["WRITE"] = { 0x16, 0x49 },
  ["COMPARE"] = { 0x17, 0x4A },
  ["INC"] = { 0x18, 0x4B },
  ["DEC"] = { 0x19, 0x4C },
  ["CREATE"] = { 0x1A, 0x4D },
  ["EDIT"] = { 0x1B, 0x4E },
  ["TRACKS-SELECT"] = { 0x1C, 0x4F },
  ["LOCATE"] = { 0x1D, 0x50 },
  ["TRACKS-MIX/MIDI"] = { 0x1E, 0x51 },
  ["RECORD"] = { 0x1F, 0x52 },
  ["STOP"] = { 0x20, 0x53 },
  ["PLAY"] = { 0x21, 0x54 },
  ["BANK 1"] = { 0x22, 0x55 },
  ["BANK 2"] = { 0x23, 0x56 },
  ["BANK 3"] = { 0x24, 0x57 },
  ["BANK 4"] = { 0x25, 0x58 },
  ["INTERNAL"] = { 0x26, 0x59 },
  ["CART A"] = { 0x27, 0x5A },
  ["CART B"] = { 0x28, 0x5B },
  ["SEQuence"] = { 0x29, 0x5C },
  ["SOFTKEY 0"] = { 0x2A, 0x5D },
  ["SOFTKEY 1"] = { 0x2B, 0x5E },
  ["SOFTKEY 2"] = { 0x2C, 0x5F },
  ["SOFTKEY 3"] = { 0x2D, 0x60 },
  ["SOFTKEY 4"] = { 0x2E, 0x61 },
  ["SOFTKEY 5"] = { 0x2F, 0x62 },
  ["SOFTKEY 6"] = { 0x30, 0x63 },
  ["SOFTKEY 7"] = { 0x31, 0x64 },
  ["SOFTKEY 8"] = { 0x32, 0x65 },
  ["SOFTKEY 9"] = { 0x33, 0x66 },
}

VirtualKeypadEventMsg = {}
VirtualKeypadEventMsg.__index = VirtualKeypadEventMsg

setmetatable(VirtualKeypadEventMsg, {
  __index = Esq1SyxMsg, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function VirtualKeypadEventMsg:_init(buttonNames)
  Esq1SyxMsg._init(self, 0x9, #buttonNames * 2)
  for index = 1, #buttonNames do
    local buttonName = buttonNames[index]
    assert(BUTTON_CODES[buttonName] ~= nil, "Invalid button name")
    local tmp = MemoryBlock(BUTTON_CODES[buttonName])
    self.data:copyFrom(tmp, HEADER_SIZE + 1 + (index - 1) * 2, tmp:getSize())
  end
end
