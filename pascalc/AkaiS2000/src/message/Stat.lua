__StatMsg = SyxMsg()

function __StatMsg:getSwVersion()
	return string.format("%d.%d", self.data:getByte(6), self.data:getByte(5))
end

function __StatMsg:getNumFreeWords()
	local result = 0
	for i = 15,18 do
		local offset = 128 ^ (i - 15)
		result = result + self.data:getByte(i) * offset
	end
	return result
end

function Stat(bytes)
	if bytes:getSize() == 21 and bytes:getByte(3) == 0x01 then
		return __StatMsg:new{ data = bytes }
	else
		console("MIDI is not a stat message")
		console(data:toHexString(1))
		return nil
	end
end
