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
  BANK_BUFFER_SIZE = 8166
  PATCH_BUFFER_SIZE = 210
  SINGLE_DATA_SIZE = 204
  NUM_PATCHES = 40

  -- Init logger
  LOGGER = Logger("Global")
  LOGGER:info("[initPanel] Initializing...")

  midiService = MidiService()

  ensoniqEsq1Controller = EnsoniqEsq1Controller()
end
