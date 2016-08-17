
__MemoryBlockMock = Object()

function MemoryBlock(size, zero)
  return __MemoryBlockMock{ data = {} }
end

function MemoryBlock(other)
  return __MemoryBlockMock{ data = other.data }
end

function MemoryBlock (dataToInitialiseFrom, sizeInBytes)
  return __MemoryBlockMock{ data = {} }
end

function MemoryBlock(hexString)
end

function MemoryBlock(tableData)
  return __MemoryBlockMock{ data = tableData }
end

function fromLuaTable (tableData)
  return MemoryBlock(tableData)
end

function __MemoryBlockMock:insertIntoTable(tableData)
end

function __MemoryBlockMock:createFromTable(tableData)
  data = tableData
end

function __MemoryBlockMock:getByte(position)
  return data[position + 1]
end

function __MemoryBlockMock:getRange(startingPosition, numBytes)
end

function __MemoryBlockMock:toHexString(groupSize)
  local retval = ""
  for k,v in pairs(self.data) do
    retval = string.format("%s %0.2X", retval, v)
  end
  return retval
end

function __MemoryBlockMock:insert(dataToInsert, insertPosition)

  table.insert(self.data,insertPosition,value)
end

function __MemoryBlockMock:insert(dataToInsert, dataSize, insertPosition)
end

function __MemoryBlockMock:append(dataToAppend)
end

function __MemoryBlockMock:copyFrom(dataToCopy, destinationOffset, numBytes)
end

function __MemoryBlockMock:copyTo(dataToCopy, sourceOffset, numBytes)
end

function __MemoryBlockMock:replaceWith(dataToReplace)
end

function __MemoryBlockMock:getBitRange(bitRangeStart, numBits)
end

function __MemoryBlockMock:setBitRange(bitRangeStart, numBits, binaryNumberToApply)
end

function __MemoryBlockMock:removeSection(startByte, dataSize)
end

function __MemoryBlockMock:setByte (bytePosition, byteValue)
end

function __MemoryBlockMock:getSize()
end

function __MemoryBlockMock:toLuaTable (tableToWriteTo)
end


