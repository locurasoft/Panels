require("AbstractMidiSender")

CCMidiSender = {}
CCMidiSender.__index = CCMidiSender

setmetatable(CCMidiSender, {
  __index = AbstractMidiSender, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function CCMidiSender:_init(timeout)
  AbstractMidiSender._init(self, timeout)
end

function CCMidiSender:getMidiMessages(param, value)
  local addr = mutils.d2n2(param)
  return { 
    CtrlrMidiMessage({ 0xB0, 0x63, addr:getByte(0) }), 
    CtrlrMidiMessage({ 0xB0, 0x62, addr:getByte(1) }), 
    CtrlrMidiMessage({ 0xB0, 0x06, value }), 
    CtrlrMidiMessage({ 0xB0, 0x26, value })
  }
end
