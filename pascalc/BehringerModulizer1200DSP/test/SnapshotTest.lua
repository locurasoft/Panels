require("ctrlrTestUtils")
require("Logger")
require 'lunity'
require 'lemock'
module( 'SnapshotTest', lunity )

local xml = require("xmlSimple").newParser()

local log = Logger("SnapshotTest")

function setup()
end

function teardown()
end

function testPartialSelects()
  local xmlParser = xml:ParseXmlText("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<midiLibrarySnapshots name=\"Snapshots\">\n  <midiLibraryBank name=\"my bank\" description=\"\" lsb=\"0\" msb=\"0\" number=\"1\" midiLibraryCanGetItem=\"1\"\n                   midiLibraryCanSendItem=\"1\" uuid=\"5c922b45bfa04cf4824232d0188226af\"/>\n</midiLibrarySnapshots>")
  local xmlElements = xmlParser.midiLibrarySnapshots:children()
  for key, xmlElement in ipairs(xmlElements) do
    if xmlElement:name() == "midiLibraryBank" then
--      if xmlElement["@luaModulatorValueChange"] ~= nil and xmlElement["@luaModulatorValueChange"] ~= "-- None" then
--        modulator:setProperty("luaModulatorValueChange", xmlElement["@luaModulatorValueChange"])
--      end
    elseif xmlElement:name() == "midiLibraryProgram" then
    end
  end
  
  local vt = ValueTree()
  local vt2 = ValueTree()
  vt2:setProperty(description, "b", nil)
  vt:addChild(vt2, 1, nil)
  console(vt:toXmlString())
end

runTests{useANSI = false}
