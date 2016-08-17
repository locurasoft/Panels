__Object = {}

function __Object:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	return o
end

function __Object:isSerializable()
	return self[LUA_CLASS_NAME] ~= nil
end

function __Object:getLuaClassName()
	return self[LUA_CLASS_NAME]
end

function Object()
	return __Object:new()
end