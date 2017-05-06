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
  Voice_singleSize = 210
  Voice_SingleDataSize = 204
  Voice_NumPatches = 40
  Voice_Header = MemoryBlock({ 0xF0, 0x0F, 0x02, 0x00, 0x01 })
  Voice_HeaderSize = Voice_Header:getSize()
  Voice_Footer = MemoryBlock({ 0xF7 })
  Voice_FooterSize = Voice_Footer:getSize()

  Voice_PartialMuteUpdating = false

  -- Init logger
  LOGGER = Logger("Global")
  LOGGER:info("[initPanel] Initializing...")

  midiService = MidiService()

  ensoniqEsq1Controller = EnsoniqEsq1Controller()
end
