local log = Logger("ProcessService")
local MIDI_POLL_THREAD_ID = 33

__ProcessService = Object()

local getFileContents = function(filepath)
	local f = io.open(filepath, "rb")
	local content = ""
	if f ~= nil then
		content = f:read("*all")
		f:close()
	end
	
	return content
end

local macOsXExecutor = function(scriptDir, scriptName)
	os.execute(string.format("chmod 755 %s/%s", scriptDir, scriptName))
	os.execute(string.format("pushd %s; ./%s > %s.log 2>&1", scriptDir, scriptName, scriptName))

	local logPath = string.format("%s/%s.log", scriptDir, scriptName)
end

local windowsExecutor = function(scriptDir, scriptName)
	local scriptPath = string.format("%s\\%s", scriptDir, scriptName)
	local script = io.open(scriptPath, "a")
	script:write(eol)
	script:write("exit")
	script:write(eol)
	script:close()

	os.execute(string.format("cmd /C start /B %s ^> %s.log", scriptPath, scriptPath))
end

function __ProcessService:execute(proc)
	if self.curr_transfer_proc == nil then
		self.curr_transfer_proc = proc

		if self.processListener ~= nil then
			self.processListener(true)
		end

		log:info("Execute")
		if proc.midiCallback ~= nil then
			log:info("Adding midiCallback")
			midiSrvc:setMidiReceived(proc.midiCallback)
		end

		if proc.midiSender ~= nil then
			log:info("Launching midiSender")

			timer:stopTimer(MIDI_POLL_THREAD_ID)

			timer:setCallback (MIDI_POLL_THREAD_ID, proc.midiSender)
			log:info("Starting timer %d, with interval %d", MIDI_POLL_THREAD_ID, proc.interval)
			timer:startTimer(MIDI_POLL_THREAD_ID, proc.interval)
		end

		if proc:hasLauncher() then
			proc:build()
			local scriptPath = proc:getScriptPath()
			local scriptName = proc:getLaunchName()
			if operatingSystem == "win" then
				log:info("[hxcLaunchOnWindows] %s - %s:", scriptPath, scriptName)
				windowsExecutor(scriptPath, scriptName)
			else
				log:info("[hxcLaunchOnMacOsX] %s - %s", scriptPath, scriptName)
				macOsXExecutor(scriptPath, scriptName)
			end
		end

		log:info("Done")
		return true
	else
		return false
	end
end

function __ProcessService:abort()
	log:info("abort()")
	if self.curr_transfer_proc == nil then
		log:info("No active process to abort!")
	else
		timer:stopTimer(MIDI_POLL_THREAD_ID)
		midiSrvc:clearMidiReceived()

		if self.curr_transfer_proc:hasAborter() then
			local scriptPath = self.curr_transfer_proc:getScriptPath()
			local scriptName = self.curr_transfer_proc:getAbortName()
			if operatingSystem == "win" then
				log:info("[hxcLaunchOnWindows] %s - %s:", scriptPath, scriptName)
				windowsExecutor(scriptPath, scriptName)
			else
				log:info("[hxcLaunchOnMacOsX] %s - %s", scriptPath, scriptName)
				macOsXExecutor(scriptPath, scriptName)
			end
		end

		if self.processListener ~= nil then
			self.processListener(false)
		end

		self.curr_transfer_proc = nil
	end
end

function ProcessService(pl)
	return __ProcessService:new{
		processListener = pl,
		curr_transfer_proc = nil
	}
end
