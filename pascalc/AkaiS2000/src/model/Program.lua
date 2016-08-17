local log = Logger("Program")

__Program = Dispatcher()

function __Program:getName()
	return self.pdata:getName()
end

function __Program:setName(name)
	self.pdata:setName(name)
	self:notifyListeners()
end

function __Program:setProgramNumber(programNumber)
	self.pdata:setProgramNumber(programNumber)
end

function __Program:getProgramNumber()
	return self.pdata:getProgramNumber()
end

function __Program:setActiveKeyGroupIndex(index)
	self.activeKg = index
	--self:notifyListeners()
end

function __Program:getActiveKeyGroupIndex()
	return self.activeKg
end

function __Program:getActiveKeyGroup()
	return self.keyGroups[self.activeKg]
end

function __Program:getNumKeyGroups()
	return table.getn(self.keyGroups)
end

function __Program:addKeyGroup(keyGroup)
	table.insert(self.keyGroups, keyGroup)
	self:notifyListeners()
end

function __Program:getKeyGroup(index)
	return self.keyGroups[index]
end

function __Program:removeKeyGroup(index)
	table.remove(self.keyGroups, index)
	self:notifyListeners()
end

function __Program:storeParamEdit(phead)
	if self.updating then
		return
	end
	self.pdata:storePhead(phead)
end

function __Program:getParamValue(blockId)
	return self.pdata:getPdataValue(blockId)
end

function __Program:setUpdating(updating)
	self.updating = updating
end

function __Program:isUpdating()
	return self.updating
end

function __Program:toString()
	return self.pdata:toString()
end

function __Program:toJson()
	local base = json.encode(self)
	-- Replace pdata
	base = string.gsub(
		base, "\"pdata\":{[^}]+}", string.format("\"pdata\":%s", self.pdata:toJson()),	1)
	-- Replace keygroups
	local kgs = ""
	for k,v in pairs(self.keyGroups) do
		if kgs == "" then
			kgs = string.format("%s", v:toJson())
		else
			kgs = string.format("%s,%s", kgs, v:toJson())
		end
	end
	base = string.gsub(
		base, "\"keyGroups\":\[[^]+\]", string.format("\"keyGroups\":[%s]", kgs),	1)
	return base
end

function Program(data)
	data = data or Pdata()
	return __Program:new{
		pdata = data,
		keyGroups = {},
		activeKg = 1,
		updating = false,
		[LUA_CLASS_NAME] = "Program"
	}
end
