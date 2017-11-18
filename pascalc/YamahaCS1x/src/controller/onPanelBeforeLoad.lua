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
  LOG_LEVEL = FINE

  Voice_SelectedPatchIndex = 0
  SinglePerformanceSize = 319
  PerformanceBankSize = 40576
  COMMON, COMMON_1, COMMON_2, LAYER1, LAYER2, LAYER3, LAYER4 = 1, 2, 3, 4, 5, 6, 7
  NUM_PATCHES = 128

  midiService = MidiService()

  yamahaCS1xController = YamahaCS1xController()
end
