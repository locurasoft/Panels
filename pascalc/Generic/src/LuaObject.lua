LuaObject = {}
LuaObject.__index = LuaObject

setmetatable(LuaObject, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function LuaObject:_init()

end

--function __Object:new(o)
--	o = o or {}
--	setmetatable(o, self)
--	self.__index = self
--
--	return o
--end

function LuaObject:isSerializable()
	return self[LUA_CONTRUCTOR_NAME] ~= nil
end

function LuaObject:getLuaClassName()
	return self[LUA_CONTRUCTOR_NAME]
end

--function Object()
--	return __Object:new()
--end