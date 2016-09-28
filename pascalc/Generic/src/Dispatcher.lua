require("LuaObject")

Dispatcher = {}
Dispatcher.__index = Dispatcher

setmetatable(Dispatcher, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function Dispatcher:_init()
  LuaObject._init(self)
  self.listeners = {}
end

local bind = function(t, k)
	return function(...) return t[k](t, ...) end
end

function Dispatcher:addListener(listener, funcName)
	table.insert(self.listeners, bind(listener, funcName))
	return table.getn(self.listeners)
end

function Dispatcher:removeListener(id)
	table.remove(self.listeners, id)
end

function Dispatcher:notifyListeners()
	for k,v in pairs(self.listeners) do
		v(self)
	end
end
