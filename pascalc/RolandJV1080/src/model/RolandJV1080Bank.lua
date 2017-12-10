require("AbstractBank")
require("SyxMsg")
require("model/RolandJV1080Patch")
require("Logger")
require("lutils")

local log = Logger("RolandJV1080Bank")

RolandJV1080Bank = {}
RolandJV1080Bank.__index = RolandJV1080Bank

setmetatable(RolandJV1080Bank, {
  __index = AbstractBank, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function RolandJV1080Bank:_init(bankData)
  AbstractBank._init(self)

  self.patches = {}
--  if bankData == nil then
--    self.data = MemoryBlock(BANK_BUFFER_SIZE, true)
--
--    for i = 0, NUM_PATCHES - 1 do
--      local p = EnsoniqEsq1Patch(self.data, COMPLETE_HEADER_SIZE + i * SINGLE_DATA_SIZE)
--      p:setPatchName("INIT")
--      table.insert(self.patches, p)
--    end
--  else
--    assert(bankData:getSize() == BANK_BUFFER_SIZE, string.format("Data does not contain a Ensoniq ESQ-1 bank"))
--    self.data = MemoryBlock(BANK_BUFFER_SIZE, false)
--    self.data:copyFrom(bankData, 0, BANK_BUFFER_SIZE)
--
--    for i = 0, NUM_PATCHES - 1 do
--      table.insert(self.patches, EnsoniqEsq1Patch(self.data, COMPLETE_HEADER_SIZE + i * SINGLE_DATA_SIZE))
--    end
--  end
end
