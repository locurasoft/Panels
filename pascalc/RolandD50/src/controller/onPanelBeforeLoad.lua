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
  LUA_CONTRUCTOR_NAME = "LUA_CLASS_NAME"

  Voice_singleSize = 448
  Voice_Header = MemoryBlock({ 0xF0, 0x41, 0x00, 0x14, 0x12, 0x00, 0x00, 0x00 })
  Voice_HeaderSize = Voice_Header:getSize()
  Voice_Footer = MemoryBlock({ 0x00, 0xF7 })
  Voice_FooterSize = Voice_Footer:getSize()

  Voice_PartialMuteUpdating = false
  Voice_SelectedPatchIndex = 0

  -- Init logger
  LOGGER = Logger("Global")
  LOGGER:info("[initPanel] Initializing...")

  midiService = MidiService()

  rolandD50Controller = RolandD50Controller()
end
