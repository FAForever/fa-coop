local import, unpack = import, unpack

---Command represents a table with such structure:
---
---`{ <file path>, <function name>, <table of arguments> }`
---
---https://en.wikipedia.org/wiki/Command_pattern
---@class Command
---@field [1] FileName
---@field [2] FunctionName
---@field [3] table @arguments
Command = ClassSimple
{
    __init = function(self, args)
        self[3] = args
    end,

    ---Executes command
    ---@param self Command
    ---@return any
    Execute = function(self)
        return import(self[1])[ self[2] ](unpack(self[3]))
    end
}

---@class BrainsCompareNumCategoryCommand : Command
BrainsCompareNumCategoryCommand = Class(Command)
{
    '/lua/editor/otherarmyunitcountbuildconditions.lua',
    "BrainsCompareNumCategory"
}

---@class FocusBrainBeingBuiltOrActiveCategoryCompareCommand : Command
FocusBrainBeingBuiltOrActiveCategoryCompareCommand = Class(Command)
{
    '/lua/Oxygen/BrainsConditions.lua',
    "FocusBrainBeingBuiltOrActiveCategoryCompare"
}
