require("LuaObject")
require("Logger")
require("lutils")

local log = Logger("AbstractBank")

AbstractBank = {}
AbstractBank.__index = AbstractBank

setmetatable(AbstractBank, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function AbstractBank:_init(bankData)
  LuaObject._init(self)

  self.selectedPatchIndex = 0
end

function AbstractBank:getSelectedPatchIndex()
  return self.selectedPatchIndex
end

function AbstractBank:getSelectedPatch()
  return self.patches[self.selectedPatchIndex + 1]
end

function AbstractBank:selectPatch(patchIndex)
  self.selectedPatchIndex = patchIndex
end

function AbstractBank:isSelectedPatch(patchIndex)
  return self.selectedPatchIndex == patchIndex
end

function AbstractBank:setSelectedPatchIndex(selectedPatchIndex)
  self.selectedPatchIndex = selectedPatchIndex
end
