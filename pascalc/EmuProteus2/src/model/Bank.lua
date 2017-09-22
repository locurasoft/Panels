require("AbstractBank")
require("message/Proteus2SyxMsg")
require("SyxMsg")
require("model/Patch")
require("Logger")
require("lutils")

local log = Logger("Bank")

Bank = {}
Bank.__index = Bank

setmetatable(Bank, {
  __index = AbstractBank, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Bank:_init(bankData)
  AbstractBank._init(self)

  self.patches = {}
  if bankData == nil then
    self.data = MemoryBlock(BANK_BUFFER_SIZE, true)

    for i = 0, NUM_PATCHES - 1 do
      local p = Patch(self.data, i * SINGLE_DATA_SIZE)
      p:setPatchName("INIT")
      table.insert(self.patches, p)
    end
  else
    assert(bankData:getSize() == BANK_BUFFER_SIZE, string.format("Data does not contain a Emu Proteus/2 bank"))
    self.data = MemoryBlock(BANK_BUFFER_SIZE, false)
    self.data:copyFrom(bankData, 0, BANK_BUFFER_SIZE)

    for i = 0, NUM_PATCHES - 1 do
      table.insert(self.patches, Patch(self.data, i * SINGLE_DATA_SIZE))
    end
  end
end

function Bank:getSelectedPatch()
  return self.patches[self.selectedPatchIndex + 1]
end

function Bank:toStandaloneData()
  return self.data
end

function Bank:toSyxMessage()
  local m = SyxMsg()
  m.data = self.data
  return m
end
