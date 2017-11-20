require("AbstractController")
require("Logger")
require("cutils")
require("message/GMSystemOffMsg")
require("message/RolandJV1080DataRequestMsg")
require("message/RolandJV1080DataSetMsg")
require("message/RolandJV1080SystemIdentityMsg")

local log = Logger("RolandJV1080Controller")

-- Patch state map from the MIDI implementation chart.
local RolandJVPatchStateMap = {
  [0x0C] = "EFX Type",
  [0x0D] = "EFX Parameter 1",
  [0x0E] = "EFX Parameter 2",
  [0x0F] = "EFX Parameter 3",
  [0x10] = "EFX Parameter 4",
  [0x11] = "EFX Parameter 5",
  [0x12] = "EFX Parameter 6",
  [0x13] = "EFX Parameter 7",
  [0x14] = "EFX Parameter 8",
  [0x15] = "EFX Parameter 9",
  [0x16] = "EFX Parameter 10",
  [0x17] = "EFX Parameter 11",
  [0x18] = "EFX Parameter 12",
  [0x19] = "EFX Output Assign",
  [0x1A] = "EFX Mix Out Send Level",
  [0x1B] = "EFX Chorus Send Level",
  [0x1C] = "EFX Reverb Send Level",
  [0x1D] = "EFX Control Source 1",
  [0x1E] = "EFX Control Depth 1",
  [0x1F] = "EFX Control Source 2",
  [0x20] = "EFX Control Depth 2",
  [0x21] = "Chorus Level",
  [0x22] = "Chorus Rate",
  [0x23] = "Chorus Depth",
  [0x24] = "Chorus Pre-Delay",
  [0x25] = "Chorus Feedback",
  [0x26] = "Chorus Output",
  [0x27] = "Reverb Type",
  [0x28] = "Reverb Level",
  [0x29] = "Reverb Time",
  [0x2A] = "Reverb HF Damp",
  [0x2B] = "Delay Feedback",
  [0x2C] = "Patch Tempo",
  [0x2E] = "Patch Level",
  [0x2F] = "Patch Pan",
  [0x30] = "Analog Feel",
  [0x31] = "Bend Range Up",
  [0x32] = "Bend Range Down",
  [0x33] = "Key Assign Mode",
  [0x34] = "Solo Legato",
  [0x35] = "Portamento Switch",
  [0x36] = "Portamento Mode",
  [0x37] = "Portamento Type",
  [0x38] = "Portamento Start",
  [0x39] = "Portamento Time",
  [0x3A] = "Patch Control Source 2",
  [0x3B] = "Patch Control Source 3",
  [0x3C] = "EFX Control Hold/Peak",
  [0x3D] = "Control 1 Hold/Peak",
  [0x3E] = "Control 2 Hold/Peak",
  [0x3F] = "Control 3 Hold/Peak",
  [0x40] = "Velocity Range Switch",
  [0x41] = "Octave Shift",
  [0x42] = "Stretch Tune Depth",
  [0x43] = "Voice Priority",
  [0x44] = "Structure Type 1&2",
  [0x45] = "Booster 1&2",
  [0x46] = "Structure Type 3&4",
  [0x47] = "Booster 3&4",
  [0x48] = "Clock Source",
  [0x49] = "Patch Category",
}

-- Offsets to match the modulators.
local RolandJVPatchValueCorrection = {
  [0x1E] = -63, --"EFX Control Depth 1",
  [0x20] = -63, --"EFX Control Depth 2",
  [0x2F] = -64, --"Patch Pan",
-- it is implemented by list: [0x41] = -03, --"Octave Shift",
}

-- Tone state map from MIDI implementation chart.
local RolandJVToneStateMap = {
  [0x00] = "Tone Switch",
  [0x01] = "Wave Group Type",
  [0x02] = "Wave Group ID",
  --  [0x03] = "Wave Number",
  [0x05] = "Wave Gain",
  [0x06] = "FXM Switch",
  [0x07] = "FXM Color",
  [0x08] = "FXM Depth",
  [0x09] = "Tone Delay Mode",
  [0x0A] = "Tone Delay Time",
  [0x0B] = "Velocity Cross Fade",
  [0x0C] = "Velocity Range Lower",
  [0x0D] = "Velocity Range Upper",
  [0x0E] = "Keyboard Range Lower",
  [0x0F] = "Keyboard Range Upper",
  [0x10] = "Redamper Control Switch",
  [0x11] = "Volume Control Switch",
  [0x12] = "Hold-1 Control Switch",
  [0x13] = "Pitch Bend Control Switch",
  [0x14] = "Pan Control Switch",
  [0x15] = "Controller 1 Destination 1",
  [0x16] = "Controller 1 Depth 1",
  [0x17] = "Controller 1 Destination 2",
  [0x18] = "Controller 1 Depth 2",
  [0x19] = "Controller 1 Destination 3",
  [0x1A] = "Controller 1 Depth 3",
  [0x1B] = "Controller 1 Destination 4",
  [0x1C] = "Controller 1 Depth 4",
  [0x1D] = "Controller 2 Destination 1",
  [0x1E] = "Controller 2 Depth 1",
  [0x1F] = "Controller 2 Destination 2",
  [0x20] = "Controller 2 Depth 2",
  [0x21] = "Controller 2 Destination 3",
  [0x22] = "Controller 2 Depth 3",
  [0x23] = "Controller 2 Destination 4",
  [0x24] = "Controller 2 Depth 4",
  [0x25] = "Controller 3 Destination 1",
  [0x26] = "Controller 3 Depth 1",
  [0x27] = "Controller 3 Destination 2",
  [0x28] = "Controller 3 Depth 2",
  [0x29] = "Controller 3 Destination 3",
  [0x2A] = "Controller 3 Depth 3",
  [0x2B] = "Controller 3 Destination 4",
  [0x2C] = "Controller 3 Depth 4",
  [0x2D] = "LFO1 Waveform",
  [0x2E] = "LFO1 Key Sync",
  [0x2F] = "LFO1 Rate",
  [0x30] = "LFO1 Offset",
  [0x31] = "LFO1 Delay Time",
  [0x32] = "LFO1 Fade Mode",
  [0x33] = "LFO1 Fade Time",
  [0x34] = "LFO1 External Sync",
  [0x35] = "LFO2 Waveform",
  [0x36] = "LFO2 Key Sync",
  [0x37] = "LFO2 Rate",
  [0x38] = "LFO2 Offset",
  [0x39] = "LFO2 Delay Time",
  [0x3A] = "LFO2 Fade Mode",
  [0x3B] = "LFO2 Fade Time",
  [0x3C] = "LFO2 External Sync",
  [0x3D] = "Coarse Tune",
  [0x3E] = "Fine Tune",
  [0x3F] = "Random Pitch Depth",
  [0x40] = "Pitch Keyfollow",
  [0x41] = "Pitch Envelope Depth",
  [0x42] = "Pitch Envelope Velocity Sens",
  [0x43] = "Pitch Envelope Velocity Time1",
  [0x44] = "Pitch Envelope Velocity Time4",
  [0x45] = "Pitch Envelope Time Keyfollow",
  [0x46] = "Pitch Envelope Time 1",
  [0x47] = "Pitch Envelope Time 2",
  [0x48] = "Pitch Envelope Time 3",
  [0x49] = "Pitch Envelope Time 4",
  [0x4A] = "Pitch Envelope Level 1",
  [0x4B] = "Pitch Envelope Level 2",
  [0x4C] = "Pitch Envelope Level 3",
  [0x4D] = "Pitch Envelope Level 4",
  [0x4E] = "Pitch LFO1 Depth",
  [0x4F] = "Pitch LFO2 Depth",
  [0x50] = "Filter Type",
  [0x51] = "Cutoff Frequency",
  [0x52] = "Cutoff Keyfollow",
  [0x53] = "Resonance",
  [0x54] = "Resonance Velocity Sens",
  [0x55] = "Filter Envelope Depth",
  [0x56] = "Filter Envelope Velocity Curve 0 - 6",
  [0x57] = "Filter Envelope Velocity Sens",
  [0x58] = "Filter Envelope Velocity Time1 0 - 14",
  [0x59] = "Filter Envelope Velocity Time4 0 - 14",
  [0x5A] = "Filter Envelope Time Keyfollow 0 - 14",
  [0x5B] = "Filter Envelope Time 1",
  [0x5C] = "Filter Envelope Time 2",
  [0x5D] = "Filter Envelope Time 3",
  [0x5E] = "Filter Envelope Time 4",
  [0x5F] = "Filter Envelope Level 1",
  [0x60] = "Filter Envelope Level 2",
  [0x61] = "Filter Envelope Level 3",
  [0x62] = "Filter Envelope Level 4",
  [0x63] = "Filter LFO1 Depth",
  [0x64] = "Filter LFO2 Depth",
  [0x65] = "Tone Level",
  [0x66] = "Bias Direction",
  [0x67] = "Bias Position",
  [0x68] = "Bias Level",
  [0x69] = "Level Envelope Velocity Curve",
  [0x6A] = "Level Envelope Velocity Sens",
  [0x6B] = "Level Envelope Velocity Time1",
  [0x6C] = "Level Envelope Velocity Time4",
  [0x6D] = "Level Envelope Time Keyfollow",
  [0x6E] = "Level Envelope Time 1",
  [0x6F] = "Level Envelope Time 2",
  [0x70] = "Level Envelope Time 3",
  [0x71] = "Level Envelope Time 4",
  [0x72] = "Level Envelope Level 1",
  [0x73] = "Level Envelope Level 2",
  [0x74] = "Level Envelope Level 3",
  [0x75] = "Level LFO1 Depth",
  [0x76] = "Level LFO2 Depth",
  [0x77] = "Tone Pan",
  [0x78] = "Pan Keyfollow",
  [0x79] = "Random Pan Depth",
  [0x7A] = "Alternate Pan Depth",
  [0x7B] = "Pan LFO1 Depth",
  [0x7C] = "Pan LFO2 Depth",
  [0x7D] = "Output Assign",
  [0x7E] = "Mix/EFX Send Level",
  [0x7F] = "Chorus Send Level",
  [0x100] = "Reverb Send Level",

}

-- Tone state offsets from MIDI implementation chart + some from panel implementation.
local RolandJVToneValueCorrection = {
  [0x16] = -63, --"Controller 1 Depth 1",
  [0x18] = -63, --"Controller 1 Depth 2",
  [0x1A] = -63, --"Controller 1 Depth 3",
  [0x1C] = -63, --"Controller 1 Depth 4",
  [0x1E] = -63, --"Controller 2 Depth 1",
  [0x20] = -63, --"Controller 2 Depth 2",
  [0x22] = -63, --"Controller 2 Depth 3",
  [0x24] = -63, --"Controller 2 Depth 4",
  [0x26] = -63, --"Controller 3 Depth 1",
  [0x28] = -63, --"Controller 3 Depth 2",
  [0x2A] = -63, --"Controller 3 Depth 3",
  [0x2C] = -63, --"Controller 3 Depth 4",
  [0x3D] = -48, --"Coarse Tune",
  [0x3E] = -50, --"Fine Tune",
  [0x41] = -12, --"Pitch Envelope Depth",
  [0x4A] = -63, --"Pitch Envelope Level 1",
  [0x4B] = -63, --"Pitch Envelope Level 2",
  [0x4C] = -63, --"Pitch Envelope Level 3",
  [0x4D] = -63, --"Pitch Envelope Level 4",
  [0x4E] = -63, --"Pitch LFO1 Depth",
  [0x4F] = -63, --"Pitch LFO2 Depth",
  [0x55] = -63, --"Filter Envelope Depth",
  [0x63] = -63, --"Filter LFO1 Depth",
  [0x64] = -63, --"Filter LFO2 Depth",
  [0x75] = -63, --"Level LFO1 Depth",
  [0x76] = -63, --"Level LFO2 Depth",
  [0x77] = -64, --"Tone Pan",
  [0x7A] = -63, --"Alternate Pan Depth",
  [0x7B] = -63, --"Pan LFO1 Depth",
  [0x7C] = -63, --"Pan LFO2 Depth",
  -- Manual additions.
  [0x68] = -7, --"Bias Level",
  [0x6A] = -63, --"Level Envelope Velocity Sens",
  [0x6B] = -7, --"Level Envelope Velocity Time1",
  [0x6C] = -7, --"Level Envelope Velocity Time4",
  [0x6C] = -7, --"Level Envelope Velocity Time4",
  [0x6D] = -7, --"Level Envelope Time Keyfollow",
  [0x57] = -63, --"Filter Envelope Velocity Sens",
  [0x58] = -7, --"Filter Envelope Velocity Time1 0 - 14",
  [0x59] = -7, --"Filter Envelope Velocity Time4 0 - 14",
  [0x5A] = -7, --"Filter Envelope Time Keyfollow 0 - 14",
  [0x55] = -63, --"Filter Envelope Depth",
  [0x78] = -7, --"Pan Keyfollow",
  [0x42] = -63, --"Pitch Envelope Velocity Sens",
  [0x43] = -7, --"Pitch Envelope Velocity Time1",
  [0x44] = -7, --"Pitch Envelope Velocity Time4",
  [0x45] = -7, --"Pitch Envelope Time Keyfollow",
  [0x40] = -7, --"Pitch Keyfollow",

}

-- EFX parameter descriptions
-- Should contain all from JV-1010 manual.
local RolandJVEffectParameters = {
  [0] = {
    ["Name"] = "STEREO-EQ",
    ["prm1"] = {
      ["Name"] = "Low Frequency",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- 200 Hz / 400 Hz
    ["prm2"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm3"] = {
      ["Name"] = "High Frequency",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- 4kHz / 8 kHz
    ["prm4"] = {
      ["Name"] = "Hi Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm5"] = {
      ["Name"] = "Peaking1 Frequency",
      ["ValueMin"] = "0",
      ["ValueMax"] = "16",
    }, -- 200/250/315/400/500/630/800/1000/1250/1600/2000/2500/3150/4000/5000/6300/8000
    ["prm6"] = {
      ["Name"] = "Peaking1 Q",
      ["ValueMin"] = "0",
      ["ValueMax"] = "4",
    }, -- 0.5/1,0/2,0/4,0/9,0
    ["prm7"] = {
      ["Name"] = "Peaking1 Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm8"] = {
      ["Name"] = "Peaking2 Frequency",
      ["ValueMin"] = "0",
      ["ValueMax"] = "16",
    }, -- 200/250/315/400/500/630/800/1000/1250/1600/2000/2500/3150/4000/5000/6300/8000
    ["prm9"] = {
      ["Name"] = "Peaking2 Q",
      ["ValueMin"] = "0",
      ["ValueMax"] = "4",
    }, -- 0.5/1,0/2,0/4,0/9,0
    ["prm10"] = {
      ["Name"] = "Peaking2 Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm11"] = {
      ["Name"] = "Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [1] = {
    ["Name"] = "OVERDRIVE",
    ["prm1"] = {
      ["Name"] = "Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Output Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64 0 R63
    ["prm3"] = {
      ["Name"] = "Amp Simulator Type",
      ["ValueMin"] = "0",
      ["ValueMax"] = "3",
    }, -- small,built-in,2-stack,3-stack
    ["prm4"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm5"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm6"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [2] = {
    ["Name"] = "DISTORTION",
    ["prm1"] = {
      ["Name"] = "Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Output Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Amp Simulator Type",
      ["ValueMin"] = "0",
      ["ValueMax"] = "3",
    }, -- small,built-in,2-stack,3-stack
    ["prm4"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm5"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB +15dB
    ["prm6"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [3] = {
    ["Name"] = "PHASER",
    ["prm1"] = {
      ["Name"] = "Manual ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 100Hz - 8 kHz (100-290:10Hz,300-980:20Hz,1-8kHz:100Hz step)
    ["prm2"] = {
      ["Name"] = "Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0.05 - 10Hz (0.05-4.95: 0.05Hz, 5-6.9: 0.1Hz, 7-10:0.5Hz)
    ["prm3"] = {
      ["Name"] = "Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Resonance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm5"] = {
      ["Name"] = "Mix Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Output Pan ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64 0 R63
    ["prm7"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [4] = {
    ["Name"] = "SPECTRUM",
    ["prm1"] = {
      ["Name"] = "Band1 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- 250Hz -15dB to +15 dB
    ["prm2"] = {
      ["Name"] = "Band2 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB 500Hz
    ["prm3"] = {
      ["Name"] = "Band3 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB 1000Hz
    ["prm4"] = {
      ["Name"] = "Band4 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB 1250Hz
    ["prm5"] = {
      ["Name"] = "Band5 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB 2000Hz
    ["prm6"] = {
      ["Name"] = "Band6 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB 3150Hz
    ["prm7"] = {
      ["Name"] = "Band7 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB 4000Hz
    ["prm8"] = {
      ["Name"] = "Band8 Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB 8000Hz
    ["prm9"] = {
      ["Name"] = "Q ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "4",
    }, -- Bandwidth 1 to 5???
    ["prm10"] = {
      ["Name"] = "Output Pan ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64 0 R63
    ["prm11"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [5] = {
    ["Name"] = "ENHANCER",
    ["prm1"] = {
      ["Name"] = "Sens ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Mix Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB
    ["prm4"] = {
      ["Name"] = "High Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, -- -15dB to +15 dB
    ["prm5"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [6] = {
    ["Name"] = "AUTO-WAH",
    ["prm1"] = {
      ["Name"] = "Filter Type ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- Low Pass Filter / Band Pass Filter
    ["prm2"] = {
      ["Name"] = "Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0.05 - 10Hz (0.05-4.95: 0.05Hz, 5-6.9: 0.1Hz, 7-10:0.5Hz)
    ["prm3"] = {
      ["Name"] = "Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Sens ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm5"] = {
      ["Name"] = "Manual ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Peak ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm7"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [7] = {
    ["Name"] = "ROTARY",
    ["prm1"] = {
      ["Name"] = "High Frequency Slow Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0.05 - 10Hz (0.05-4.95: 0.05Hz, 5-6.9: 0.1Hz, 7-10:0.5Hz)
    ["prm2"] = {
      ["Name"] = "Low Frequency Slow Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0.05 - 10Hz (0.05-4.95: 0.05Hz, 5-6.9: 0.1Hz, 7-10:0.5Hz)
    ["prm3"] = {
      ["Name"] = "High Frequency Fast Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0.05 - 10Hz (0.05-4.95: 0.05Hz, 5-6.9: 0.1Hz, 7-10:0.5Hz)
    ["prm4"] = {
      ["Name"] = "Low Frequency Fast Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0.05 - 10Hz (0.05-4.95: 0.05Hz, 5-6.9: 0.1Hz, 7-10:0.5Hz)
    ["prm5"] = {
      ["Name"] = "Speed ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- Slow, Fast
    ["prm6"] = {
      ["Name"] = "High Frequency Acceleration ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "15",
    }, --
    ["prm7"] = {
      ["Name"] = "Low Frequency Acceleration ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "15",
    }, --
    ["prm8"] = {
      ["Name"] = "High Frequency Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm9"] = {
      ["Name"] = "Low Frequency Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm10"] = {
      ["Name"] = "Separation ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm11"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [8] = {
    ["Name"] = "COMPRESSOR",
    ["prm1"] = {
      ["Name"] = "Sustain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Attack ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Output Pan ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64 0 R63
    ["prm4"] = {
      ["Name"] = "Post Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "3",
    }, -- x1/x2/x4/x8
    ["prm5"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm6"] = {
      ["Name"] = "HiGH Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm7"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [9] = {
    ["Name"] = "LIMITER",
    ["prm1"] = {
      ["Name"] = "Threshold Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Release Time ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Compression Ratio ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "3",
    }, -- 1.5:1,2:1,4:1,100:1
    ["prm4"] = {
      ["Name"] = "Output Pan ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm5"] = {
      ["Name"] = "Post Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "3",
    }, --
    ["prm6"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm7"] = {
      ["Name"] = "High Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [10] = {
    ["Name"] = "HEXA-CHORUS",
    ["prm1"] = {
      ["Name"] = "Pre Delay Time ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- ms,0-0.49:0.1,5-9.5:0.5,10-49:1,50-100:2 ms steps)
    ["prm2"] = {
      ["Name"] = "Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- (std. rate 0.05-10)
    ["prm3"] = {
      ["Name"] = "Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Pre Delay Deviation ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "20",
    }, --
    ["prm5"] = {
      ["Name"] = "Depth Deviation ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "40",
    }, -- -20 to +20
    ["prm6"] = {
      ["Name"] = "Pan Deviation ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "20",
    }, --
    ["prm7"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, -- (dry:wet %)
    ["prm8"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [11] = {
    ["Name"] = "TREMOLO-CHORUS",
    ["prm1"] = {
      ["Name"] = "Pre Delay Time ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- see predelay time
    ["prm2"] = {
      ["Name"] = "Chorus Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- see rate
    ["prm3"] = {
      ["Name"] = "Chorus Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Tremolo Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- see rate
    ["prm5"] = {
      ["Name"] = "Tremolo Separation ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Tremolo Phase ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "90",
    }, -- (chorus phase? 0-180?)
    ["prm7"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [12] = {
    ["Name"] = "SPACE-D",
    ["prm1"] = {
      ["Name"] = "Pre Delay Time ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- see predelay
    ["prm2"] = {
      ["Name"] = "Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- see rate
    ["prm3"] = {
      ["Name"] = "Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Phase ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "90",
    }, -- 0-180, 2 degree?
    ["prm5"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm6"] = {
      ["Name"] = "High Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm7"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [13] = {
    ["Name"] = "STEREO-CHORUS",
    ["prm1"] = {
      ["Name"] = "Filter Type ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "2",
    }, -- off, lpf, hpf
    ["prm2"] = {
      ["Name"] = "Cutoff Frequency ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "16",
    }, -- 200 to 8 khz, see earlier
    ["prm3"] = {
      ["Name"] = "Pre Delay Time ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- see predelay time
    ["prm4"] = {
      ["Name"] = "Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm5"] = {
      ["Name"] = "Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Phase ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "90",
    }, -- 0-180?
    ["prm8"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm9"] = {
      ["Name"] = "High Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm10"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm11"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [14] = {
    ["Name"] = "STEREO-FLANGER",
    ["prm1"] = {
      ["Name"] = "Filter Type ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "2",
    }, -- off, lpf, hpf
    ["prm2"] = {
      ["Name"] = "Cutoff Frequency ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "16",
    }, -- 200-8000 see earlier
    ["prm3"] = {
      ["Name"] = "Pre Delay Time ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm4"] = {
      ["Name"] = "Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm5"] = {
      ["Name"] = "Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Phase ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "90",
    }, -- 0-180
    ["prm7"] = {
      ["Name"] = "Feedback Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, -- -98% to 98%, 2% step
    ["prm8"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm9"] = {
      ["Name"] = "High Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm10"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm11"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [15] = {
    ["Name"] = "STEP-FLANGER",
    ["prm1"] = {
      ["Name"] = "Pre Delay Time ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm2"] = {
      ["Name"] = "Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Depth ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Feedback Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, -- -98% to 98%, 2% step
    ["prm5"] = {
      ["Name"] = "Step Rate ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- see Rate
    ["prm6"] = {
      ["Name"] = "Phase ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "90",
    }, --
    ["prm7"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm8"] = {
      ["Name"] = "High Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm9"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [16] = {
    ["Name"] = "STEREO-DELAY",
    ["prm1"] = {
      ["Name"] = "Feedback Mode ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- Normal, Cross
    ["prm2"] = {
      ["Name"] = "Delay Time Left  ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0ms to 500ms: 0-4.9:0.1,5-9.5:0.5,10-39:1,40-290:10,300-500:20ms step
    ["prm3"] = {
      ["Name"] = "Delay Time Right ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, --
    ["prm4"] = {
      ["Name"] = "Feedback Phase Left ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- normal, invert
    ["prm5"] = {
      ["Name"] = "Feedback Phase Right ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- normal, invert
    ["prm6"] = {
      ["Name"] = "Feedback Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, -- -98% to 98%, 2% step
    ["prm7"] = {
      ["Name"] = "HF Damp ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, -- 200-8khz + bypass
    ["prm8"] = {
      ["Name"] = "Low Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm9"] = {
      ["Name"] = "High Gain ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm10"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm11"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [17] = {
    ["Name"] = "MODULATION-DELAY",
    ["prm1"] = {
      ["Name"] = "Feedback Mode",
      ["ValueMin"] = "0",
      ["ValueMax"] = "1",
    }, -- Normal, Cross
    ["prm2"] = {
      ["Name"] = "Delay Time Left",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0ms to 500ms
    ["prm3"] = {
      ["Name"] = "Delay Time Right",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, --
    ["prm4"] = {
      ["Name"] = "Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, -- -98% to +98%
    ["prm5"] = {
      ["Name"] = "HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, -- 200-8khz + bypass
    ["prm6"] = {
      ["Name"] = "Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- rate
    ["prm7"] = {
      ["Name"] = "Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm8"] = {
      ["Name"] = "Phase",
      ["ValueMin"] = "0",
      ["ValueMax"] = "90",
    }, --
    ["prm9"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm10"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm11"] = {
      ["Name"] = "Effect Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm12"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [18] = {
    ["Name"] = "TRIPLE-TAP-DELAY",
    ["prm1"] = {
      ["Name"] = "Delay Time Left",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- same as next
    ["prm2"] = {
      ["Name"] = "Delay Time Right",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- same as next
    ["prm3"] = {
      ["Name"] = "Delay Time Center",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 200 to 1000 ms, 200-545:5ms,550-1000:10ms
    ["prm4"] = {
      ["Name"] = "Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm5"] = {
      ["Name"] = "HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm6"] = {
      ["Name"] = "Left Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm7"] = {
      ["Name"] = "Right Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm8"] = {
      ["Name"] = "Center Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm9"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm10"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm11"] = {
      ["Name"] = "Effect Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm12"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [19] = {
    ["Name"] = "QUADRUPLE-TAP-DELAY ",
    ["prm1"] = {
      ["Name"] = "Delay Time 1 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 200-1000ms
    ["prm2"] = {
      ["Name"] = "Delay Time 2 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Delay Time 3 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm4"] = {
      ["Name"] = "Delay Time 4 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm5"] = {
      ["Name"] = "Level 1 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Level 2 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm7"] = {
      ["Name"] = "Level 3 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm8"] = {
      ["Name"] = "Level 4 ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm9"] = {
      ["Name"] = "Feedback Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm10"] = {
      ["Name"] = "HF Damp ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm11"] = {
      ["Name"] = "Effect Balance ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm12"] = {
      ["Name"] = "Output Level ",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [20] = {
    ["Name"] = "TIME-CONTROL-DELAY",
    ["prm1"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "120",
    }, -- 200-595: 5ms, 600-1000:10ms ????
    ["prm2"] = {
      ["Name"] = "Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm3"] = {
      ["Name"] = "Acceleration",
      ["ValueMin"] = "0",
      ["ValueMax"] = "15",
    }, --
    ["prm4"] = {
      ["Name"] = "HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm5"] = {
      ["Name"] = "Output Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- -63R 0 64L???
    ["prm6"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm7"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm8"] = {
      ["Name"] = "Effect Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm9"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [21] = {
    ["Name"] = "2VOICE-PITCH-SHIFTER",
    ["prm1"] = {
      ["Name"] = "Pitch Shifter Mode",
      ["ValueMin"] = "0",
      ["ValueMax"] = "4",
    }, --
    ["prm2"] = {
      ["Name"] = "Coarse Pitch A",
      ["ValueMin"] = "0",
      ["ValueMax"] = "36",
    }, -- -24..+12
    ["prm3"] = {
      ["Name"] = "Coarse Pitch B",
      ["ValueMin"] = "0",
      ["ValueMax"] = "36",
    }, --
    ["prm4"] = {
      ["Name"] = "Fine Pitch A",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, -- -100..+100 2%
    ["prm5"] = {
      ["Name"] = "Fine Pitch B",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm6"] = {
      ["Name"] = "Pre Delay Time A",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0-500ms
    ["prm7"] = {
      ["Name"] = "Pre Delay Time B",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Pan A",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64 0 63R
    ["prm9"] = {
      ["Name"] = "Output Pan B",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm10"] = {
      ["Name"] = "Level Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, -- A100:0B to A0:B100
    ["prm11"] = {
      ["Name"] = "Effect Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm12"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [22] = {
    ["Name"] = "FBK-PITCH-SHIFTER",
    ["prm1"] = {
      ["Name"] = "Pitch Shifter Mode",
      ["ValueMin"] = "0",
      ["ValueMax"] = "4",
    }, --
    ["prm2"] = {
      ["Name"] = "Coarse Pitch",
      ["ValueMin"] = "0",
      ["ValueMax"] = "36",
    }, -- -24..+12
    ["prm3"] = {
      ["Name"] = "Fine Pitch",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, -- -100..+100
    ["prm4"] = {
      ["Name"] = "Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0..500
    ["prm5"] = {
      ["Name"] = "Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, -- -98..+98
    ["prm6"] = {
      ["Name"] = "Output Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64..0..63R
    ["prm7"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm8"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm9"] = {
      ["Name"] = "Effect Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [23] = {
    ["Name"] = "REVERB",
    ["prm1"] = {
      ["Name"] = "Reverb Type",
      ["ValueMin"] = "0",
      ["ValueMax"] = "5",
    }, -- room1,room2,stage1,stage2,hall1,hall2
    ["prm2"] = {
      ["Name"] = "Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100
    ["prm3"] = {
      ["Name"] = "Gate Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- (Reverb time???)
    ["prm4"] = {
      ["Name"] = "HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, -- 200..8000,bypass
    ["prm5"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm6"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm7"] = {
      ["Name"] = "Effect Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [24] = {
    ["Name"] = "GATE-REVERB",
    ["prm1"] = {
      ["Name"] = "Gate-Reverb Type",
      ["ValueMin"] = "0",
      ["ValueMax"] = "3",
    }, -- normal, reverse, sweep1, sweep2
    ["prm2"] = {
      ["Name"] = "Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100ms
    ["prm3"] = {
      ["Name"] = "Gate Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "99",
    }, -- 5..500ms
    ["prm4"] = {
      ["Name"] = "Low Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm5"] = {
      ["Name"] = "High Gain",
      ["ValueMin"] = "0",
      ["ValueMax"] = "30",
    }, --
    ["prm6"] = {
      ["Name"] = "Effect Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm7"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [25] = {
    ["Name"] = "OVERDRIVE→CHORUS (serial)",
    ["prm1"] = {
      ["Name"] = "Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Over Drive Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64..0..R63
    ["prm3"] = {
      ["Name"] = "Chorus Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100ms
    ["prm4"] = {
      ["Name"] = "Chorus Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- rate
    ["prm5"] = {
      ["Name"] = "Chorus Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm7"] = {
      ["Name"] = "Chorus Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, -- Ch0:OD100..Ch100..OD100
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [26] = {
    ["Name"] = "OVERDRIVE→FLANGER (serial)",
    ["prm1"] = {
      ["Name"] = "Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Over Drive Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, -- L64 ..0..R63
    ["prm3"] = {
      ["Name"] = "Flanger Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100ms
    ["prm4"] = {
      ["Name"] = "Flanger Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm5"] = {
      ["Name"] = "Flanger Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Flanger Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm7"] = {
      ["Name"] = "Flanger Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, -- Fl0..FL100
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [27] = {
    ["Name"] = "OVERDRIVE→DELAY (serial)",
    ["prm1"] = {
      ["Name"] = "Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Over Drive Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0..500ms
    ["prm4"] = {
      ["Name"] = "Delay Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm5"] = {
      ["Name"] = "Delay HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, -- 200..8000,bypass
    ["prm6"] = {
      ["Name"] = "Delay Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm7"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [28] = {
    ["Name"] = "DISTORTION→CHORUS (serial)",
    ["prm1"] = {
      ["Name"] = "Distortion Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Distortion Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Chorus Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm4"] = {
      ["Name"] = "Chorus Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm5"] = {
      ["Name"] = "Chorus Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm7"] = {
      ["Name"] = "Chorus Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [29] = {
    ["Name"] = "DISTORTION→FLANGER (serial)",
    ["prm1"] = {
      ["Name"] = "Distortion Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Distortion Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Flanger Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm4"] = {
      ["Name"] = "Flanger Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm5"] = {
      ["Name"] = "Flanger Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Flanger Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm7"] = {
      ["Name"] = "Flanger Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [30] = {
    ["Name"] = "DISTORTION→DELAY (serial)",
    ["prm1"] = {
      ["Name"] = "Distortion Drive",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Distortion Pan",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, --
    ["prm4"] = {
      ["Name"] = "Delay Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm5"] = {
      ["Name"] = "Delay HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm6"] = {
      ["Name"] = "Delay Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm7"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [31] = {
    ["Name"] = "ENHANCER→CHORUS (serial)",
    ["prm1"] = {
      ["Name"] = "Enhancer Sens",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Enhancer Mix Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Chorus Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100ms
    ["prm4"] = {
      ["Name"] = "Chorus Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- rate
    ["prm5"] = {
      ["Name"] = "Chorus Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm7"] = {
      ["Name"] = "Chorus Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, -- Ch0..Ch100
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [32] = {
    ["Name"] = "ENHANCER→FLANGER (serial)",
    ["prm1"] = {
      ["Name"] = "Enhancer Sens",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Enhancer Mix Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Flanger Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100ms
    ["prm4"] = {
      ["Name"] = "Flanger Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- rate
    ["prm5"] = {
      ["Name"] = "Flanger Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm6"] = {
      ["Name"] = "Flanger Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm7"] = {
      ["Name"] = "Flanger Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [33] = {
    ["Name"] = "ENHANCER→DELAY (serial)",
    ["prm1"] = {
      ["Name"] = "Enhancer Sens",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm2"] = {
      ["Name"] = "Enhancer Mix Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm3"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0..500ms
    ["prm4"] = {
      ["Name"] = "Delay Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm5"] = {
      ["Name"] = "Delay HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm7"] = {
      ["Name"] = "Delay Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm8"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [34] = {
    ["Name"] = "CHORUS→DELAY (serial)",
    ["prm1"] = {
      ["Name"] = "Chorus Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100ms
    ["prm2"] = {
      ["Name"] = "Chorus Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Chorus Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm5"] = {
      ["Name"] = "Chorus Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm6"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0..500ms
    ["prm7"] = {
      ["Name"] = "Delay Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm8"] = {
      ["Name"] = "Delay HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm9"] = {
      ["Name"] = "Delay Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [35] = {
    ["Name"] = "FLANGER→DELAY (serial)",
    ["prm1"] = {
      ["Name"] = "Flanger Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, -- 0..100ms
    ["prm2"] = {
      ["Name"] = "Flanger Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Flanger Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Flanger Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm5"] = {
      ["Name"] = "Flanger Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm6"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, -- 0..500ms
    ["prm7"] = {
      ["Name"] = "Delay Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm8"] = {
      ["Name"] = "Delay HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm9"] = {
      ["Name"] = "Delay Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [36] = {
    ["Name"] = "CHORUS→FLANGER (serial)",
    ["prm1"] = {
      ["Name"] = "Chorus Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm2"] = {
      ["Name"] = "Chorus Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Chorus Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Chorus Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm5"] = {
      ["Name"] = "Flanger Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm6"] = {
      ["Name"] = "Flanger Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm7"] = {
      ["Name"] = "Flanger Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm8"] = {
      ["Name"] = "Flanger Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm9"] = {
      ["Name"] = "Flanger Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [37] = {
    ["Name"] = "CHORUS/DELAY (parallel)",
    ["prm1"] = {
      ["Name"] = "Chorus Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm2"] = {
      ["Name"] = "Chorus Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Chorus Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm5"] = {
      ["Name"] = "Chorus Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm6"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, --
    ["prm7"] = {
      ["Name"] = "Delay Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm8"] = {
      ["Name"] = "Delay HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm9"] = {
      ["Name"] = "Delay Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [38] = {
    ["Name"] = "FLANGER/DELAY (parallel)",
    ["prm1"] = {
      ["Name"] = "Flanger Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm2"] = {
      ["Name"] = "Flanger Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Flanger Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Flanger Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm5"] = {
      ["Name"] = "Flanger Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm6"] = {
      ["Name"] = "Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "126",
    }, --
    ["prm7"] = {
      ["Name"] = "Delay Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm8"] = {
      ["Name"] = "Delay HF Damp",
      ["ValueMin"] = "0",
      ["ValueMax"] = "17",
    }, --
    ["prm9"] = {
      ["Name"] = "Delay Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  },
  [39] = {
    ["Name"] = "CHORUS/FLANGER (parallel)",
    ["prm1"] = {
      ["Name"] = "Chorus Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm2"] = {
      ["Name"] = "Chorus Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm3"] = {
      ["Name"] = "Chorus Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm4"] = {
      ["Name"] = "Chorus Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm5"] = {
      ["Name"] = "Flanger Pre Delay Time",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm6"] = {
      ["Name"] = "Flanger Rate",
      ["ValueMin"] = "0",
      ["ValueMax"] = "125",
    }, --
    ["prm7"] = {
      ["Name"] = "Flanger Depth",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
    ["prm8"] = {
      ["Name"] = "Flanger Feedback Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "98",
    }, --
    ["prm9"] = {
      ["Name"] = "Flanger Balance",
      ["ValueMin"] = "0",
      ["ValueMax"] = "100",
    }, --
    ["prm10"] = {
      ["Name"] = "Output Level",
      ["ValueMin"] = "0",
      ["ValueMax"] = "127",
    }, --
  }
}


RolandJV1080Controller = {}
RolandJV1080Controller.__index = RolandJV1080Controller

setmetatable(RolandJV1080Controller, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

---
-- @function [parent=#RolandJV1080Controller] _init
--
function RolandJV1080Controller:_init()
  AbstractController._init(self)

  self:displayText("Initializing...")
  log:fine("======== Trying to decode modulators ======")
  local memoryItem = "FF"

  -- Modulator list by sysex offset.
  -- Keys/indexes are two byte hex strings (like "00 4C")
  self.modulatorListByMemory = {}
  self.modulatorSpecialListByMemory = {}

  local max = panel:getNumModulators()
  for v=1,max do
    local modulatorRef = panel:getModulatorByIndex(v)
    if (modulatorRef ~= nil and (modulatorRef:getProperty("modulatorIsStatic") == "0")) then
      local formula = string.format("%s", modulatorRef:getMidiMessage():getProperty("midiMessageSysExFormula"))
      if formula ~= nil then
        --string.sub(formula, 22, 5) should work but somehow it does not...
        if (string.len(formula) == 35) then
          local sysexAddress = string.sub(formula , 22 )
          sysexAddress = string.sub(sysexAddress , 1 , 5 )
          self.modulatorListByMemory[sysexAddress] = modulatorRef
          -- Special modulators that have 2-byte values. It will be treated differently.
        elseif (string.len(formula) == 38) then
          local sysexAddress = string.sub(formula , 22 )
          sysexAddress = string.sub(sysexAddress , 1 , 5 )
          self.modulatorSpecialListByMemory[sysexAddress] = modulatorRef

        end
      end
    end
  end
  log:fine("======== Modulator decode end ======")

  -- Send System Identity message.
  self:sendMidiMessage(RolandJV1080SystemIdentityMsg())
end

---
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
function RolandJV1080Controller:onGetData(mod, value)
  self:displayText("Reading data...")
  -- apparently some devices interpret data length as "data length with header"
  -- and some without... so let's ask for 0x55 instead of 0x4A
  self:sendMidiMessage(RolandJV1080DataRequestMsg(0, 0x55))
  --sendDataRequest(0x03,0x00,0x00,0x00,0x00,0x4A)
end

---
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   http://ctrlr.org/api/class_ctrlr_midi_message.html
--
function RolandJV1080Controller:onMidiReceived(midi)
  if( midi:getData():getByte(0) == 0xF0 and
    midi:getData():getByte(1) == 0x7E and
    midi:getData():getByte(3) == 0x06 and
    midi:getData():getByte(4) == 0x02) then
    self:processSystemIdentity(midi)
  elseif(
    midi:getData():getByte(0) == 0xF0 and
    midi:getData():getByte(1) == 0x41 and
    midi:getData():getByte(3) == 0x6A and
    midi:getData():getByte(4) == 0x12) then
    local addr =
      midi:getData():getByte(5) * 0x1000000 +
      midi:getData():getByte(6) * 0x10000 +
      midi:getData():getByte(7) * 0x100 +
      midi:getData():getByte(8)
    local fixedDumpOffset = 9
    local fixedDumpTrailer = 2
    local dataLength = midi:getSize() - fixedDumpOffset - fixedDumpTrailer
    log:fine("Received data of length %04X", dataLength)
    if (    addr >= 0x03000000 and addr <= 0x030007FF) then
      self:processPatchData(midi, fixedDumpOffset)
    elseif (addr >= 0x03001000 and addr <= 0x030017FF) then
      self:processToneData(midi, fixedDumpOffset, midi:getData():getByte(7))
    elseif (addr == 0x0) then
      self:processSystemData(midi, fixedDumpOffset, dataLength)
    end
  end
end

-- System Identity responses.
function RolandJV1080Controller:processSystemIdentity(midi)
  if( midi:getData():getByte(5) == 0x41) then
    log:fine("Roland device")
  else
    log:fine("NOT Roland device")
    self:displayText("NOT Roland device")
    return
  end

  if( midi:getData():getByte(6) == 0x6A) then
    log:fine("JV/XP family")
  else
    log:fine("NOT JV/XP family")
    self:displayText("NOT JV/XP family")
    return
  end

  -- TODO: more JV types recognition
  if( midi:getData():getByte(8) == 0x05) then
    log:fine("JV-1010")
    self:displayText("JV-1010")
  elseif (midi:getData():getByte(8) == 0x05) then
  else
    log:fine("Unknown JV/XP")
    self:displayText("Unknown JV/XP")
  end
  --Put the device to Patch mode and send request for patch values.
  -- Send GM system OFF first. It will go to Performance mode.
  self:sendMidiMessage(GMSystemOffMsg())
  
  -- Then, move it to Patch mode
  -- (Delay might be needed? works for me at least)
  self:sendMidiMessage(RolandJV1080DataSetMsg())
  -- Patch data might be requested right away, right now it is not.
  --sendDataRequest(0x03,0x00,0x00,0x00,0x00,0x4A)
end

-- Patch data responses.
function RolandJV1080Controller:processPatchData(midi,fixedDumpOffset)

  -- Patch name (0-12)
  self.patchName = midi:getData():getRange(fixedDumpOffset + 0,12):toString()

  local patchNumberRef = panel:getModulatorByName("PatchSelect")
  if patchNumberRef ~= nil then
    self.patchName = string.format("%d %s", patchNumberRef:getModulatorValue() + 1, self.patchName)
  end

  -- Individual parameters for the simple controllers
  for v = 0x0C, 0x49 do
    local arrayIndex = string.format("00 %02X", v)
    local modulatorRef = self.modulatorListByMemory[arrayIndex]
    if modulatorRef ~= nil then
      local valueToSet = midi:getData():getByte(fixedDumpOffset + v)
      if RolandJVPatchValueCorrection[v]~= nil then
        valueToSet = valueToSet + RolandJVPatchValueCorrection[v]
      end
      modulatorRef:setModulatorValue(valueToSet,false,false,false)
    elseif v == 0x2C then
      modulatorRef = self.modulatorSpecialListByMemory[arrayIndex]
      if modulatorRef ~= nil then
        log:fine("Found special modulator for %s", arrayIndex)
        modulatorRef:setModulatorValue(
          midi:getData():getByte(fixedDumpOffset + v)*0x10 +
          midi:getData():getByte(fixedDumpOffset + v+1),
          false,false,false)
      end
    end
  end
  log:fine("Finished processing common patch data of %s", self.patchName)

  -- FX parameter handling
  local fxType = midi:getData():getByte(fixedDumpOffset + 0x0C)
  self:onRunFxTypeChange(nil, fxType)
  -- Request tone data 1, rest will be done by processToneData
    self:sendMidiMessage(RolandJV1080DataRequestMsg(0x10, 0x7F))
end

-- System data is not yet processed
function RolandJV1080Controller:processSystemData(midi, fixedDumpOffset, dataLength)
end

function RolandJV1080Controller:processToneData(midi,fixedDumpOffset, toneOffset)

  -- Individual parameters for the simple controllers
  for v = 0x00, 0x100 do
    -- because of that last parameter, offset handling is more complicated
    local combinedOffset = toneOffset + math.floor(v/0x100)
    local arrayIndex = string.format("%02X %02X", combinedOffset, v)
    local modulatorRef = self.modulatorListByMemory[arrayIndex]
    if modulatorRef ~= nil then
      local valueToSet = midi:getData():getByte(fixedDumpOffset + v)
      if RolandJVToneValueCorrection[v]~= nil then
        valueToSet = valueToSet + RolandJVToneValueCorrection[v]
      end
      modulatorRef:setModulatorValue(valueToSet,false,false,false)
      --modulatorRef:getComponent():setPropertyString("componentVisibleName",RolandJVToneStateMap[v])
      -- Special handling for wave number, it is stored on 2 bytes
    elseif v == 0x03 then
      modulatorRef = self.modulatorSpecialListByMemory[arrayIndex]
      if modulatorRef ~= nil then
        modulatorRef:setModulatorValue(
          midi:getData():getByte(fixedDumpOffset + v)*0x10 +
          midi:getData():getByte(fixedDumpOffset + v+1),
          false,false,false)
        --modulatorRef:getComponent():setPropertyString("componentVisibleName",RolandJVToneStateMap[v])
      end
    end
  end

  log:fine("Finished processing tone %d message %d", (toneOffset-0x10)/2+1, (toneOffset % 2)+1)

  -- Tone messages need to be retrieved in 2 messages each.
  if (toneOffset < 0x17) then
    self:sendMidiMessage(RolandJV1080DataRequestMsg(toneOffset + 1, 0x7F))
    -- Display patch name, processing has ended.
  else
    self:displayText(self.patchName)
  end

end

---
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
-- Used also when fx data is loaded from sysex data.
function RolandJV1080Controller:onRunFxTypeChange(mod, value)
  -- do not continue if array is not yet filled (panel not initialized yet)
  if self.modulatorListByMemory == nil then return end
  -- Values originate from patch sysex data offset
  for v = 0, 0x18-0x0D do
    local arrayIndex = string.format("00 %02X", v + 0x0D)
    local modulatorRef = self.modulatorListByMemory[arrayIndex]
    if modulatorRef ~= nil then
      self:setFxModulatorToDefault(modulatorRef,v)
      if  RolandJVEffectParameters[value]~= nil then
        local paramIndex = string.format("prm%d",v+1)
        -- Set name, range based on the effects array
        if RolandJVEffectParameters[value][paramIndex] ~= nil then
          modulatorRef:getComponent():setPropertyString("componentVisibleName",
            RolandJVEffectParameters[value][paramIndex]["Name"])
          -- Range. TODO: min-max checking.
          if RolandJVEffectParameters[value][paramIndex]["ValueMax"] ~= nil then
            modulatorRef:getComponent():setPropertyString("uiSliderMax",
              RolandJVEffectParameters[value][paramIndex]["ValueMax"])
          end
          -- Slider type.
          -- Negative ranges require more settings.
          if (string.match(RolandJVEffectParameters[value][paramIndex]["Name"],"Feedback") ~= nil or
            string.match(RolandJVEffectParameters[value][paramIndex]["Name"],"Gain") ~= nil or
            string.match(RolandJVEffectParameters[value][paramIndex]["Name"],"Pan") ~= nil ) and
            math.floor(RolandJVEffectParameters[value][paramIndex]["ValueMax"]) >= 30 then

            modulatorRef:getComponent():setPropertyString("uiImageSliderResource", "JVKNOB5BI")
            -- unfortunately, Pan usually goes from -64 through 0 to +63
            -- so some modulators will require different negative and positive ranges
            local midValue = math.floor((RolandJVEffectParameters[value][paramIndex]["ValueMax"]+1) / 2)
            local midValue2 = math.floor(RolandJVEffectParameters[value][paramIndex]["ValueMax"] / 2)
            modulatorRef:getComponent():setPropertyDouble("uiSliderMin",0-midValue)
            modulatorRef:getComponent():setPropertyDouble("uiSliderMax",0+midValue2)
            modulatorRef:setPropertyString("modulatorValueExpression", string.format("modulatorValue + %d",midValue))
            -- The value also needs to be re-set.
            modulatorRef:setModulatorValue(modulatorRef:getModulatorValue()-midValue,false,false,false)

          end
        else
          -- If this parameter is not used with this fx type, do not display at all
          modulatorRef:getComponent():setPropertyInt("componentVisibility",0)
        end
      end
    end
  end
end

-- Reset FX modulators. Default settings: 0..127, no offset.
function RolandJV1080Controller:setFxModulatorToDefault(fxModulatorRef, fxModulatorIndex)
  fxModulatorRef:getComponent():setPropertyString("componentVisibleName", string.format("FX PARAM %d", fxModulatorIndex + 1))
  fxModulatorRef:getComponent():setPropertyDouble("uiSliderMax",127)
  fxModulatorRef:getComponent():setPropertyDouble("uiSliderMin",0)
  fxModulatorRef:getComponent():setPropertyString("uiImageSliderResource","JVKnob")
  fxModulatorRef:getComponent():setPropertyInt("componentVisibility",1)
  fxModulatorRef:setPropertyString("modulatorValueExpression","modulatorValue")
end

function RolandJV1080Controller:displayText(textToDisplay)
  local labelRef = panel:getModulatorByName("lblPhTtl")
  if labelRef ~= nil then
    labelRef:getComponent():setPropertyString("uiLabelText",textToDisplay)
  end
end
