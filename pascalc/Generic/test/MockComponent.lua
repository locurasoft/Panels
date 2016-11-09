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

function MockComponent:_init(name, mod)
  PropertyContainer._init(self)
  self.name = name
  self.owner = mod
  self.text = ""
  self.compText = ""
  self.max = 0
  self.min = 0
  self.visible = false
  self.toggleState = false
end

function MockComponent:getMaximum()
  return self.max
end

function MockComponent:setComponentText(text)
  self.compText = text
end

function MockComponent:isVisible()
  return self.visible
end

function MockComponent:setVisible(visible)
  self.visible = visible
end

function MockComponent:getToggleState()
  return self.toggleState
end

function MockComponent:isShowing()
end

function MockComponent:isEnabled()
  return self:getPropertyInt("componentDisabled") == 0
end

function MockComponent:getComponentText()
  return String(self.compText)
end

function MockComponent:getMinimum()
  return self.min
end

function MockComponent:setName(name)
  self.name = name
end

function MockComponent:setValue(value)
  self.value = value
end

function MockComponent:setComponentValue(value)
  self.value = value
end

function MockComponent:setToggleState(toggleState)
  self.toggleState = toggleState
end

function MockComponent:setText(text)
  self:setProperty("uiLabelText", text)
end

function MockComponent:getText()
  return self:getProperty("uiLabelText")
end

function MockComponent:getValue()
  return self.value
end

function MockComponent:getOwner()
	return self.owner
end