require("DefaultControllerBase")
require("Logger")
require("model/YamahaCS1xBank")
require("model/YamahaCS1xPatch")
require("message/CS1xReceiveMsg")
require("message/CS1xArpegMsg")
require("cutils")
require("lutils")

local log = Logger("YamahaCS1xController")

local voiceBanks = {
  [0] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [1] = { "GrndPnoK", "BritPnoK", "ElGrPnoK", "HnkyTnkK", "El.Pno1K", "El.Pno2K", "Harpsi.K", "Clavi. K", "Celesta", "Glocken", "MusicBox", "VibesK", "MarimbaK", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [3] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "S.Strngs", "S.SlwStr", "Syn.Str1", "Syn.Str2", "S.Choir", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [6] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "MelloSB1", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "FrHrSolo", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "Square 2", "Saw 2", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [8] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "SlowVln", "Viola", "Cello", "Contrabs", "SlowTrStr", "Pizz.Str", "Harp", "Timpani", "Slow Str", "LegatoSt", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "LMSquare", "ThickSaw", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "EchoPad2", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [12] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "Seq Bass", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "QuackBr", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "SynDrCmp", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [14] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Popcorn", "Atmosphr", "Bright", "Goblins", "Echo Pan", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [16] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGt2", "SteelGt2", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "Ch.Aahs2", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet2", "Trombone", "Tuba 2", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Big&Low", "NewAgePd", "ThickPad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [17] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "BriteTrp", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Soft Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [18] = { "MelloGrP", "BritePno", "E.Grand", "HnkyTonk", "MelloEP1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "MelloGtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FingrDrk", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBa1Dk", "ClkSynBa", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trmbone2", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "Soft Brs", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "Hollow", "DynaSaw", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "SinePad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "TinyBell", "WarmAtms", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [19] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBa2Dk", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "Shmoog", "DigiSaw", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "HollwRls", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [20] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "FastResB", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "RezSynBr", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Big Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "Shwimmer", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [24] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "70sPcOr1", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "AcidBass", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "ArcoStr", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "PolyBrss", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "HeavySyn", "CaliopLd", "Chiff Ld", "CharanLd", "SynthAah", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [25] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.2", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGt3", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "WaspySyn", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [27] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "ClaviWah", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FlangeBa", "PickBass", "Fretless", "ResoSlap", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "ResoStr", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras3", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "Converge", "Rain", "Prologue", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [28] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "MutePkBa", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "MuteBnjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [32] = { "GrandPno", "BritePno", "Det.CP80", "HnkyTonk", "Chor.EP1", "Chor.EP2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DetDrwOr", "DetPrcOr", "RockOrgn", "ChurOrg3", "ReedOrgn", "AccordIt", "Harmo 2", "TangoAcd", "NylonGtr", "SteelGtr", "JazzAmp", "ChorusGt", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretles2", "PunchThm", "SlapBas2", "SynBass1", "SmthBa 2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "MelChoir", "VoiceOoh", "SynVoice", "Orch.Hit", "WarmTrp", "Trombone", "Tuba", "Mute.Trp", "FrHorn2", "BrasSect", "JumpBrss", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "DetSitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [33] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "DX Hard", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "60sDrOr1", "LiteOrg", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretles3", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [34] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "DXLegend", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "60sDrOr2", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretles4", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [35] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.3", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimr2", "70sDrOr1", "PercOrgn", "RockOrgn", "ChurOrg2", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "12StrGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "Clv Bass", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "60sStrng", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "OrchHit2", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "Tp&TbSec", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Big Five", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "RndGlock", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar 2", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [36] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrg2", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [37] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "60sDrOr3", "PercOrg2", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "HornOrch", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [38] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "EvenBar", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [39] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [40] = { "PianoStr", "BritePno", "ElGrPno1", "HnkyTonk", "HardEl.P", "DX Phase", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "16+2\"2/3", "PercOrgn", "RockOrgn", "NotreDam", "Puff Org", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "Nyln&Stl", "Jazz Gtr", "CleanGtr", "FunkGtr1", "Ovrdrive", "FeedbkGt", "GtrHarmo", "JazzRthm", "Ba&DstEG", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "TeknoBa", "ModulrBa", "Violin", "Viola", "Cello", "Contrabs", "Susp Str", "Pizz.Str", "YangChin", "Timpani", "Orchestr", "Warm Str", "Syn.Str1", "Syn.Str2", "ChoirStr", "VoiceOoh", "SynVox2", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrssSec2", "SynBras1", "SynBras4", "SprnoSax", "Sax Sect", "BrthTnSx", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "PulseSaw", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "GlockChi", "NylonEP", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [41] = { "Dream", "BritePno", "ElGrPno2", "HnkyTonk", "E.Piano1", "DX+Analg", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "Stl&Body", "Jazz Gtr", "CleanGtr", "MuteStlG", "Ovrdrive", "FeedbGt2", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "DX Bass", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Orchstr2", "Kingdom", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "Choral", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "HiBrass", "SynBras1", "ChorBrss", "SprnoSax", "Alto Sax", "SoftTenr", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Dr. Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "ClearBel", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [42] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "DXKotoEP", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "TremOrch", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "MelloBrs", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "ChorBell", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [43] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "VelGtHrm", "SteelGtr", "Jazz Gtr", "CleanGtr", "FunkGtr2", "Gt.Pinch", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrSlap", "PickBass", "Fretless", "SlapBas1", "VeloSlap", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "HyprAlto", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [45] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "VX El.P1", "VX El.P2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "HardVibe", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Jazz Man", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "VXUprght", "FngBass2", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "VeloStr", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "AnaVelBr", "VelBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "VeloLead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "ClaviPad", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [64] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "60sEl.P", "E.Piano2", "Harpsi.", "PulseClv", "Celesta", "Glocken", "Orgel", "Vibes", "SineMrmb", "Xylophon", "TubulBel", "Dulcimer", "Organ Ba", "PercOrgn", "RotaryOr", "OrgFlute", "ReedOrgn", "Acordion", "Harmnica", "TngoAcd2", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "Oscar", "X WireBa", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "70s Str", "Syn Str4", "Syn.Str2", "ChoirAah", "VoiceOoh", "AnaVoice", "Impact", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "AnaBrss1", "AnaBrss2", "SprnoSax", "Alto Sax", "TnrSax 2", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "Mellow", "Saw.Lead", "CaliopLd", "Rubby", "DistLead", "VoxLead", "Fifth Ld", "Fat&Prky", "Fantasy2", "Horn Pad", "PolyPd80", "Heaven2", "Glacier", "Tine Pad", "Halo Pad", "PolarPad", "HrmoRain", "Ancestrl", "SynMalet", "NylnHarp", "FantaBel", "GobSyn", "EchoBell", "Starz", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai2", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "Mel Tom2", "Ana Tom", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [65] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "PierceCl", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "70sDrOr2", "PercOrgn", "SloRotar", "TrmOrgFl", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtFeedbk", "Aco.Bass", "ModAlem", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SqrBass", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Str Ens3", "SS Str", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SoloSine", "Saw.Lead", "Pure Pad", "Chiff Ld", "WireLead", "Voice Ld", "Fifth Ld", "SoftWurl", "NewAgePd", "RotarStr", "ClickPad", "ChoirPad", "GlassPad", "Pan Pad", "Halo Pad", "SweepPad", "AfrcnWnd", "SoundTrk", "SftCryst", "Harp Vox", "Bright", "50sSciFi", "Big Pan", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "Real Tom", "ElecPerc", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [66] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "CheezOrg", "PercOrgn", "FstRotar", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHrmo2", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "RubberBa", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SineLead", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "Ana Pad", "Itopia", "BowedPad", "MetalPad", "Halo Pad", "Celstial", "Caribean", "SoundTrk", "LoudGlok", "AtmosPad", "Bright", "Ring Pad", "SynPiano", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "Rock Tom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [67] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrg3", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "SquarPad", "CC Pad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "XmasBell", "Planet", "Bright", "Ritual", "Creation", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [68] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "VibeBell", "Atmosphr", "Bright", "ToHeaven", "Stardust", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [69] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "DigiBell", "Atmosphr", "Bright", "Goblins", "Reso Pan", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [70] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "AirBells", "Atmosphr", "Bright", "Night", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [72] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Gamelmba", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "TnklBell", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [96] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "ChrchBel", "Cimbalom", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "Ukulele", "Mandolin", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "SynFretl", "SlapBas1", "SlapBas2", "Hammer", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Seq Ana", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Smokey", "BelChoir", "Echoes", "Sci-Fi", "Tambra", "Rabab", "Shamisen", "T. Koto", "Kalimba", "Bagpipe", "Fiddle", "Pungi", "Bonang", "Agogo", "SteelDrm", "Castanet", "Gr.Cassa", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [97] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Balafon2", "Xylophon", "Carillon", "Santur", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Smooth", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Tamboura", "Gopichnt", "Shamisen", "Kanoon", "Kalimba", "Bagpipe", "Fiddle", "Hichriki", "Gender", "Agogo", "GlasPerc", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [98] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Log Drum", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Oud", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "Gamelan", "Agogo", "ThaiBell", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [99] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "S.Gamlan", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [100] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "Rama Cym", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [101] = { "GrandPno", "BritePno", "E.Grand", "HnkyTonk", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "DrawOrgn", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Aco.Bass", "FngrBass", "PickBass", "Fretless", "SlapBas1", "SlapBas2", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Strings1", "Strings2", "Syn.Str1", "Syn.Str2", "ChoirAah", "VoiceOoh", "SynVoice", "Orch.Hit", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "SprnoSax", "Alto Sax", "TenorSax", "Bari.Sax", "Oboe", "Eng.Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "SquareLd", "Saw.Lead", "CaliopLd", "Chiff Ld", "CharanLd", "Voice Ld", "Fifth Ld", "Bass &Ld", "NewAgePd", "Warm Pad", "PolySyPd", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Rain", "SoundTrk", "Crystal", "Atmosphr", "Bright", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "AsianBel", "Agogo", "SteelDrm", "WoodBlok", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [8192] = { "CuttngNz", "CttngNz2", "E.Grand", "Str Slap", "E.Piano1", "E.Piano2", "Harpsi.", "Clavi.", "Celesta", "Glocken", "MusicBox", "Vibes", "Marimba", "Xylophon", "TubulBel", "Dulcimer", "Fl.KClik", "PercOrgn", "RockOrgn", "ChrchOrg", "ReedOrgn", "Acordion", "Harmnica", "TangoAcd", "NylonGtr", "SteelGtr", "Jazz Gtr", "CleanGtr", "Mute.Gtr", "Ovrdrive", "Dist.Gtr", "GtrHarmo", "Rain", "Thunder", "Wind", "Stream", "Bubble", "Feed", "SynBass1", "SynBass2", "Violin", "Viola", "Cello", "Contrabs", "Trem.Str", "Pizz.Str", "Harp", "Timpani", "Dog", "Horse", "Bird 2", "Syn.Str2", "ChoirAah", "VoiceOoh", "Ghost", "Maou", "Trumpet", "Trombone", "Tuba", "Mute.Trp", "Fr.Horn", "BrasSect", "SynBras1", "SynBras2", "Tel.Dial", "DoorSqek", "Door Slam", "Scratch", "Scratch 2", "WindChm", "Telphon2", "Clarinet", "Piccolo", "Flute", "Recorder", "PanFlute", "Bottle", "Shakhchi", "Whistle", "Ocarina", "CarEngin", "Car Stop", "Car Pass", "CarCrash", "Siren", "Train", "Jetplane", "Starship", "Burst", "Coaster", "SbMarine", "ChoirPad", "BowedPad", "MetalPad", "Halo Pad", "SweepPad", "Laughing", "Scream", "Punch", "Heart", "FootStep", "Goblins", "Echoes", "Sci-Fi", "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bagpipe", "Fiddle", "Shanai", "MchinGun", "LaserGun", "Xplosion", "FireWork", "TaikoDrm", "MelodTom", "Syn.Drum", "RevCymbl", "FretNoiz", "BrthNoiz", "Seashore", "Tweet", "Telphone", "Helicptr", "Applause", "Gunshot" },
  [8064] = { "Dr:umTrx1 A", "Sq:Sn*Arp A", "Sq:Kirmes A", "Sq:Clasic A", "Sq:Seqnza A", "Sq:RytFld A", "Sq:B Luva A", "Sq:ObieSq A", "Sq:Strobe A", "Sq:Fly A", "Sq:Vivldi A", "Sq:Dorian A", "Sc:Rezlne A", "Sc:Todd A", "Sc:Thick A", "Sc:Thin A", "Sc:CutGls A", "Sc:Unvrse A", "Sc:Crispy A", "Sc:FatAne A", "Sc:Brassy A", "Sc:TheWrksA", "Sc:PlsMoD6A", "Sc:Minora A", "Sc:Nble Q A", "Sc:TexSas A", "Sc:Quadra A", "Sc:DstArp A", "Sc:Digitz A", "Sc:Odysey A", "Sc:Doves A", "Fx:Airy A", "Fx:Pardse A", "Fx:Indies A", "Fx:CSpace A", "Fx:Eerie A", "Fx:Ambint A", "Fx:Mornng A", "Fx:CSphre A", "Fx:MagcPd A", "Fx:Tintpa A", "Fx:FlwrArpA", "Fx:K.Scpe A", "Fx:Orient A", "Fx:Omnivr A", "Fx:Whelez A", "Ba:Baslne A", "Ba:Basln2 A", "Ba:Super A", "Ba:Unison A", "Ba:SQ Bas A", "Ba:80sSynBA", "Ba:Pulsbs A", "Ba:SawBas A", "Ba:Fsh303 A", "Ba:SawnOf A", "Ba:CS 01 A", "Ba:Mogue A", "Ba:LeeDa A", "Ba:Howler A", "Ba:KickBs A", "Ba:Sub A", "Ld:Wasp A", "Ld:E no A", "Ld:Fifths A", "Ld:TalkBx A", "Ld:Micrdt A", "Ld:OldMni A", "Ld:NuSync A", "Ld:Clangr A", "Ld:OldRso A", "Ld:Sync A", "Ld:Croma A", "Ld:Bg mUp A", "Ld:Human A", "Ld:BigBob A", "Gt:Firstr A", "Gt:Sevila A", "Pf:CP80 A", "Pf:Woltz1 A", "Pf:Tina A", "Pf:DX Cls A", "Pf:AmbiEp A", "Pf:HipRds A", "Pf:Hard A", "Cp:BelEnd A", "Or:Compct A", "Or:EnsmbleA", "Or:Gospel A", "Or:Drwbrs A", "Or:MissU A", "Or:GlsOrgnA", "Pd:AnglSt A", "Pd:IceFld A", "Pd:Memory A", "Pd:SckWve A", "Pd:Sprite A", "Pd:Trance A", "Pd:White A", "Pd:AirCls A", "Pd:Carpet A", "St:Detrot A", "St:Baroqe A", "St:Octava A", "St:Jupitr A", "St:Strwmn A", "St:Strynx A", "Br:Jump A", "Br:Bronze A", "Br:Xpandr A", "Br:HansUp A", "Br:Prophy A", "Br:Matrix A", "Se:Union A", "Se:Vulcan A", "Se:WStatn A", "Se:Ghost A", "Vo:Choir A", "Vo:Fragle A", "Co:Haendl A", "Co:WshUha A", "Co:Transt A", "Dr:KtB900 A", "Dr:Kit9o9 A", "Dr:Kit8o8 A", "Dr:HipHop A", "Dr:Jungly A", "Dr:Elctrc A" },
  [8065] = { "", "Sq:Sn*Arp B", "Sq:Kirmes B", "Sq:Clasic B", "", "Sq:RytFld B", "Sq:B Luva B", "Sq:ObieSq B", "Sq:Strobe B", "", "Sq:Vivldi B", "Sq:Dorian B", "Sc:Rezlne B", "Sc:Todd B", "", "Sc:Thin B", "Sc:CutGls B", "", "Sc:Crispy B", "", "", "Sc:TheWrksB", "Sc:PlsMoD6B", "Sc:Minora B", "Sc:Nble Q B", "Sc:TexSas B", "Sc:Quadra B", "Sc:DstArp B", "Sc:Digitz B", "Sc:Odysey B", "", "Fx:Airy B", "Fx:Pardse B", "Fx:Indies B", "Fx:CSpace B", "Fx:Eerie B", "", "Fx:Mornng B", "Fx:CSphre B", "Fx:MagcPd B", "Fx:Tintpa B", "", "Fx:K.Scpe B", "Fx:Orient B", "Fx:Omnivr B", "Fx:Whelez B", "", "Ba:Basln2 B", "Ba:Super B", "Ba:Unison B", "Ba:SQ Bas B", "Ba:80sSynBB", "Ba:Pulsbs B", "Ba:SawBas B", "", "Ba:SawnOf B", "Ba:CS 01 B", "Ba:Mogue B", "Ba:LeeDa B", "Ba:Howler B", "Ba:KickBs B", "Ba:Sub B", "Ld:Wasp B", "Ld:E no B", "Ld:Fifths B", "Ld:TalkBx B", "", "Ld:OldMni B", "Ld:NuSync B", "Ld:Clangr B", "Ld:OldRso B", "", "Ld:Croma B", "Ld:Bg mUp B", "Ld:Human B", "Ld:BigBob B", "Gt:Firstr B", "Gt:Sevila B", "", "Pf:Woltz1 B", "Pf:Tina B", "", "Pf:AmbiEp B", "Pf:HipRds B", "Pf:Hard B", "Cp:BelEnd B", "Or:Compct B", "Or:EnsmbleB", "Or:Gospel B", "Or:Drwbrs B", "Or:MissU B", "Or:GlsOrgnB", "Pd:AnglSt B", "Pd:IceFld B", "Pd:Memory B", "Pd:SckWve B", "Pd:Sprite B", "Pd:Trance B", "Pd:White B", "Pd:AirCls B", "Pd:Carpet B", "St:Detrot B", "St:Baroqe B", "St:Octava B", "St:Jupitr B", "St:Strwmn B", "St:Strynx B", "Br:Jump B", "Br:Bronze B", "Br:Xpandr B", "Br:HansUp B", "Br:Prophy B", "Br:Matrix B", "", "Se:Vulcan B", "Se:WStatn B", "Se:Ghost B", "Vo:Choir B", "Vo:Fragle B", "Co:Haendl B", "Co:WshUha B", "Co:Transt B", "Dr:KtB900 B", "Dr:Kit9o9 B", "Dr:Kit8o8 B", "Dr:HipHop B", "Dr:Jungly B", "Dr:Elctrc B" },
  [8066] = { "", "", "Sq:Kirmes C", "", "", "", "", "", "", "", "", "", "Sc:Rezlne C", "", "", "Sc:Thin C", "", "", "", "", "", "", "Sc:PlsMoD6C", "Sc:Minora C", "Sc:Nble Q C", "Sc:TexSas C", "", "", "", "Sc:Odysey C", "", "Fx:Airy C", "Fx:Pardse C", "", "Fx:CSpace C", "", "", "", "Fx:CSphre C", "Fx:MagcPd C", "", "", "Fx:K.Scpe C", "", "Fx:Omnivr C", "Fx:Whelez C", "", "", "", "Ba:Unison C", "", "Ba:80sSynBC", "", "", "", "", "", "", "Ba:LeeDa C", "Ba:Howler C", "Ba:KickBs C", "", "", "", "", "Ld:TalkBx C", "", "", "", "", "", "", "", "Ld:Bg mUp C", "", "", "", "", "", "", "", "", "", "Pf:HipRds C", "", "Cp:BelEnd C", "", "", "", "Or:Drwbrs C", "", "Or:GlsOrgnC", "Pd:AnglSt C", "Pd:IceFld C", "Pd:Memory C", "Pd:SckWve C", "Pd:Sprite C", "", "", "", "Pd:Carpet C", "", "St:Baroqe C", "St:Octava C", "St:Jupitr C", "", "St:Strynx C", "", "", "", "Br:HansUp C", "Br:Prophy C", "Br:Matrix C", "", "", "Se:WStatn C", "Se:Ghost C", "", "", "Co:Haendl C", "Co:WshUha C", "Co:Transt C", "Dr:KtB900 C", "Dr:Kit9o9 C", "Dr:Kit8o8 C", "Dr:HipHop C", "Dr:Jungly C", "Dr:Elctrc C" },
  [8067] = { "", "", "", "", "", "", "", "", "", "", "", "", "Sc:Rezlne D", "", "", "Sc:Thin D", "", "", "", "", "", "", "Sc:PlsMoD6D", "", "", "Sc:TexSas D", "", "", "", "Sc:Odysey D", "", "Fx:Airy D", "", "", "", "", "", "", "", "Fx:MagcPd D", "", "", "", "", "Fx:Omnivr D", "", "", "", "", "", "", "Ba:80sSynBD", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Ld:Bg mUp D", "", "", "", "", "", "", "", "", "", "", "", "Cp:BelEnd D", "", "", "", "Or:Drwbrs D", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "St:Jupitr D", "", "", "", "", "", "Br:HansUp D", "Br:Prophy D", "Br:Matrix D", "", "", "", "Se:Ghost D", "", "", "", "Co:WshUha D", "Co:Transt D", "Dr:KtB900 D", "Dr:Kit9o9 D", "Dr:Kit8o8 D", "Dr:HipHop D", "Dr:Jungly D", "" },
  [8068] = { "Dr:umTrx2 A", "Sq:PanSeq A", "Sq:MC Lne1A", "Sq:MC Lne2A", "Sq:Suprrp A", "Sq:uidgy1 A", "Sq:uidgy2 A", "Sq:HardOn A", "Sq:Pltyps A", "Sq:Cyborg A", "Sq:uelchy A", "Sq:uenza1 A", "Sq:uenza2 A", "Sq:Erased A", "Sq:uareDg A", "Sq:Pulse A", "Co:Ethno A", "Fx:CfiFlt A", "Sq:SprkRn A", "Fx:SnCrny A", "Fx:SwepRn A", "Fx:BrekIt A", "Sc:Syndim A", "Sc:TranCS A", "Sc:Source A", "Sc:ary A", "Sc:EurRal A", "Sc:OwaOwa A", "Sc:Xrayz A", "Pd:ResoCt A", "Sc:Glassy A", "Sc:SynchrdA", "Sc:C Hook A", "Sc:raper A", "Sc:Stab A", "Sc:MonBas A", "Ld:UniLed A", "Ld:4Poles A", "Ld:Cream A", "Ld:ZapLed A", "Ld:TheHok A", "Ld:Trngle A", "Ld:Fuji A", "Ld:MegaHk A", "Ld:Mondo A", "Ld:Marion A", "Ld:Seminl A", "Ld:PureSn A", "Ld:Volfet A", "Ld:Empha A", "Ba:Fashns A", "Ba:Relaxr A", "Ba:ssWire A", "Ba:Wound A", "Ba:Fridge A", "Ba:ssSine A", "Ba:Saw 1 A", "Ba:Saw 2 A", "Ba:Plse25 A", "Ba:Fuzlne A", "Ba:listic A", "Ba:303Wve A", "Ba:Howtzr A", "Ba:Polrze A", "Pf:70 sClvA", "Pf:Woltz2 A", "Pf:DynaRseA", "Pf:Major7 A", "Pf:SwetFn A", "Cp:XyldyneA", "Or:ganMtl A", "Or:YC45D A", "Or:Door A", "Or:ganPrc A", "Or:ganRve A", "Or:Celuli A", "Gt:Tele A", "Gt:EzaGza A", "Br:Obie A", "Br:Cross A", "Br:assTek A", "Br:asHose A", "Br:asFase A", "St:Swpstr A", "St:Vintge A", "St:StrngpdA", "St:Bartok A", "St:Vienna A", "St:FltaFe A", "Pd:MlkyWy A", "Pd:SlvrThwA", "Pd:Solinl A", "Pd:Spooks A", "Pd:Swell A", "Pd:VS Pad A", "Pd:Amber A", "Pd:Aurora A", "Pd:Crystl A", "Pd:Haze A", "Pd:FSOTkyoA", "Fx:Tribal A", "Fx:Plnktn A", "Fx:Ryza A", "Fx:Gaa 99 A", "Fx:Lights A", "Fx:Morf A", "Fx:QSpacs A", "Fx:WatrTy A", "Fx:Galaxy A", "Fx:Triger A", "Fx:Reslve A", "Et:Santur A", "Se:Plasma A", "Se:Lunar A", "Se:ArpDrpsA", "Se:HybriFlA", "Se:BetPhl A", "Se:Organx A", "Se:Varint A", "Se:SkyDmn A", "Vo:ooDooo A", "Vo:xoMono A", "Vo:Tehilm A", "Co:EthnoSpA", "Co:ldHitz A", "Co:ShmStr A", "Co:DistKk A", "Co:EuroKt A" },
  [8069] = { "", "Sq:PanSeq B", "", "Sq:MC Lne2B", "Sq:Suprrp B", "", "", "Sq:HardOn B", "Sq:Pltyps B", "Sq:Cyborg B", "Sq:uelchy B", "", "Sq:uenza2 B", "Sq:Erased B", "Sq:uareDg B", "", "Co:Ethno B", "", "Sq:SprkRn B", "Fx:SnCrny B", "Fx:SwepRn B", "Fx:BrekIt B", "Sc:Syndim B", "Sc:TranCS B", "Sc:Source B", "Sc:ary B", "Sc:EurRal B", "Sc:OwaOwa B", "Sc:Xrayz B", "", "Sc:Glassy B", "Sc:SynchrdB", "Sc:C Hook B", "", "Sc:Stab B", "Sc:MonBas B", "Ld:UniLed B", "Ld:4Poles B", "", "Ld:ZapLed B", "Ld:TheHok B", "Ld:Trngle B", "Ld:Fuji B", "Ld:MegaHk B", "Ld:Mondo B", "Ld:Marion B", "Ld:Seminl B", "Ld:PureSn B", "Ld:Volfet B", "", "Ba:Fashns B", "", "Ba:ssWire B", "", "Ba:Fridge B", "Ba:ssSine B", "", "", "", "", "Ba:listic B", "", "", "", "Pf:70 sClvB", "Pf:Woltz2 B", "Pf:DynaRseB", "Pf:Major7 B", "Pf:SwetFn B", "Cp:XyldyneB", "Or:ganMtl B", "Or:YC45D B", "Or:Door B", "Or:ganPrc B", "Or:ganRve B", "Or:Celuli B", "Gt:Tele B", "Gt:EzaGza B", "", "Br:Cross B", "Br:assTek B", "Br:asHose B", "Br:asFase B", "St:Swpstr B", "", "St:StrngpdB", "St:Bartok B", "St:Vienna B", "", "Pd:MlkyWy B", "Pd:SlvrThwB", "Pd:Solinl B", "Pd:Spooks B", "Pd:Swell B", "Pd:VS Pad B", "", "Pd:Aurora B", "Pd:Crystl B", "Pd:Haze B", "Pd:FSOTkyoB", "Fx:Tribal B", "", "Fx:Ryza B", "Fx:Gaa 99 B", "Fx:Lights B", "Fx:Morf B", "Fx:QSpacs B", "Fx:WatrTy B", "Fx:Galaxy B", "", "Fx:Reslve B", "Et:Santur B", "Se:Plasma B", "Se:Lunar B", "Se:ArpDrpsB", "Se:HybriFlB", "Se:BetPhl B", "Se:Organx B", "Se:Varint B", "Se:SkyDmn B", "Vo:ooDooo B", "Vo:xoMono B", "Vo:Tehilm B", "Co:EthnoSpB", "Co:ldHitz B", "Co:ShmStr B", "Co:DistKk B", "Co:EuroKt C" },
  [8070] = { "", "", "", "", "Sq:Suprrp C", "", "", "Sq:HardOn C", "", "", "", "", "", "", "", "", "Co:Ethno C", "", "", "Fx:SnCrny C", "", "", "Sc:Syndim C", "Sc:TranCS C", "Sc:Source C", "Sc:ary C", "", "", "", "", "Sc:Glassy C", "Sc:SynchrdC", "", "", "", "", "", "Ld:4Poles C", "", "", "Ld:TheHok C", "", "Ld:Fuji C", "Ld:MegaHk C", "", "Ld:Marion C", "Ld:Seminl C", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Pf:DynaRseC", "Pf:Major7 C", "Pf:SwetFn C", "", "Or:ganMtl C", "", "", "Or:ganPrc C", "Or:ganRve C", "", "", "", "", "Br:Cross C", "", "Br:asHose C", "", "St:Swpstr C", "", "", "", "", "", "Pd:MlkyWy C", "", "Pd:Solinl C", "", "", "", "", "Pd:Aurora C", "Pd:Crystl C", "", "", "Fx:Tribal C", "", "Fx:Ryza C", "Fx:Gaa 99 C", "Fx:Lights C", "Fx:Morf C", "Fx:QSpacs C", "Fx:WatrTy C", "", "", "", "Et:Santur C", "", "Se:Lunar C", "", "Se:HybriFlC", "", "Se:Organx C", "", "", "Vo:ooDooo C", "Vo:xoMono C", "", "Co:EthnoSpC", "Co:ldHitz C", "Co:ShmStr C", "Co:DistKk C", "Co:EuroKt D" },
  [8071] = { "", "", "", "", "Sq:Suprrp D", "", "", "Sq:HardOn D", "", "", "", "", "", "", "", "", "Co:Ethno D", "", "", "Fx:SnCrny D", "", "", "", "Sc:TranCS D", "Sc:Source D", "Sc:ary D", "", "", "", "", "", "Sc:SynchrdD", "", "", "", "", "", "", "", "", "", "", "", "Ld:MegaHk D", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Fx:KeslRn A", "", "", "", "Pf:Major7 D", "", "", "Or:ganMtl D", "", "", "Or:ganPrc D", "", "", "", "", "", "Br:Cross D", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Fx:Gaa 99 D", "", "", "Fx:QSpacs D", "", "", "", "", "", "", "Se:Lunar D", "", "", "", "", "", "", "Vo:ooDooo D", "Vo:xoMono D", "", "Co:EthnoSpD", "Co:ldHitz D", "Co:ShmStr D", "", "Dr:LfiAna A" },
  [8072] = { "Pf:Wrltza A", "Pf:Radio A", "Pf:DncePn A", "Cp:AirHtz A", "Cp:TheBig A", "Cp:Vibes A", "Or:Drwbrs2A", "Or:PeeEss A", "Or:PhseOrgA", "Or:DistHm A", "Or:JacjJz A", "Or:Hamond A", "Gt:JazAmp A", "Gt:Chorus A", "Ba:Dubstr A", "Ba:Joda C A", "Ba:sPunch A", "Ba:Marins A", "Ba:Trad A", "Ba:Yeah A", "Ba:Boing A", "Ba:303Vlo A", "Ba:Outlnd A", "Ba:belshs A", "St:ObeStrgA", "St:Phaser A", "St:Dark A", "St:UFourr A", "St:Cars A", "St:Arco A", "Br:Behind A", "Br:OldTnr A", "Br:GoaBrs A", "Br:Punchy A", "Br:Trmpts A", "Br:Sectin A", "Br:Soft A", "Ld:ToClse A", "Ld:EntrnseA", "Ld:MiniQS A", "Ld:Babyln A", "Ld:Thermn A", "Ld:DstShk A", "Ld:AcidLd A", "Ld:BabyLd A", "Ld:MogLed A", "Ld:Raplnd A", "Ld:CryBby A", "Ld:SneMng A", "Ld:TheLog A", "Ld:InYFce A", "Pd:ChoSwp A", "Pd:Synagy A", "Pd:Vangls A", "Pd:ClubUK A", "Pd:Dolfns A", "Pd:Expndr A", "Pd:MayTrk A", "Pd:MonPad A", "Pd:Nebula A", "Pd:RelAnl A", "Pd:Dawn A", "Pd:Satrn5 A", "Fx:KeslRn B", "Fx:Goldlx A", "Fx:Washot A", "Fx:Chilin A", "Fx:Scvnge A", "Fx:Dr Hoo A", "Fx:D Laid A", "Fx:Wisppp A", "Fx:Comdwn A", "Fx:SpceDstA", "Fx:Wowlng A", "Fx:Chiled A", "Fx:Touch A", "Fx:DynaHt A", "Fx:NoseCt A", "Fx:Elctro A", "Fx:Winter A", "Fx:Magicl A", "Fx:JaWble A", "Fx:CSubSb A", "Et:Shaku A", "Et:Koto A", "Et:Bali A", "Et:Ravi A", "Se:Yavin A", "Se:SwptWy A", "Se:Fitzcr A", "Se:HrpGls A", "Se:Inosns A", "Se:Monaco A", "Se:Isoltr A", "Se:E Drpz A", "Se:DeadBl A", "Se:DblWtr A", "Se:Shinng A", "Se:Jungle A", "Se:DevlCt A", "Se:Whsprs A", "Se:ColrMe A", "Sc:Loaded A", "Sc:ATenth A", "Sc:Ugly A", "Sc:FMInte A", "Sc:BigDgi A", "Sc:Monkee A", "Sc:Arpstc A", "Sc:Feelme A", "Sc:C Quor A", "Sc:Strinx A", "Sc:Busy A", "Vo:You A", "Co:Split A", "Co:Str&Pn A", "Co:Fairy A", "Co:EP&StrnA", "Co:Loop A", "Co:Chldrn A", "Co:SynE.P A", "Co:New808 A", "Sq:uirt A", "Sq:Einstn A", "Sq:Estury A", "Sq:Pulshn A", "Dr:HipSet A", "Dr:LfiAna B" },
  [8073] = { "Pf:Wrltza B", "", "", "Cp:AirHtz B", "Cp:TheBig B", "Cp:Vibes B", "Or:Drwbrs2B", "Or:PeeEss B", "Or:PhseOrgB", "Or:DistHm B", "Or:JacjJz B", "Or:Hamond B", "", "Gt:Chorus B", "", "Ba:Joda C B", "Ba:sPunch B", "Ba:Marins B", "", "Ba:Yeah B", "Ba:Boing B", "Ba:303Vlo B", "", "Ba:belshs B", "", "St:Phaser B", "St:Dark B", "St:UFourr B", "St:Cars B", "St:Arco B", "Br:Behind B", "Br:OldTnr B", "Br:GoaBrs B", "Br:Punchy B", "Br:Trmpts B", "Br:Sectin B", "Br:Soft B", "Ld:ToClse B", "Ld:EntrnseB", "Ld:MiniQS B", "Ld:Babyln B", "", "Ld:DstShk B", "Ld:AcidLd B", "Ld:BabyLd B", "Ld:MogLed B", "Ld:Raplnd B", "Ld:CryBby B", "Ld:SneMng B", "Ld:TheLog B", "Ld:InYFce B", "Pd:ChoSwp B", "Pd:Synagy B", "Pd:Vangls B", "Pd:ClubUK B", "Pd:Dolfns B", "Pd:Expndr B", "Pd:MayTrk B", "Pd:MonPad B", "Pd:Nebula B", "Pd:RelAnl B", "Pd:Dawn B", "Pd:Satrn5 B", "Fx:KeslRn C", "Fx:Goldlx B", "Fx:Washot B", "Fx:Chilin B", "", "", "Fx:D Laid B", "Fx:Wisppp B", "Fx:Comdwn B", "Fx:SpceDstB", "", "Fx:Chiled B", "Fx:Touch B", "Fx:DynaHt B", "", "Fx:Elctro B", "Fx:Winter B", "Fx:Magicl B", "Fx:JaWble B", "Fx:CSubSb B", "Et:Shaku B", "Et:Koto B", "Et:Bali B", "", "Se:Yavin B", "Se:SwptWy B", "Se:Fitzcr B", "Se:HrpGls B", "Se:Inosns B", "Se:Monaco B", "Se:Isoltr B", "", "Se:DeadBl B", "Se:DblWtr B", "Se:Shinng B", "Se:Jungle B", "Se:DevlCt B", "Se:Whsprs B", "Se:ColrMe B", "Sc:Loaded B", "Sc:ATenth B", "Sc:Ugly B", "Sc:FMInte B", "Sc:BigDgi B", "Sc:Monkee B", "Sc:Arpstc B", "Sc:Feelme B", "", "", "", "Vo:You B", "Co:Split B", "Co:Str&Pn B", "Co:Fairy B", "Co:EP&StrnB", "Co:Loop B", "Co:Chldrn B", "Co:SynE.P B", "Co:New808 B", "Sq:uirt B", "Sq:Einstn B", "Sq:Estury B", "Sq:Pulshn B", "Dr:HipSet B", "" },
  [8074] = { "", "", "", "", "", "", "Or:Drwbrs2C", "Or:PeeEss C", "", "", "", "Or:Hamond C", "", "Gt:Chorus C", "", "", "Ba:sPunch C", "", "", "Ba:Yeah C", "", "", "", "Ba:belshs C", "", "", "St:Dark C", "St:UFourr C", "St:Cars C", "St:Arco C", "", "Br:OldTnr C", "", "", "Br:Trmpts C", "Br:Sectin C", "Br:Soft C", "Ld:ToClse C", "", "", "Ld:Babyln C", "", "Ld:DstShk C", "", "Ld:BabyLd C", "", "", "", "", "", "Ld:InYFce C", "", "", "", "Pd:ClubUK C", "", "Pd:Expndr C", "", "Pd:MonPad C", "Pd:Nebula C", "Pd:RelAnl C", "", "", "Fx:KeslRn D", "Fx:Goldlx C", "Fx:Washot C", "", "", "", "", "", "", "Fx:SpceDstC", "", "", "Fx:Touch C", "Fx:DynaHt C", "", "Fx:Elctro C", "Fx:Winter C", "Fx:Magicl C", "", "", "Et:Shaku C", "", "", "", "Se:Yavin C", "", "", "Se:HrpGls C", "", "Se:Monaco C", "", "", "", "", "", "Se:Jungle C", "Se:DevlCt C", "Se:Whsprs C", "", "", "", "", "", "Sc:BigDgi C", "", "Sc:Arpstc C", "Sc:Feelme C", "", "", "", "", "Co:Split C", "Co:Str&Pn C", "", "", "Co:Loop C", "Co:Chldrn C", "", "Co:New808 C", "", "Sq:Einstn C", "", "", "Dr:HipSet C", "" },
  [8075] = { "", "", "", "", "", "", "Or:Drwbrs2D", "Or:PeeEss D", "", "", "", "", "", "Gt:Chorus D", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "St:Arco D", "", "", "", "", "", "Br:Sectin D", "Br:Soft D", "", "", "", "", "", "Ld:DstShk D", "", "", "", "", "", "", "", "", "", "", "", "Pd:ClubUK D", "", "", "", "Pd:MonPad D", "", "", "", "", "", "", "Fx:Washot D", "", "", "", "", "", "", "", "", "", "Fx:Touch D", "", "", "Fx:Elctro D", "Fx:Winter D", "Fx:Magicl D", "", "", "", "", "", "", "", "", "", "Se:HrpGls D", "", "", "", "", "", "", "", "Se:Jungle D", "", "Se:Whsprs D", "", "", "", "", "", "", "", "Sc:Arpstc D", "Sc:Feelme D", "", "", "", "", "Co:Split D", "", "", "", "Co:Loop D", "", "", "Co:New808 D", "", "Sq:Einstn D", "", "", "Dr:HipSet D", "" },
  [8076] = { "Dr:TechKt A", "Dr:ElctrKtA", "Dr:JnglKt A", "Dr:HpHpKt A", "Dr:8o8Kit A", "Dr:9o9Kit A" }
}


local effectParamTables = {
  -- LFO Frequency
  { "0.00", "0.04", "0.08", "0.13", "0.17", "0.21", "0.25", "0.29", "0.34", "0.38", "0.42", "0.46", "0.51", "0.55", "0.59", "0.63", "0.67", "0.72", "0.76", "0.80", "0.84", "0.88", "0.93", "0.97", "1.01", "1.05", "1.09", "1.14", "1.18", "1.22", "1.26", "1.30", "1.35", "1.39", "1.43", "1.47", "1.51", "1.56", "1.60", "1.64", "1.68", "1.72", "1.77", "1.81", "1.85", "1.89", "1.94", "1.98", "2.02", "2.06", "2.10", "2.15", "2.19", "2.23", "2.27", "2.31", "2.36", "2.40", "2.44", "2.48", "2.52", "2.57", "2.61", "2.65", "2.69", "2.78", "2.86", "2.94", "3.03", "3.11", "3.20", "3.28", "3.37", "3.45", "3.53", "3.62", "3.70", "3.87", "4.04", "4.21", "4.37", "4.54", "4.71", "4.88", "5.05", "5.22", "5.38", "5.55", "5.72", "6.06", "6.39", "6.73", "7.07", "7.40", "7.74", "8.08", "8.41", "8.75", "9.08", "9.42", "9.76", "10.10", "10.80", "11.40", "12.10", "12.80", "13.50", "14.10", "14.80", "15.50", "16.20", "16.80", "17.50", "18.20", "19.50", "20.90", "22.20", "23.60", "24.90", "26.20", "27.60", "28.90", "30.30", "31.60", "33.00", "34.30", "37.00", "39.70" },
  -- Modulation Delay Offset
  { "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3.0", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4.0", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5.0", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6.0", "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7.0", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "8.0", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "9.0", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10.0", "11.1", "12.2", "13.3", "14.4", "15.5", "17.1", "18.6", "20.2", "21.8", "23.3", "24.9", "26.5", "28.0", "29.6", "31.2", "32.8", "34.3", "35.9", "37.5", "39.0", "40.6", "42.2", "43.7", "45.3", "46.9", "48.4", "50.0" },
  -- EQ Frequency
  { "20", "22", "25", "28", "32", "36", "40", "45", "50", "56", "63", "70", "80", "90", "100", "110", "125", "140", "160", "180", "200", "225", "250", "280", "315", "355", "400", "450", "500", "560", "630", "700", "800", "900", "1.0k", "1.1k", "1.2k", "1.4k", "1.6k", "1.8k", "2.0k", "2.2k", "2.5k", "2.8k", "3.2k", "3.6k", "4.0k", "4.5k", "5.0k", "5.6k", "6.3k", "7.0k", "8.0k", "9.0k", "10.0k", "11.0k", "12.0k", "14.0k", "16.0k", "18.0k", "20.0k" },
  -- Reverb Time
  { "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3.0", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4.0", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5.0", "5.5", "6.0", "6.5", "7.0", "7.5", "8.0", "8.5", "9.0", "9.5", "10.0", "11.0", "12.0", "13.0", "14.0", "15.0", "16.0", "17.0", "18.0", "19.0", "20.0", "25.0", "30.0" },
  -- Delay Time (200ms)
  { "0.1", "1.7", "3.2", "4.8", "6.4", "8.0", "9.5", "11.1", "12.7", "14.3", "15.8", "17.4", "19.0", "20.6", "22.1", "23.7", "25.3", "26.9", "28.4", "30.0", "31.6", "33.2", "34.7", "36.3", "37.9", "39.5", "41.0", "42.6", "44.2", "45.7", "47.3", "48.9", "50.5", "52.0", "53.6", "55.2", "56.8", "58.3", "59.9", "61.5", "63.1", "64.6", "66.2", "67.8", "69.4", "70.9", "72.5", "74.1", "75.7", "77.2", "78.8", "80.4", "81.9", "83.5", "85.1", "86.7", "88.2", "89.8", "91.4", "93.0", "94.5", "96.1", "97.7", "99.3", "100.8", "102.4", "104.0", "105.6", "107.1", "108.7", "110.3", "111.9", "113.4", "115.0", "116.6", "118.2", "119.7", "121.3", "122.9", "124.4", "126.0", "127.6", "129.2", "130.7", "132.3", "133.9", "135.5", "137.0", "138.6", "140.2", "141.8", "143.3", "144.9", "146.5", "148.1", "149.6", "151.2", "152.8", "154.4", "155.9", "157.5", "159.1", "160.6", "162.2", "163.8", "165.4", "166.9", "168.5", "170.1", "171.7", "173.2", "174.8", "176.4", "178.0", "179.5", "181.1", "182.7", "184.3", "185.8", "187.4", "189.0", "190.6", "192.1", "193.7", "195.3", "196.9", "198.4", "200.0" },
  -- Room Size
  { "0.1", "0.3", "0.4", "0.6", "0.7", "0.9", "1.0", "1.2", "1.4", "1.5", "1.7", "1.8", "2.0", "2.1", "2.3", "2.5", "2.6", "2.8", "2.9", "3.1", "3.2", "3.4", "3.5", "3.7", "3.9", "4.0", "4.2", "4.3", "4.5", "4.6", "4.8", "5.0", "5.1", "5.3", "5.4", "5.6", "5.7", "5.9", "6.1", "6.2", "6.4", "6.5", "6.7", "6.8", "7.0" },
  -- Delay Time (400ms)
  { "0.1", "3.2", "6.4", "9.5", "12.7", "15.8", "19.0", "22.1", "25.3", "28.4", "31.6", "34.7", "37.9", "41.0", "44.2", "47.3", "50.5", "53.6", "56.8", "59.9", "63.1", "66.2", "69.4", "72.5", "75.7", "78.8", "82.0", "85.1", "88.3", "91.4", "94.6", "97.7", "100.9", "104.0", "107.2", "110.3", "113.5", "116.6", "119.8", "122.9", "126.1", "129.2", "132.4", "135.5", "138.6", "141.8", "144.9", "148.1", "151.2", "154.4", "157.5", "160.7", "163.8", "167.0", "170.1", "173.3", "176.4", "179.6", "182.7", "185.9", "189.0", "192.2", "195.3", "198.5", "201.6", "204.8", "207.9", "211.1", "214.2", "217.4", "220.5", "223.7", "226.8", "230.0", "233.1", "236.3", "239.4", "242.6", "245.7", "248.9", "252.0", "255.2", "258.3", "261.5", "264.6", "267.7", "270.9", "274.0", "277.2", "280.3", "283.5", "286.6", "289.8", "292.9", "296.1", "299.2", "302.4", "305.5", "308.7", "311.8", "315.0", "318.1", "321.3", "324.4", "327.6", "330.7", "333.9", "337.0", "340.2", "343.3", "346.5", "349.6", "352.8", "355.9", "359.1", "362.2", "365.4", "368.5", "371.7", "374.8", "378.0", "381.1", "384.3", "387.4", "390.6", "393.7", "396.9", "400.0" },
  -- Reverb Width/Depth/Height
  { "0.5", "0.8", "1.0", "1.3", "1.5", "1.8", "2.0", "2.3", "2.6", "2.8", "3.1", "3.3", "3.6", "3.9", "4.1", "4.4", "4.6", "4.9", "5.2", "5.4", "5.7", "5.9", "6.2", "6.5", "6.7", "7.0", "7.2", "7.5", "7.8", "8.0", "8.3", "8.6", "8.8", "9.1", "9.4", "9.6", "9.9", "10.2", "10.4", "10.7", "11.0", "11.2", "11.5", "11.8", "12.1", "12.3", "12.6", "12.9", "13.1", "13.4", "13.7", "14.0", "14.2", "14.5", "14.8", "15.1", "15.4", "15.6", "15.9", "16.2", "16.5", "16.8", "17.1", "17.3", "17.6", "17.9", "18.2", "18.5", "18.8", "19.1", "19.4", "19.7", "20.0", "20.2", "20.5", "20.8", "21.1", "21.4", "21.7", "22.0", "22.4", "22.7", "23.0", "23.3", "23.6", "23.9", "24.2", "24.5", "24.9", "25.2", "25.5", "25.8", "26.1", "26.5", "26.8", "27.1", "27.5", "27.8", "28.1", "28.5", "28.8", "29.2", "29.5", "29.9", "30.2" },
  -- Cutoff Frequency Offset
  { "50", "55", "60", "66", "72", "80", "86", "94", "100", "110", "120", "130", "140", "150", "162", "174", "186", "200", "215", "230", "245", "260", "280", "300", "315", "335", "355", "380", "400", "425", "450", "475", "500", "530", "560", "590", "620", "650", "680", "720", "760", "800", "840", "880", "920", "960", "1.00k", "1.05k", "1.10k", "1.15k", "1.20k", "1.26k", "1.32k", "1.38k", "1.43k", "1.50k", "1.56k", "1.62k", "1.69k", "1.76k", "1.83k", "1.90k", "1.98k", "2.06k", "2.14k", "2.22k", "2.31k", "2.40k", "2.49k", "2.58k", "2.67k", "2.77k", "2.87k", "2.97k", "3.08k", "3.19k", "3.30k", "3.41k", "3.53k", "3.65k", "3.77k", "3.90k", "4.03k", "4.16k", "4.29k", "4.43k", "4.57k", "4.72k", "4.87k", "5.02k", "5.18k", "5.34k", "5.50k", "5.67k", "5.84k", "6.02k", "6.20k", "6.38k", "6.56k", "6.75k", "6.95k", "7.15k", "7.35k", "7.56k", "7.78k", "8.00k", "8.22k", "8.44k", "8.67k", "8.90k", "9.14k", "9.38k", "9.63k", "9.90k", "10.2k", "10.4k", "10.7k", "10.9k", "11.2k", "11.5k", "11.8k", "12.1k", "12.4k", "12.7k", "13.0k", "13.3k", "13.7k", "14.0k" },
  -- Dry/wet
  { "D63>W", "D62>W", "D61>W", "D60>W", "D59>W", "D58>W", "D57>W", "D56>W", "D55>W", "D54>W", "D53>W", "D52>W", "D51>W", "D50>W", "D49>W", "D48>W", "D47>W", "D46>W", "D45>W", "D44>W", "D43>W", "D42>W", "D41>W", "D40>W", "D39>W", "D38>W", "D37>W", "D36>W", "D35>W", "D34>W", "D33>W", "D32>W", "D31>W", "D30>W", "D29>W", "D28>W", "D27>W", "D26>W", "D25>W", "D24>W", "D23>W", "D22>W", "D21>W", "D20>W", "D19>W", "D18>W", "D17>W", "D16>W", "D15>W", "D14>W", "D13>W", "D12>W", "D11>W", "D10>W", "D9>W", "D8>W", "D7>W", "D6>W", "D5>W", "D4>W", "D3>W", "D2>W", "D1>W", "D-W", "D<W1", "D<W2", "D<W3", "D<W4", "D<W5", "D<W6", "D<W7", "D<W8", "D<W9", "D<W10", "D<W11", "D<W12", "D<W13", "D<W14", "D<W15", "D<W16", "D<W17", "D<W18", "D<W19", "D<W20", "D<W21", "D<W22", "D<W23", "D<W24", "D<W25", "D<W26", "D<W27", "D<W28", "D<W29", "D<W30", "D<W31", "D<W32", "D<W33", "D<W34", "D<W35", "D<W36", "D<W37", "D<W38", "D<W39", "D<W40", "D<W41", "D<W42", "D<W43", "D<W44", "D<W45", "D<W46", "D<W47", "D<W48", "D<W49", "D<W50", "D<W51", "D<W52", "D<W53", "D<W54", "D<W55", "D<W56", "D<W57", "D<W58", "D<W59", "D<W60", "D<W61", "D<W62", "D<W63" },
  -- Er/Rev Balance
  { "E63>R", "E62>R", "E61>R", "E60>R", "E59>R", "E58>R", "E57>R", "E56>R", "E55>R", "E54>R", "E53>R", "E52>R", "E51>R", "E50>R", "E49>R", "E48>R", "E47>R", "E46>R", "E45>R", "E44>R", "E43>R", "E42>R", "E41>R", "E40>R", "E39>R", "E38>R", "E37>R", "E36>R", "E35>R", "E34>R", "E33>R", "E32>R", "E31>R", "E30>R", "E29>R", "E28>R", "E27>R", "E26>R", "E25>R", "E24>R", "E23>R", "E22>R", "E21>R", "E20>R", "E19>R", "E18>R", "E17>R", "E16>R", "E15>R", "E14>R", "E13>R", "E12>R", "E11>R", "E10>R", "E9>R", "E8>R", "E7>R", "E6>R", "E5>R", "E4>R", "E3>R", "E2>R", "E1>R", "E-R", "E<R1", "E<R2", "E<R3", "E<R4", "E<R5", "E<R6", "E<R7", "E<R8", "E<R9", "E<R10", "E<R11", "E<R12", "E<R13", "E<R14", "E<R15", "E<R16", "E<R17", "E<R18", "E<R19", "E<R20", "E<R21", "E<R22", "E<R23", "E<R24", "E<R25", "E<R26", "E<R27", "E<R28", "E<R29", "E<R30", "E<R31", "E<R32", "E<R33", "E<R34", "E<R35", "E<R36", "E<R37", "E<R38", "E<R39", "E<R40", "E<R41", "E<R42", "E<R43", "E<R44", "E<R45", "E<R46", "E<R47", "E<R48", "E<R49", "E<R50", "E<R51", "E<R52", "E<R53", "E<R54", "E<R55", "E<R56", "E<R57", "E<R58", "E<R59", "E<R60", "E<R61", "E<R62", "E<R63" },
  -- Input select
  { "L", "R", "L&R" },
  -- High Damp
  { "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", },
  -- Input Mode / Diffusion
  { "Mono", "Stereo" },
  -- LFO Phase Difference
  { "-192", "-189", "-186", "-183", "-180", "-177", "-174", "-171", "-168", "-165", "-162", "-159", "-156", "-153", "-150", "-147", "-144", "-141", "-138", "-135", "-132", "-129", "-126", "-123", "-120", "-117", "-114", "-111", "-108", "-105", "-102", "-99", "-96", "-93", "-90", "-87", "-84", "-81", "-78", "-75", "-72", "-69", "-66", "-63", "-60", "-57", "-54", "-51", "-48", "-45", "-42", "-39", "-36", "-33", "-30", "-27", "-24", "-21", "-18", "-15", "-12", "-9", "-6", "-3", "0", "3", "6", "9", "12", "15", "18", "21", "24", "27", "30", "33", "36", "39", "42", "45", "48", "51", "54", "57", "60", "63", "66", "69", "72", "75", "78", "81", "84", "87", "90", "93", "96", "99", "102", "105", "108", "111", "114", "117", "120", "123", "126", "129", "132", "135", "138", "141", "144", "147", "150", "153", "156", "159", "162", "165", "168", "171", "174", "177", "180" },
  -- PAN Direction
  { "L<->R", "L->R", "L<-R", "Lturn", "Rturn", "L/R" },
  -- EQ Mid Width
  { "1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3.0", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4.0", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5.0", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6.0", "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7.0", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "8.0", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "9.0", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10.0", "10.1", "10.2", "10.3", "10.4", "10.5", "10.6", "10.7", "10.8", "10.9", "11.0", "11.1", "11.2", "11.3", "11.4", "11.5", "11.6", "11.7", "11.8", "11.9", "12.0" },
  -- AMP Type
  { "Off", "Stack", "Combo", "Tube" },
  -- Early Ref Type
  { "S-H", "L-H", "Rdm", "Rvs", "Plt", "Spr" },
  -- Gate Reverb Type
  { "TypeA", "TypeB" }
}

local reverbParams = { "Reverb Time:4:0:69:", "Diffusion::0:10:", "Initial Delay:5:0:63:", "HPF Cutoff:3:0:52:", "LPF Cutoff:3:34:60:", "::::", "::::", "::::", "::::", "Dry/Wet:10:1:127:", "Rev Delay:5:0:63:", "Density::0:3:", "Er/Rev Bal:11:1:127:", "::::", "Fdbk Lvl::-63:63:64", "::::" }
local delayLCRParams = { "Lch Delay::1:7150:", "Rch Delay::1:7150:", "Cch Delay::1:7150:", "Fdbk Delay::1:7150:", "Fdbk Lvl::-63:63:64", "Cch Level::0:127:", "High Damp:13:1:10:", "::::", "::::", "Dry/Wet:10:1:127:", "::::", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64" }
local delayLRParams = { "Lch Delay::1:7150:", "Rch Delay::1:7150:", "Fdbk Delay 1::1:7150:", "Fdbk Delay 2::1:7150:", "Fdbk Lvl::-63:63:64", "High Damp:13:1:10:", "::::", "::::", "::::", "Dry/Wet:10:1:127:", "::::", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64" }
local echoParams = { "Lch Delay1::1:3550:", "Lch Fdbk Lvl::-63:63:64", "Rch Delay1::1:3550:", "Rch Fdbk Lvl::-63:63:64", "High Damp:13:1:10:", "Lch Delay2::1:3550:", "Rch Delay2::1:3550:", "Delay2 Level::0:127:", "::::", "Dry/Wet:10:1:127:", "::::", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64" }
local crossDelayParams = { "L->R Delay::1:3550:", "R->L Delay::1:3550:", "Fdbk Lvl::-63:63:64", "Input Select:12:0:2:1", "High Damp:13:1:10:", "::::", "::::", "::::", "::::", "Dry/Wet:10:1:127:", "::::", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64" }
local earlyReflectionsParams = { "Type:19:0:5:1", "Room Size:6:0:44:", "Diffusion::0:10:", "Initial Delay:5:0:63:", "Fdbk Lvl::-63:63:64", "HPF Cutoff:3:0:52:", "LPF Cutoff:3:34:60:", "::::", "::::", "Dry/Wet:10:1:127:", "Liveness::0:10:", "Density::0:3:", "High Damp:13:1:10:", "::::", "::::", "::::" }
local gatedReverbParams = { "Type:20:0:1:1", "Room Size:6:0:44:1", "Diffusion::0:10:", "Initial Delay:5:0:63:1", "Fdbk Lvl::-63:63:64", "HPF Cutoff:3:0:52:1", "LPF Cutoff:3:34:60:1", "::::", "::::", "Dry/Wet:10:1:127:", "Liveness::0:10:", "Density::0:3:", "High Damp:13:1:10:", "::::", "::::", "::::", }
local whiteRoomParams = { "Reverb Time:4:0:69:", "Diffusion::0:10:", "Initial Delay:5:0:63:", "HPF Cutoff:3:0:52:", "LPF Cutoff:3:34:60:", "Width:8:0:37:", "Heigt:8:0:73:", "Depth:8:0:104:", "Wall Vary::0:30:", "Dry/Wet:10:1:127:", "Rev Delay:5:0:63:", "Density::0:3:", "Er/Rev Bal:11:1:127:", "::::", "Fdbk Lvl::-63:63:64", "::::" }
local karaokeParams = { "Delay Time:7:0:127:", "Fdbk Lvl::-63:63:64", "HPF Cutoff:3:0:52:1", "LPF Cutoff:3:34:60:", "::::", "::::", "::::", "::::", "::::", "Dry/Wet:10:1:127:", "::::", "::::", "::::", "::::", "::::", "::::", }
local chorusParams = { "LFO Freq:1:0:127:", "LFO PM Depth::0:127:", "Fdbk Lvl::-63:63:64", "Delay Offset:2:0:127:", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "Dry/Wet:10:1:127:", "::::", "::::", "::::", "::::", "Input Mode:14:0:1:", "::::", }
local flangerParams = { "LFO Freq:1:0:127:", "LFO Depth::0:127:", "Fdbk Lvl::-63:63:64", "Delay Offset:2:0:63:", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "Dry/Wet:10:1:127:", "::::", "::::", "::::", "LFO Ph Diff:15:4:124:", "::::", "::::", }
local symphonicParams = { "LFO Freq:1:0:127:", "LFO Depth::0:127:", "Delay Offset:2:0:127:", "::::", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "Dry/Wet:10:1:127:", "::::", "::::", "::::", "::::", "::::", "::::", }
local rotarySpkrParams = { "LFO Freq:1:0:127:", "LFO Depth::0:127:", "::::", "::::", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "Dry/Wet:10:1:127:", "::::", "::::", "::::", "::::", "::::", "::::", }
local tremoloParams = { "LFO Freq:1:0:127:", "AM Depth::0:127:", "PM Depth::0:127:", "::::", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "::::", "::::", "::::", "::::", "LFO Ph Diff:15:4:124:", "Input Mode:14:0:1:", "::::", }
local autoPanParams = { "LFO Freq:1:0:127:", "L/R Depth::0:127:", "F/R Depth::0:127:", "Pan Dir:16:0:5:", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "::::", "::::", "::::", "::::", "::::", "::::", "::::", }
local phaserParams = { "LFO Freq:1:0:127:", "LFO Depth::0:127:", "Phase ShftOffs::0:127:", "Fdbk Lvl::-63:63:64", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "Dry/Wet:10:1:127:", "Stage::3:10:", "Diffusion:14:0:1:", "LFO Ph Diff:15:4:124:", "::::", "::::", "::::", }
local distortionParams = { "Drive::0:127:", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "LPF Cutoff:3:34:60:", "Output Level::0:127:", "::::", "Mid Freq:3:28:54:", "Mid Gain::-12:12:64", "Mid Width:17:10:120:10", "Dry/Wet:10:1:127:", "Edge::0:127:", "::::", "::::", "::::", "::::", "::::", }
local ampSimulatorParams = { "Drive::0:127:", "AMP Type:18:0:3:", "LPF Cutoff:3:34:60:", "Output Level::0:127:", "::::", "::::", "::::", "::::", "::::", "Dry/Wet:10:1:127:", "Edge::0:127:", "::::", "::::", "::::", "::::", "::::", }
local threeBandEqParams = { "Low Gain::-12:12:64", "Mid Freq:3:28:54:", "Mid Gain::-12:12:64", "Mid Width:17:10:120:10", "High Gain::-12:12:64", "Low Freq:3:8:40:", "High Freq:3:28:58:", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", }
local twoBandEqParams = { "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", }
local autoWahParams = { "LFO Freq:1:0:127:", "LFO Depth::0:127:", "Cutoff Freq:9:0:127:", "Resonance:17:10:120:10", "::::", "Low Freq:3:8:40:", "Low Gain::-12:12:64", "High Freq:3:28:58:", "High Gain::-12:12:64", "Dry/Wet:10:1:127:", "::::", "::::", "::::", "::::", "::::", "::::", }
local thruParams = { "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", "::::", }

local effectParams = {
  ['0x01'] = reverbParams,
  ['0x02'] = reverbParams,
  ['0x03'] = reverbParams,
  ['0x04'] = reverbParams,
  ['0x05'] = delayLCRParams,
  ['0x06'] = delayLRParams,
  ['0x07'] = echoParams,
  ['0x08'] = crossDelayParams,
  ['0x09'] = earlyReflectionsParams,
  ['0x0A'] = gatedReverbParams,
  ['0x0B'] = gatedReverbParams,
  ['0x10'] = whiteRoomParams,
  ['0x11'] = whiteRoomParams,
  ['0x13'] = whiteRoomParams,
  ['0x14'] = karaokeParams,
  ['0x40'] = thruParams,
  ['0x41'] = chorusParams,
  ['0x42'] = chorusParams,
  ['0x43'] = flangerParams,
  ['0x44'] = symphonicParams,
  ['0x45'] = rotarySpkrParams,
  ['0x46'] = tremoloParams,
  ['0x47'] = autoPanParams,
  ['0x48'] = phaserParams,
  ['0x49'] = distortionParams,
  ['0x4A'] = distortionParams,
  ['0x4B'] = ampSimulatorParams,
  ['0x4C'] = threeBandEqParams,
  ['0x4D'] = twoBandEqParams,
  ['0x4E'] = autoWahParams
}

local midiMessageTimerIndex = 1001

local mappedParams = {
  [66] = true,
  [68] = true,
  [70] = true,
  [118] = true,
  [170] = true,
  [222] = true,
  [274] = true
}

local variIndexes = { 1, 2, 3, 4, 5, 10 }

local getSliderContentFromSequence = function(min, max)
  local contents = ""
  for i = min, max do
    contents = string.format("%s\n%d", contents, i)
  end
  return contents
end

local getSliderContentFromArray = function(array)
  local contents = ""
  for i = 1, table.getn(array) do
    contents = string.format("%s\n%s", contents, array[i])
  end
  return contents
end

local onMidiMessageTimeout = function()
  -- Clear message queue
  midiSendQueue = {}
  -- Stop timer
  timer:stopTimer(midiMessageTimerIndex)

  AlertWindow.showMessageBox(AlertWindow.WarningIcon, "MIDI Timeout", "No MIDI response from CS1x received", "OK")
end

local getVoiceContents = function(values)
  local retval = ""
  for i = 1, table.getn(values) do
    local s = values[i]
    if s ~= '' then
      if retval == '' then
        retval = string.format("%s=%d", s, i - 1)
      else
        retval = string.format("%s\n%s=%d", retval, s, i - 1)
      end
    end
  end
  return retval
end

YamahaCS1xController = {}
YamahaCS1xController.__index = YamahaCS1xController

setmetatable(YamahaCS1xController, {
  __index = DefaultControllerBase, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#YamahaCS1xController] _init
--
function YamahaCS1xController:_init()
  DefaultControllerBase._init(self, SinglePerformanceSize, PerformanceBankSize, YamahaCS1xPatch, YamahaCS1xBank)
  self.midiSendQueue = {}
  self.receivedMidiData = {}
end

function YamahaCS1xController:loadData(data, mute)
  mute = mute or false
  local midiSize = data:getSize()
  if midiSize == self.bankSize then
    local status, bank = pcall(self.bankPointer, data)
    if status then
      self:assignBank(bank)
    else
      log:warn(cutils.getErrorMessage(bank))
      utils.warnWindow ("Load Bank", cutils.getErrorMessage(bank))
      return
    end
  elseif midiSize == self.voiceSize or midiSize == self.voiceSize + 2 then
    local status, patch = pcall(self.standAlonePatchPointer, data)
    if not status then
      log:warn(cutils.getErrorMessage(patch))
      utils.warnWindow ("Load Patch", cutils.getErrorMessage(patch))
      return
    end
    -- Assign values
    self:p2v(patch, mute)
  else
    error(string.format("The loaded file does not contain valid sysex data: %s", data:toHexString(1)))
    return
  end
end

---
-- @function [parent=#YamahaCS1xController] p2v
--
-- This method assigns modulators from a patch
-- to all modulators in the panel
function YamahaCS1xController:p2v(patch, mute)
  mute = mute or false
  self:toggleVisibility("singlePatchName", false)
  self:toggleVisibility("processingLabel", true)
  for i = 1, self.voiceSize do -- gets the voice parameter values
    local mod = self:getModulatorByCustomIndex(i)
--    log:info("%d = %.2X", i, patch:getValue(i))
    if mod ~= nil then
      local value = patch:getValue(i)
      if mappedParams[i] then
        self:setValueByCustomIndexMapped(i, value, mute)
      else
        self:setValueByCustomIndex(i, value, mute)
      end
    elseif i == 54 then
      local value = patch:getValue(i)
      local modulo = value % 3
      self:setValueByCustomName("arpegOn", modulo == 0 and 0 or 1)
      self:setValueByCustomName("arpegHold", modulo == 2 and 1 or 0)
      self:setValueByCustomName("arpegSplit", value < 3 and 1 or 0)
    end
  end
  self:setText("singlePatchName", patch:getPatchName())
  self:toggleVisibility("processingLabel", false)
  self:toggleVisibility("singlePatchName", true)
end

---
-- @function [parent=#YamahaCS1xController] v2p
--
-- This method assembles the param values from
-- all modulators and stores them in a patch
function YamahaCS1xController:v2p(patch)
  -- run through all modulators and fetch their value
  for i = 1, self.voiceSize do
    local mod = self:getModulatorByCustomIndex(i)
    if mod ~= nil then
      local value = mod:getValue()
      if mappedParams[i] then
        value = mod:getValueMapped()
      end
      patch:setValue(i, mod:getValue())
    elseif i == 54 then
      local arpegOn = self:getValue("arpegOn")
      local arpegHold = self:getValue("arpegHold")
      local arpegSplit = self:getValue("arpegSplit")
      local value = 0
      if arpegSplit == 1 then value = 3 end
      if arpegOn == 1 then value = value + 1 end
      if arpegHold == 1 then value = value + 1 end
      patch:setValue(i, value)
    end
  end

  patch:setPatchName(self:getText("singlePatchName"))
end

function YamahaCS1xController:onArpegValueChanged(mod, value)
  local arpegOn = self:getValue("arpegOn")
  local arpegHold = self:getValue("arpegHold")
  local arpegSplit = self:getValue("arpegSplit")
  local value = 0
  if arpegOn == 1 then value = 1 end
  if arpegHold == 1 then value = value * 2 end
  if arpegSplit == 0 then value = value + 4 end
  self:sendMidiMessage(CS1xArpegMsg(value))
end

---
-- @function [parent=#YamahaCS1xController] onEffectSelectorChanged
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function YamahaCS1xController:onEffectSelectorChanged(mod, value)
  local effectValue = mod:getValue()
  local layers = { "REVERB", "CHORUS", "VARIATION" }
  for k,v in pairs(layers) do
    self:toggleLayerVisibility(v, false)
  end
  self:toggleLayerVisibility(layers[effectValue + 1], true)
end

---
-- @function [parent=#YamahaCS1xController] onEffectTypeChanged
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function YamahaCS1xController:onEffectTypeChanged(mod, value)
  local effectIndex = mod:getValueMapped() / 128
  local effectParamList = thruParams
  if effectIndex > 0 then
    effectParamList = effectParams[string.format("0x%.2X", effectIndex)]
  end
  local groupName = mod:getProperty("modulatorCustomNameGroup")

  for i = 1, 6 do
    local index = variIndexes[i]
    local modName = string.format("%s%d", groupName, index)
    local paramValues = lutils.split(effectParamList[index], ":")
    if table.getn(paramValues) ~= 5 then
      error(string.format("Invalid param value string '%s'", effectParamList[index]))
    end

    local name = paramValues[1]
    self:toggleVisibility(modName, name ~= "")
    self:setVisibleName(modName, name)
    if name ~= "" then
      local dataArrayIndex = paramValues[2]
      local min = paramValues[3]
      local max = paramValues[4]
      local offset = paramValues[5]

      local sliderContents = ""
      if dataArrayIndex == "" then
        sliderContents = getSliderContentFromSequence(min, max)
      else
        sliderContents = getSliderContentFromArray(effectParamTables[tonumber(dataArrayIndex)])
      end

      self:setFixedSliderContent(modName, sliderContents)
    end
  end
end

---
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function YamahaCS1xController:onFilterParamChanged(mod, value)
  self:getModulatorByCustomName(string.format("%sL", mod:getProperty("modulatorCustomName"))):setValue(value - 64, true)
end

---
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function YamahaCS1xController:onVoiceBankChange(mod, value)
  --  -- Calculate values
  local mappedValue = mod:getValueMapped()
  if mappedValue > 8192 then
    mappedValue = value
  end
  --  local msb = math.floor(mappedValue / 128)
  --  local lsb = mappedValue - msb
  --
  --  -- Send midi message
  --  local paramValues = assembleValues()
  --  local splitParamValues = splitMessages(paramValues, 7)
  --  local midiMsg = splitParamValues[4]
  --  local data = midiMsg:getData()
  --  data:setByte(9, msb)
  --  data:setByte(10, lsb)
  --  panel:sendMidi(midiMsg, 0)

  -- Update voice selector
  local voiceValues = voiceBanks[mappedValue]
  local voiceContents = getVoiceContents(voiceValues)
  local custName = mod:getProperty("modulatorCustomName")
  local splitCustName = lutils.split(custName, "-")
  local voiceCustName = string.format("%s-2", splitCustName[1])

  self:getModulatorByCustomName(voiceCustName):getComponent():setProperty("uiFixedSliderContent", voiceContents, false)
end

---
-- @function [parent=#YamahaCS1xController] onSaveMenu
--
function YamahaCS1xController:onSaveMenu(mod, value)
  local menu = PopupMenu()    -- Main Menu
  menu:addItem(1, "Performance to file", true, false, Image())
  --  menu:addItem(2, "Bank to file", true, false, Image())
  menu:addItem(3, "Performance to CS1x", true, false, Image())
  --  menu:addItem(4, "Bank to CS1x", true, false, Image())
  local menuSelect = menu:show(0,0,0,0)

  if menuSelect == 0 then
    return
  end

  if menuSelect == 1 then
    self:savePatchToFile()
    --  elseif menuSelect == 2 then
    --
    --    -- Save bank to file
    --    if VoiceBankData == nil then
    --      utils.warnWindow ("No bank loaded", "You must load a bank in order to perform this action.")
    --      return
    --    end
    --
    --    -- Save current performance to VoiceBankData
    --    local currPatch = assembleValues()
    --    putPerformanceToBank(currPatch, Voice_SelectedPatchIndex)
    --
    --    local memBlock = MemoryBlock(PerformanceBankSize, true)
    --    local offset = 0
    --
    --    -- Fill memBlock with VoiceBankData
    --    for i = 1, table.getn(VoiceBankData) do
    --      local data = VoiceBankData[i]:getData()
    --      local dataSize = data:getSize()
    --      offset = offset + dataSize
    --    end
    --
    --    cutils.writeSyxDataToFile(memBlock, utils.saveFileWindow ("Save bank", File(""), "*.syx", true))
  elseif menuSelect == 3 then
    self:writePatchToSynth()
    --  elseif menuSelect == 4 then
    --
    --    -- Write bank to CS1x
    --    if VoiceBankData == nil then
    --      utils.warnWindow ("No bank loaded", "You must load a bank in order to perform this action.")
    --      return
    --    end
    --    local voiceBankSendTimer = 1002
    --    local voiceBankSendIndex = 1
    --    sendPerfBank = function()
    --      if voiceBankSendIndex > table.getn(VoiceBankData) then
    --        timer:stopTimer(voiceBankSendTimer)
    --      else
    --        panel:sendMidiNow(VoiceBankData[voiceBankSendIndex])
    --        voiceBankSendIndex = voiceBankSendIndex + 1
    --      end
    --
    --    end
    --    timer:setCallback(voiceBankSendTimer, sendPerfBank)
    --    timer:startTimer(voiceBankSendTimer, 130)
  end
end

---
-- @function [parent=#YamahaCS1xController] onLoadMenu
--
function YamahaCS1xController:onLoadMenu(mod, value)
  local menu = PopupMenu()
  menu:addItem(1, "Performance from file", true, false, Image())
  --  menu:addItem(2, "Bank from file", true, false, Image())
  menu:addItem(3, "Current Performance from CS1x", true, false, Image())
  --  menu:addItem(4, "Bank from CS1x", true, false, Image())
  local menuSelect = menu:show(0,0,0,0)

  if menuSelect == 0 then
    return
  end

  if menuSelect == 1 then
    -- Load Patch
    local alertValue = AlertWindow.showYesNoCancelBox(AlertWindow.InfoIcon, "Load patch", "Load patch.\nWhat do you want to do?", "Discard bank and load patch", "Insert patch in bank", "Cancel")
    if alertValue == false then return end

    local loadedData = cutils.getSyxAsMemBlock(utils.openFileWindow ("Open Patch", File(""), "*.syx", true))
    self:loadData(loadedData)
    --  elseif menuSelect == 2 then
    --
    --    -- Load bank from file
    --    local data = loadFileContents("Open Bank")
    --    if data:getSize() == PerformanceBankSize then
    --      VoiceBankData = splitMessages(data, 896)
    --      Voice_SelectedPatchIndex = 0
    --      local perfData = getPerformanceFromBank(Voice_SelectedPatchIndex)
    --      assignValues(perfData)
    --    else
    --      AlertWindow.showMessageBox(AlertWindow.WarningIcon, "File format error",
    --        "The file provided does not contain a CS1x bank", "OK")
    --    end
  elseif menuSelect == 3 then
    -- Load performance from CS1x
    local midiSendQueue = {
      CS1xReceiveMsg(COMMON),
      CS1xReceiveMsg(COMMON_1),
      CS1xReceiveMsg(COMMON_2),
      CS1xReceiveMsg(LAYER1),
      CS1xReceiveMsg(LAYER2),
      CS1xReceiveMsg(LAYER3),
      CS1xReceiveMsg(LAYER4),
    }
    self:requestDump(midiSendQueue)
    --  elseif menuSelect == 4 then
    --
    --    -- Load bank from CS1x
    --    local perfIndexArray = {}
    --    for i = 0, 128 do
    --      table.insert(perfIndexArray, i)
    --    end
    --    receivePerformance(perfIndexArray)
  end
end
