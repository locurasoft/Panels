require("ctrlrsdk")

LUA_CONTRUCTOR_NAME = "LUA_CLASS_NAME"

function console(var)
  print(var)
end

function regGlobal(name, value)
  _G[name] = value
end

function delGlobal(name)
  _G[name] = nil
end
