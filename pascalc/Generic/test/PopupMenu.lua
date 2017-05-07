require("LuaObject")
require("Image")
require("Logger")
require("lutils")

local log = Logger("PopupMenu")

PopupMenu = {}
PopupMenu.__index = PopupMenu

setmetatable(PopupMenu, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function PopupMenu:_init()
  LuaObject._init(self)
end

function PopupMenu:addItem()
	
end

function PopupMenu:show()
	return POPUP_MENU_SHOW_RETVAL
end