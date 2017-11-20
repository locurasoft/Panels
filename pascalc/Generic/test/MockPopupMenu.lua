require("LuaObject")
require("Logger")

POPUP_MENU_SELECT_VALUE = 0
MockPopupMenu = {}
MockPopupMenu.__index = MockPopupMenu

local log = Logger("MockPopupMenu")

setmetatable(MockPopupMenu, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockPopupMenu:_init()
  LuaObject._init(self)
end

function MockPopupMenu:show()
  return POPUP_MENU_SELECT_VALUE
end

function MockPopupMenu:addItem()
end
