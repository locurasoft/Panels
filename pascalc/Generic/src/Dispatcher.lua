__Dispatcher = Object()

function __Dispatcher:addListener(listener)
	table.insert(self.listeners, listener)
	return table.getn(self.listeners)
end

function __Dispatcher:removeListener(id)
	table.remove(self.listeners, id)
end

function __Dispatcher:notifyListeners()
	for k,v in pairs(self.listeners) do
		v(self)
	end
end

function Dispatcher()
	return __Dispatcher:new{ listeners = {} }
end
