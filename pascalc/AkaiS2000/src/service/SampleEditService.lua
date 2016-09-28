require("LuaObject")
require("Logger")

SampleEditService = {}
SampleEditService.__index = SampleEditService

setmetatable(SampleEditService, {
  __index = LuaObject, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function SampleEditService:_init()
  LuaObject._init(self)
end

function SampleEditService:trimSample(sample)
end

function SampleEditService:loopSample(sample)
end

function SampleEditService:timestretchSample(sample)
end

function SampleEditService:resampleSample(sample)
end

function SampleEditService:copySample(sample)
end

function SampleEditService:renameSample(sample)
end

function SampleEditService:deleteSample(sample)
end

function SampleEditService:normaliseSample(sample)
end

function SampleEditService:reverseSample(sample)
end

function SampleEditService:pitchSample(sample)
end
