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

  PerformanceBankData = nil
  Performance_checksumEnd = 4101
  Performance_checksumOffset = 4102
  Performance_checksumStart = 6
  Performance_dxSinglePackedSize = 64
  Performance_dxSysexHeaderSize = 6
  Performance_singleSize = 102
  VoicePatchNames = {}
  VoiceBankData = nil
  Voice_offsets={[26]=7, [47]=7, [68]=7, [89]=7, [110]=7, [131]=7}
  Voice_checksumEnd = 160
  Voice_checksumOffset = 161
  Voice_checksumStart = 6
  Voice_dxSinglePackedSize = 128
  Voice_dxSysexHeaderSize = 6
  Voice_singleSize = 163
  Voice_SelectedPatchIndex = 0
  DisableMemoryProtect = false
  BANK_BUFFER_SIZE = 4104
  PATCH_BUFFER_SIZE = 163
  PERFORMANCE_BUFFER_SIZE = 163
  NUM_PATCHES = 32
  

  yamahaDX7Controller = YamahaDX7Controller()
end
