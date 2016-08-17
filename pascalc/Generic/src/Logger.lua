FINE, INFO, WARN = 3, 2, 1
LOG_LEVEL = WARN

__Logger = Object()

function __Logger:setLevel(level)
	LOG_LEVEL = level
end

function __Logger:getLevel()
	return LOG_LEVEL
end

function __Logger:warn(log, ...)
	if LOG_LEVEL >= WARN then
		console(string.format("[WARN] [%s] - %s", self.name, string.format(log, ...)))
	end
end

function __Logger:info(log, ...)
	if LOG_LEVEL >= INFO then
		console(string.format("[INFO] [%s] - %s", self.name, string.format(log, ...)))
	end
end

function __Logger:fine(log, ...)
	if LOG_LEVEL >= FINE then
		console(string.format("[FINE] [%s] - %s", self.name, string.format(log, ...)))
	end
end

function Logger(loggerName)
	return __Logger:new{name = loggerName}
end
