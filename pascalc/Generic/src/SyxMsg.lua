__SyxMsg = Object()

function __SyxMsg:toMidiMessage()
	return CtrlrMidiMessage(self.data)
end

function __SyxMsg:toString()
	return self.data:toHexString(1)
end

function __SyxMsg:toJson()
	return string.gsub(
		json.encode(self), 
		"^{", 
		string.format("{data = \"%s\",", self.data:toHexString(1)), 
		1)
end

function SyxMsg()
	return __SyxMsg:new{ data = nil }
end
