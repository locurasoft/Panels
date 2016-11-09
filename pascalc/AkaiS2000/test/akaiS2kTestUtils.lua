require("ctrlrTestUtils")

function setupIntegrationTest(tmpFolderName, processListener, midiListener)
  regGlobal("panel", MockPanel("Akai-S2000.panel", midiListener))
  local log = Logger("GLOBAL")
  log:setLevel(3)
  regGlobal("LOGGER", log)

  local settings = Settings()
  settings:setWorkFolder(File(tmpFolderName))
  settings:setS2kDiePath(File("c:\\ctrlr\\s2kdie\\s2kdie.php"))
  settings:setHxcPath(File("hxc.exe"))
  settings:setTransferMethod(1)

  local programList = ProgramList()
  local drumMap = DrumMap()
  local sampleList = SampleList()

  regGlobal("programList", programList)
  regGlobal("settings", settings)
  regGlobal("drumMap", drumMap)
  regGlobal("sampleList", sampleList)

  regGlobal("globalController", GlobalController())
  regGlobal("drumMapController", DrumMapController(drumMap, sampleList))
  regGlobal("settingsController", SettingsController(settings))
  regGlobal("sampleListController", SampleListController(sampleList))
  regGlobal("processController", ProcessController(processListener))
  regGlobal("programController", ProgramController(programList))

  regGlobal("programService", ProgramService())
  regGlobal("drumMapService", DrumMapService())
  regGlobal("midiService", MidiService())
  regGlobal("s2kDieService", S2kDieService(settings))
  regGlobal("hxcService", HxcService(settings))

  panel:getModulatorByName("kgSelector"):setValue(1)
end

function tearDownIntegrationTest(tmpFolderName)
  delGlobal("midiService")
  delGlobal("panel")
  delGlobal("drumMap")
  delGlobal("settings")
  delGlobal("drumMapController")
  delGlobal("drumMapService")
  delGlobal("processController")
end

local samplesData = {
  "0E 0B 17 1A 27 11 0C 1D 18 27 27 16", -- DAMP-GBSN--L
  "0E 0B 17 1A 27 11 0C 1D 18 27 27 1C", -- DAMP-GBSN--R
  "1A 1F 16 16 27 11 1E 1C 27 27 11 02", -- PULL-GTR--G2
  "1D 17 0B 0D 15 13 18 0A 0A 0A 0A 0A", -- SMACKIN
  "17 1F 1E 0F 0A 11 1E 1C 0A 11 02 0A", -- MUTE GTR G2
  "17 1F 1E 0F 0A 11 1E 1C 0A 0E 03 0A", -- MUTE GTR D3
  "17 1F 1E 0F 0A 11 1E 1C 0A 0F 04 0A", -- MUTE GTR E4
  "0E 0B 17 1A 0A 11 1E 1C 0A 11 02 0A", -- DAMP GTR G2
  "0E 0B 17 1A 0A 11 1E 1C 0A 0E 03 0A", -- DAMP GTR D3
  "0E 0B 17 1A 0A 11 1E 1C 0A 0F 04 0A", -- DAMP GTR E4
  "17 1F 1E 0F 0A 11 1E 1C 0A 0D 05 0A", -- MUTE GTR C5
  "0E 0B 17 1A 0A 11 1E 1C 0A 0D 05 0A", -- DAMP GTR C5
  "1A 1F 16 16 0A 11 1E 1C 0A 0E 03 0A", -- PULL GTR D3
  "1A 1F 16 16 0A 11 1E 1C 0A 0F 04 0A", -- PULL GTR E4
  "11 0C 1D 18 0A 03 03 05 0A 0F 02 0A", -- GBSN 335 E2
  "11 0C 1D 18 0A 03 03 05 0A 0B 02 0A", -- GBSN 335 A2
  "11 0C 1D 18 0A 03 03 05 0A 0F 03 0A", -- GBSN 335 E3
  "11 0C 1D 18 0A 03 03 05 0A 0B 03 0A", -- GBSN 335 A3
  "11 0C 1D 18 0A 03 03 05 0A 0F 04 0A", -- GBSN 335 E4
  "11 0C 1D 18 0A 03 03 05 0A 0B 04 0A", -- GBSN 335 A4
  "11 0C 1D 18 0A 03 03 05 0A 0F 05 0A", -- GBSN 335 E5
  "11 0C 1D 18 0A 03 03 05 0A 1A 13 15", -- GBSN 335 PIK
  "11 0C 1D 18 0A 12 0B 1C 17 19 18 0D", -- GBSN HARMONC
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0F 04", -- DAMP GBSN E4
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0D 05", -- DAMP GBSN C5
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0B 02", -- DAMP GBSN A2
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0F 03", -- DAMP GBSN E3
  "0E 0B 17 1A 0A 11 0C 1D 18 0A 0B 03", -- DAMP GBSN A3
}


function newSlistMsg(numSamples)
  local bytes = string.format("F0 47 00 05 48 %.2X 00", numSamples)
  for i = 1, numSamples do
    bytes = string.format("%s %s", bytes, samplesData[i])
  end
  return MemoryBlock(string.format("%s %s", bytes, "F7"))
end

function newKeyGroupComponent(index)
  local comp = panel:getComponent(string.format("drumMap-%d", index))
  comp:setProperty("componentGroupName", string.format("drumMap-%d-grp", index))
  return comp
end

function newModulatorWithCustomIndex(name, customIndex)
  local mod = panel:getModulator(name)
  mod:setProperty("modulatorCustomIndex", string.format("%d", customIndex))
  return mod
end

function assignSamples(selectedComp, ...)
  if type(selectedComp) == "number" then
    selectedComp = newKeyGroupComponent(selectedComp)
  end

  drumMapController:onPadSelected(selectedComp)
  for i,v in ipairs(arg) do
    drumMapController:onFileDoubleClicked(File(string.format("test/data/%s", v)))
  end
end

function writeLauncherLog(numWavs, numSamples, ctrlrwork, tmpFolderName)
  local workPath = ctrlrwork:getFullPathName()
  local execDir = ctrlrwork:getParentDirectory():getFullPathName()
  local contents = ""
  
  for i = 1, numWavs do
    contents = string.format("%s%s>cp %s\test\data\PULL-GTR-G2.wav %s\PULL-GTR-G2.wav\r\n", contents, execDir, execDir, workPath)
  end
  
  contents = string.format("%s%s>cd %s\r\n", contents, execDir, workPath)
  contents = string.format("%s%s>php c:\ctrlr\s2kdie\s2kdie.php %s\script-40947.s2k\r\n\r\n", contents, execDir, workPath)
  contents = string.format("%s%s", contents, "AKAI S2000/S3000/S900 Disk Image Editor v1.1.2\r\n(? for help.)\r\n\r\n")
  contents = string.format("%s%s", contents, "Floppy read/writes disabled, setfdprm not found.\r\n\r\n")
  contents = string.format("%s%s", contents, "Command selected: BLANK S2000\r\n")
  contents = string.format("%s%s", contents, "Image in memory blanked.\r\n")
  contents = string.format("%s%s", contents, "Command selected: VOL script-40947.s2k\r\n")
  contents = string.format("%s%s", contents, "SCRIPT-40947\r\n")
  
  for i = 1, numWavs do
    contents = string.format("%sCommand selected: WLOAD PULL-GTR-G2.wav\r\n", contents)
    contents = string.format("%sStereo WAV imported as akai samples.\r\n", contents)
  end
  contents = string.format("%sCommand selected: SAVE %s\floppy-40947.img\r\n", contents, workPath)
  contents = string.format("%sImage saved.\r\nCommand selected: DIR\r\n\r\n", contents)
  contents = string.format("%s      S2000 Volume: SCRIPT-40947\r\n\r\n", contents)
  contents = string.format("%s      Filename       Type        Bytes\r\n", contents)
  for i = 0, numSamples - 1 do
    contents = string.format("%s  [%d] PULL-GTR-G-L   <UNKNOWN>   98034\r\n", contents, i)
  end
  contents = string.format("%s      1318 unused sectors.  (1349632 bytes free)\r\n\r\n", contents)
  contents = string.format("%sCommand selected: \r\n\r\n\r\n", contents)
  contents = string.format("%s%s> cd %s\r\n", contents, workPath, execDir)
  contents = string.format("%s%s>%s\hxc.exe -uselayout:AKAIS3000_HD -finput:%s\floppy-40947.img -usb:\r\n", contents, execDir, execDir, workPath)
  contents = string.format("%s%s>exit\r\n", contents, execDir)
  
  cutils.writeToFile(cutils.toFilePath(tmpFolderName, "scriptLauncher.bat.log"), contents)
end


regGlobal("INTELL_TYPE", 0)
regGlobal("CYCLIC_TYPE", 1)

regGlobal("NO_LOOPING_TYPE", 0)
regGlobal("LP_IN_RELEASE_TYPE", 1)
regGlobal("ONE_SHOT_TYPE", 2)

regGlobal("PROGRAM_BLOCK", {
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
})

regGlobal("KEY_GROUP_BLOCK", {
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
})
