require("akaiS2kTestUtils")
require("service.ProgramService")
require("service.MidiService")
require 'lunity'
require 'lemock'
module( 'ProgramServiceTest', lunity )

local underTest

function setup()
  -- code here will be run before each test
  underTest = ProgramService()
  regGlobal("midiService", MidiService())
end

function teardown()
  -- code here will be run after each test
end

--function testPhead()
--  local program = Program()
--  program:setProgramNumber(1)
--  local result = underTest:phead(program, PROG_STRING, "PRNAME", "Hello")
--  print(result:toString():upper())
--end

function testNewProgram()
	local data = "F0 47 00 07 48 14 00 01 00 00 0C 06 06 01 01 03 01 0C 00 0D 01 09 01 08 01 0A 00 0C 00 0B 00 0D 01 0D 01 02 00 03 01 00 00 0F 01 01 00 08 01 0F 07 00 00 00 00 03 06 00 00 0A 05 02 03 00 00 00 00 00 01 00 00 02 03 00 00 07 03 00 00 02 03 09 00 00 00 00 00 02 00 00 00 01 00 07 00 03 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 0A 00 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 05 00 00 00 00 02 00 00 00 00 00 06 00 08 00 01 00 06 00 03 00 06 00 06 00 06 00 05 00 03 00 0A 00 0A 00 05 00 00 00 09 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0C 03 00 00 00 00 00 00 00 00 0E 01 02 03 0E 01 0C 03 00 00 00 00 00 00 00 00 00 00 00 00 09 01 00 00 0F 0F 0F 0F 0D 01 03 01 08 01 0F 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 0A 00 00 00 0F 07 00 00 00 00 00 00 00 00 00 00 00 00 0F 0F 0F 0F 00 00 00 00 0D 01 0B 01 0F 01 0B 00 0C 01 0F 00 0A 00 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 F7"
	local pdata = PdataMsg(MemoryBlock(data))
	local prog = Program(pdata)
	print(string.format("Name '%s'", prog:getParamValue("PRNAME")))
	prog:setName("Pelle")
	print(string.format("Name '%s'", prog:getParamValue("PRNAME")))
end

runTests{useANSI = false}
