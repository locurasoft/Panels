--
-- Called when the panel has finished loading
--
-- @type the type of instance beeing started, types available in the CtrlrPanel
-- class as enum
--
-- InstanceSingle
-- InstanceMulti
-- InstanceSingleRestriced
-- InstanceSingleEngine
-- InstanceMultiEngine
-- InstanceSingleRestrictedEngine
--
function onPanelBeforeLoad(type)

  -- Init global constants
  LUA_CONTRUCTOR_NAME = "LUA_CLASS_NAME"
  
  -- Init logger
  LOGGER = Logger("Global")
  LOGGER:info("[initPanel] Initializing...")

  NUM_PATCHES = 64
  SINGLE_DATA_SIZE = 265
  Voice_Header = MemoryBlock({ 0xF0, 0x18, 0x04, 0x00, 0x01 })
  COMPLETE_HEADER_SIZE = Voice_Header:getSize()
  Voice_Footer = MemoryBlock({ 0x00, 0xF7 })
  Voice_FooterSize = Voice_Footer:getSize()
  BANK_BUFFER_SIZE = 16960

  emuProteus2Controller = EmuProteus2Controller()
end
