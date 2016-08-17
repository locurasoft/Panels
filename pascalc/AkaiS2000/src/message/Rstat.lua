__RstatMsg = SyxMsg()

function Rstat()
	local bytes = {0xf0, 0x47, 0x00, 0x00, 0x48, 0xf7}
	return __RstatMsg:new{ data = bytes }
end
