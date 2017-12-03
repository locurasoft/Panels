require("LuaObject")

AbstractMidiSender = {}
AbstractMidiSender.__index = AbstractMidiSender

setmetatable(AbstractMidiSender, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

local MIDI_SENDER_ID = 15000

local bind = function(t, k)
  return function(...) return t[k](t, ...) end
end

function AbstractMidiSender:_init(timeout)
  LuaObject._init(self)
  self.paramValues = {}
  self.timeout = timeout / 4
  timer:setCallback(MIDI_SENDER_ID, bind(self, "sendMidiInternal"))
  timer:startTimer(MIDI_SENDER_ID, timeout)
end

function AbstractMidiSender:setParamValue(paramIndex, value)
  self.paramValues[paramIndex] = value
end

function AbstractMidiSender:sendMidiInternal()
  local midiMessages = {}
  for k,v in pairs(self.paramValues) do
    table.insert(midiMessages, self:getMidiMessages(k, v))
  end
  self.paramValues = {}
  if next(midiMessages) ~= nil then
    panel:sendMidi(midiMessages, self.timeout)
  end
end

function AbstractMidiSender:getMidiMessages(param, value)
  return {}
end
