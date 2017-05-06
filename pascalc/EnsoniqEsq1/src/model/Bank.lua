require("AbstractBank")
--require("message/Esq1SyxMsg")
require("SyxMsg")
require("model/Patch")
require("Logger")
require("lutils")

local BANK_BUFFER_SIZE = 8166

local Voice_singleSize = 210
local SINGLE_DATA_SIZE = 204
local NUM_PATCHES = 40
local Voice_Header = MemoryBlock({ 0xF0, 0x0F, 0x02, 0x00, 0x01 })
local HEADER_SIZE = Voice_Header:getSize()
local Voice_Footer = MemoryBlock({ 0xF7 })
local Voice_FooterSize = Voice_Footer:getSize()

Voice_PartialMuteUpdating = false


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
      local p = Patch(self.data, HEADER_SIZE + i * SINGLE_DATA_SIZE)
      p:setPatchName("INIT")
      table.insert(self.patches, p)
    end
  else
    assert(bankData:getSize() == BANK_BUFFER_SIZE, string.format("Data does not contain a Ensoniq ESQ-1 bank"))
    self.data = MemoryBlock(BANK_BUFFER_SIZE, false)
    self.data:copyFrom(bankData, 0, BANK_BUFFER_SIZE)

    for i = 0, NUM_PATCHES - 1 do
      table.insert(self.patches, Patch(self.data, HEADER_SIZE + i * SINGLE_DATA_SIZE))
    end
  end
end

function Bank:getSelectedPatch()
  return self.patches[self.selectedPatchIndex + 1]
end

function Bank:toStandaloneData()
  return self.data
end

function Bank:toSyxMessages()
  local m = SyxMsg()
  m.data = self.data
  return m
end
