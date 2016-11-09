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
  STATE_DEV, STATE_PROD = 1, 2
  if PANEL_STATE == 0 then
    PANEL_STATE = STATE_PROD
  end

  LUA_CONTRUCTOR_NAME = "LUA_CLASS_NAME"
  
  MODEL_NAMES = {
    "DrumMap",
    "Settings",
    "ProgramList",
    "SampleList",
    "SampleEdit"
  }

  PROGRAM_BLOCK = {
    ["KGRP1@"]      = 1,
    ["PRNAME"]      = 3,
    ["PRGNUM"]      = 15,
    ["PMCHAN"]      = 16,
    ["POLYPH"]      = 17,
    ["PRIORT"]      = 18,
    ["PLAYLO"]      = 19,
    ["PLAYHI"]      = 20,
    ["OSHIFT"]      = 21,
    ["OUTPUT"]      = 22,
    ["STEREO"]      = 23,
    ["PANPOS"]      = 24,
    ["PRLOUD"]      = 25,
    ["V_LOUD"]      = 26,
    ["K_LOUD"]      = 27,
    ["P_LOUD"]      = 28,
    ["PANRAT"]      = 29,
    ["PANDEP"]      = 30,
    ["PANDEL"]      = 31,
    ["K_PANP"]      = 32,
    ["LFORAT"]      = 33,
    ["LFODEP"]      = 34,
    ["LFODEL"]      = 35,
    ["MWLDEP"]      = 36,
    ["PRSDEP"]      = 37,
    ["VELDEP"]      = 38,
    ["B_PTCH"]      = 39,
    ["P_PTCH"]      = 40,
    ["KXFADE"]      = 41,
    ["GROUPS"]      = 42,
    ["TPNUM"]       = 43,
    ["TEMPER"]      = 44,
    ["ECHOUT"]      = 56,
    ["MW_PAN"]      = 57,
    ["COHERE"]      = 58,
    ["DESYNC"]      = 59,
    ["PLAW"]        = 60,
    ["VASSOQ"]      = 61,
    ["SPLOUD"]      = 62,
    ["SPATT"]       = 63,
    ["SPFILT"]      = 64,
    ["PTUNO"]       = 65,
    ["K_LRAT"]      = 67,
    ["K_LDEP"]      = 68,
    ["K_LDEL"]      = 69,
    ["VOSCL"]       = 70,
    ["VSSCL"]       = 71,
    ["LEGATO"]      = 72,
    ["B_PTCHD"]     = 73,
    ["B_MODE"]      = 74,
    ["TRANSPOSE"]   = 75,
    ["MODSPAN1"]    = 76,
    ["MODSPAN2"]    = 77,
    ["MODSPAN3"]    = 78,
    ["MODSAMP1"]    = 79,
    ["MODSAMP2"]    = 80,
    ["MODSLFOT"]    = 81,
    ["MODSLFOL"]    = 82,
    ["MODSLFOD"]    = 83,
    ["MODSFILT1"]   = 84,
    ["MODSFILT2"]   = 85,
    ["MODSFILT3"]   = 86,
    ["MODSPITCH"]   = 87,
    ["MODSAMP3"]    = 88,
    ["MODVPAN1"]    = 89,
    ["MODVPAN2"]    = 90,
    ["MODVPAN3"]    = 91,
    ["MODVAMP1"]    = 92,
    ["MODVAMP2"]    = 93,
    ["MODVLFOR"]    = 94,
    ["MODVLVOL"]    = 95,
    ["MODVLFOD"]    = 96,
    ["LFO1WAVE"]    = 97,
    ["LFO2WAVE"]    = 98,
    ["MODSLFLT2_1"] = 99,
    ["MODSLFLT2_2"] = 100,
    ["MODSLFLT2_3"] = 101,
    ["lfo2trig"]    = 102,
    ["Reserved"]    = 103,
    ["PORTIME"]     = 110,
    ["PORTYPE"]     = 111,
    ["PORTEN"]      = 112,
    ["PFXCHAN"]     = 113,
    ["PFXSLEV"]     = 114
  }

  KEY_GROUP_BLOCK = {
    ["KGIDENT"]     = 0,
    ["NXTKG@"]      = 1,
    ["LONOTE"]      = 3,
    ["HINOTE"]      = 4,
    ["KGTUNO"]      = 5,
    ["FILFRQ"]      = 7,
    ["K_FREQ"]      = 8,
    ["V_FREQ"]      = 9,
    ["P_FREQ"]      = 10,
    ["E_FREQ"]      = 11,
    ["ATTAK1"]      = 12,
    ["DECAY1"]      = 13,
    ["SUSTN1"]      = 14,
    ["RELSE1"]      = 15,
    ["V_ATT1"]      = 16,
    ["V_REL1"]      = 17,
    ["O_REL1"]      = 18,
    ["K_DAR1"]      = 19,
    ["ENV2R1"]      = 20,
    ["ENV2R3"]      = 21,
    ["ENV2L3"]      = 22,
    ["ENV2R4"]      = 23,
    ["V_ATT2"]      = 24,
    ["V_REL2"]      = 25,
    ["O_REL2"]      = 26,
    ["K_DAR2"]      = 27,
    ["V_ENV2"]      = 28,
    ["E_PTCH"]      = 29,
    ["VXFADE"]      = 30,
    ["VZONES"]      = 31,
    ["LKXF"]        = 32,
    ["RKXF"]        = 33,
    ["SNAME1"]      = 34,
    ["LOVEL1"]      = 46,
    ["HIVEL1"]      = 47,
    ["VTUNO1"]      = 48,
    ["VLOUD1"]      = 50,
    ["VFREQ1"]      = 51,
    ["VPANO1"]      = 52,
    ["ZPLAY1"]      = 53,
    ["LVXF1"]       = 54,
    ["HVXF1"]       = 55,
    ["SBADD1"]      = 56,
    ["SNAME2"]      = 58,
    ["LOVEL2"]      = 70,
    ["HIVEL2"]      = 71,
    ["VTUNO2"]      = 72,
    ["VLOUD2"]      = 74,
    ["VFREQ2"]      = 75,
    ["VPANO2"]      = 76,
    ["ZPLAY2"]      = 77,
    ["LVXF2"]       = 78,
    ["HVXF2"]       = 79,
    ["SBADD2"]      = 80,
    ["SNAME3"]      = 82,
    ["LOVEL3"]      = 94,
    ["HIVEL3"]      = 95,
    ["VTUNO3"]      = 96,
    ["VLOUD3"]      = 98,
    ["VFREQ3"]      = 99,
    ["VPANO3"]      = 100,
    ["ZPLAY3"]      = 101,
    ["LVXF3"]       = 102,
    ["HVXF3"]       = 103,
    ["SBADD3"]      = 104,
    ["SNAME4"]      = 106,
    ["LOVEL4"]      = 118,
    ["HIVEL4"]      = 119,
    ["VTUNO4"]      = 120,
    ["VLOUD4"]      = 122,
    ["VFREQ4"]      = 123,
    ["VPANO4"]      = 124,
    ["ZPLAY4"]      = 125,
    ["LVXF4"]       = 126,
    ["HVXF4"]       = 127,
    ["SBADD4"]      = 128,
    ["KBEAT"]       = 130,
    ["AHOLD"]       = 131,
    ["CP1"]         = 132,
    ["CP2"]         = 133,
    ["CP3"]         = 134,
    ["CP4"]         = 135,
    ["VZOUT1"]      = 136,
    ["VZOUT2"]      = 137,
    ["VZOUT3"]      = 138,
    ["VZOUT4"]      = 139,
    ["VSS1"]        = 140,
    ["VSS2"]        = 142,
    ["VSS3"]        = 144,
    ["VSS4"]        = 146,
    ["KV_LO"]       = 148,
    ["FILQ"]        = 149,
    ["L_PTCH"]      = 150,
    ["MODVFILT1"]   = 151,
    ["MODVFILT2"]   = 152,
    ["MODVFILT3"]   = 153,
    ["MODVPITCH"]   = 154,
    ["MODVAMP3"]    = 155,
    ["ENV2L1"]      = 156,
    ["ENV2R2"]      = 157,
    ["ENV2L2"]      = 158,
    ["ENV2L4"]      = 159,
    ["kgmute"]      = 160,
    ["PFXCHAN"]     = 161,
    ["PFXSLEV"]     = 162,
    ["Reserved"]    = 163,
    ["LSI2_ON"]     = 168,
    ["FLT2GAIN"]    = 169,
    ["FLT2MODE"]    = 170,
    ["FLT2Q"]       = 171,
    ["TONEFREQ"]    = 172,
    ["TONESLOP"]    = 173,
    ["MODVFLT2_1"]  = 174,
    ["MODVFLT2_2"]  = 175,
    ["MODVFLT2_3"]  = 176,
    ["FIL2FR"]      = 177,
    ["K_FRQ2"]      = 178,
    ["ENV3R1"]      = 179,
    ["ENV3L1"]      = 180,
    ["ENV3R2"]      = 181,
    ["ENV3L2"]      = 182,
    ["ENV3R3"]      = 183,
    ["ENV3L3"]      = 184,
    ["ENV3R4"]      = 185,
    ["ENV3L4"]      = 186,
    ["V_ATT3"]      = 187,
    ["V_REL3"]      = 188,
    ["O_REL3"]      = 189,
    ["K_DAR3"]      = 190,
    ["V_ENV3"]      = 191
  }

  -- Init logger
  LOGGER = Logger("Global")
  LOGGER:info("[initPanel] Initializing...")

  panel:setProperty ("panelGlobalVariables", "0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0", false)
  loopAtResource = resources:getResource("AkaiLoopAt")
  loopAtImage = Image()
  if loopAtResource ~= nil then
    loopAtImage = loopAtResource:asImage()
  else
    LOGGER:warn("loopAtResource invalid, panel will crash")
  end

  for key, modelName in ipairs(MODEL_NAMES) do
    local varName = modelName:sub(1, 1):lower() .. modelName:sub(2)
    if _G[varName] == nil then
      LOGGER:info("Initialising new %s...", modelName)
     _G[varName] = _G[modelName]()
    else
      LOGGER:info("Using %s: %s", varName, _G[varName])
      _G[varName] = cson.decode(_G[varName])
    end
  end
    
  local processListener = function(running)
    if running then
      drumMapController:updateStatus("Running process...")
      drumMapController:toggleActivation("cancelTransfer", true)
    else
      drumMapController:updateStatus("Ready.")
      drumMapController:toggleActivation("cancelTransfer", false)
    end
  end

  midiService    = MidiService()
  drumMapService = DrumMapService()
  programService = ProgramService()
  hxcService     = HxcService(settings)
  s2kDieService  = S2kDieService(settings)

  processController     = ProcessController(processListener)
  drumMapController     = DrumMapController(drumMap, sampleList)
  programController     = ProgramController(programList)
  sampleListController  = SampleListController(sampleList)
  settingsController    = SettingsController(settings)
  globalController      = GlobalController()
end
