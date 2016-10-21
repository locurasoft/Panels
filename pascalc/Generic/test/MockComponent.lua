require("PropertyContainer")
require("Logger")

MockComponent = {}
MockComponent.__index = MockComponent

local log = Logger("MockComponent")

setmetatable(MockComponent, {
  __index = PropertyContainer, -- this is what makes the inheritance work
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end,
})

function MockComponent:_init(name)
  PropertyContainer._init(self)
  self.name = name
  self.text = ""
  self.max = 0
  self.min = 0
  self.visible = false
  self.toggleState = false
end

function MockComponent:getMaximum()
  log:info("MockComponent getMaximum")
  return self.max
end

function MockComponent:setComponentText(text)
  log:info("MockComponent setComponentText")
  self.text = text
end

function MockComponent:isVisible()
  log:info("MockComponent isVisible")
  return self.visible
end

function MockComponent:setVisible(visible)
  log:info("MockComponent setVisible")
  self.visible = visible
end

function MockComponent:getToggleState()
  log:info("MockComponent getToggleState")
  return self.toggleState
end

function MockComponent:isShowing()
  log:info("MockComponent isShowing")
end

function MockComponent:isEnabled()
  log:info("MockComponent isEnabled")
  return self:getPropertyInt("componentDisabled") == 0
end

function MockComponent:getComponentText()
  log:info("MockComponent getComponentText")
  return self.text
end

function MockComponent:getMinimum()
  log:info("MockComponent getMinimum")
  return self.min
end

function MockComponent:setName(name)
  log:info("MockComponent setName")
  self.name = name
end

function MockComponent:setValue(value)
  log:info("MockComponent setValue")
  self.value = value
end

function MockComponent:setComponentValue(value)
  log:info("MockComponent setComponentValue")
  self.value = value
end

function MockComponent:setToggleState(toggleState)
  log:info("MockComponent setToggleState")
  self.toggleState = toggleState
end

function MockComponent:setText(text)
  log:info("MockComponent setText")
  self.text = text
end

function MockComponent:getText()
  log:info("MockComponent getText")
  return self.text
end

function MockComponent:getValue()
  log:info("MockComponent getValue")
  return self.value
end
