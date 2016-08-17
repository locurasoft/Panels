__RplistMsg = SyxMsg()

function Rplist()
	local bytes = {0xf0, 0x47, 0x00, 0x02, 0x48, 0xf7}
	return __RplistMsg:new{ data = bytes }
end
