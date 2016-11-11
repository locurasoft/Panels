require("AbstractController")
require("Logger")

local log = Logger("AbstractS2kController")

AbstractS2kController = {}
AbstractS2kController.__index = AbstractS2kController

setmetatable(AbstractS2kController, {
  __index = AbstractController, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function AbstractS2kController:_init()
  AbstractController._init(self)
end

function AbstractS2kController:updateStatus(message)
  panel:getComponent("lcdLabel"):setText(message)
end

