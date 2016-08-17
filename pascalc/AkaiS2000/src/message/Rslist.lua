__RslistMsg = SyxMsg()

function Rslist()
	local bytes = {0xf0, 0x47, 0x00, 0x04, 0x48, 0xf7}
	return __RslistMsg:new{ data = bytes }
end
