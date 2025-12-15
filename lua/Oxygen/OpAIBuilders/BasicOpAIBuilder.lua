local BC = import("../BuildConditions.lua")

---@class OpAIData
---@field MasterPlatoonFunction PlatoonAIFunctionTable
---@field PlatoonData PlatoonDataTable
---@field Priority number

---@class OpAITable
---@field type OpAIType
---@field name string
---@field data OpAIData
---@field quantity table<string,integer>
---@field lock table<LockType, LockData>
---@field formation FormationType
---@field childrenState table<string, boolean>
---@field remove string|string[]
---@field buildConditions BuildCondition[]
---@field categories  EntityCategory[]


---@alias OpAIType
--- | "BasicLandAttack"
--- | 'AirAttacks'
--- | 'EngineerAttack'
--- | 'NavalAttacks'


---@alias LockType
--- | 'DeathRatio'
--- | 'DeathTimer'
--- | 'None'

---@class LockData
---@field Ratio number?
---@field LockTimer integer?


---@class IOpAIBuilder
---@field Type OpAIType
---@field _name string
---@field _type OpAIName
---@field _data PlatoonDataTable
---@field _useData PlatoonDataTable
---@field _quantity table<string,integer>
---@field _lock table<LockType, LockData>
---@field _formation FormationType
---@field _childrenState table<string, boolean>
---@field _remove string|string[]
---@field _buildConditions BuildCondition[]
---@field _function PlatoonAIFunctionTable
---@field _useFunction PlatoonAIFunctionTable
---@field _priority  number
---@field _categories  EntityCategory[]
---@field _count integer
IOpAIBuilder = ClassSimple
{
    ---Clears builder
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    _Clear = function(self)
        self._data = nil
        self._quantity = {}
        self._lock = {}
        self._formation = nil
        self._childrenState = {}
        self._remove = nil
        self._buildConditions = {}
        self._name = nil
        self._function = nil
        self._priority = nil
        self._categories = nil
        self._count = nil
    end,

    ---sets target priorities of OpAI units
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param categories EntityCategory[]
    ---@return Builder
    TargettingPriorities = function(self, categories)
        self._categories = categories
        return self
    end,

    ---sets target priorities of OpAI units
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param count integer
    ---@return Builder
    ChildCount = function(self, count)
        self._count = count
        return self
    end,

    ---Uses given FileName and FunctionName for all new OpAIs
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return Builder
    UseAIFunction = function(self, fileName, functionName)
        self._useFunction = { fileName, functionName }
        return self
    end,


    ---Uses given PlatoonDataTable for all new OpAIs
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param data PlatoonDataTable
    ---@return Builder
    UseData = function(self, data)
        self._useData = data
        return self
    end,

    ---Starts creation of new OpAI for use in Platoon loader
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param name string
    ---@return Builder
    New = function(self, name)
        self:_Clear()
        self._name = name
        return self
    end,


    ---Sets data of OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param data PlatoonDataTable
    ---@return Builder
    Data = function(self, data)
        self._data = data
        return self
    end,

    ---comment
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param priority number
    ---@return Builder
    Priority = function(self, priority)
        self._priority = priority
        return self
    end,

    ---comment
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return Builder
    AIFunction = function(self, fileName, functionName)
        self._function = { fileName, functionName }
        return self
    end,


    ---Adds build condition to OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param condition BuildCondition
    ---@return Builder
    AddCondition = function(self, condition)
        table.insert(self._buildConditions, condition)
        return self
    end,

    ---Sets build condition depending on human army having given category
    ---
    ---``` lua
    ---:AddHumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 20)
    ---```
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return Builder
    AddHumansCategoryCondition = function(self, category, compareOp, value)
        return self:AddCondition(
            BC.HumansCategoryCondition(category, compareOp, value)
        )
    end,


    ---Sets quantity of children for OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param childrenType string|(string[])
    ---@param quantity integer
    ---@return Builder
    Quantity = function(self, childrenType, quantity)
        if quantity and quantity ~= 0 then
            self._quantity[childrenType] = quantity
        end
        return self
    end,

    ---Enables children of OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param childrenType string
    ---@return Builder
    EnableChild = function(self, childrenType)
        self._childrenState[childrenType] = true
        return self
    end,

    ---Disables children of OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param childrenType string
    ---@return Builder
    DisableChild = function(self, childrenType)
        self._childrenState[childrenType] = false
        return self
    end,

    ---Removes children of OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param childrenType string|string[]
    ---@return Builder
    RemoveChildren = function(self, childrenType)
        self._remove = childrenType
        return self
    end,

    ---Sets formation of OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param formation FormationType
    ---@return Builder
    Formation = function(self, formation)
        self._formation = formation
        return self
    end,

    ---Sets locking style of OpAI
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@param lockType LockType
    ---@param lockData LockData?
    ---@return Builder
    LockingStyle = function(self, lockType, lockData)
        self._lock[lockType] = lockData or false
        return self
    end,

    ---completes creation of OpAI for use in platoon builder
    ---@generic Builder : IOpAIBuilder
    ---@param self Builder
    ---@return OpAITable
    Create = function(self)
        assert(self.Type, "IOpAIBuilder doesnt support creation of OpAITable without 'Type' specified")
        assert(self._priority, "Priority mustn't be empty")
        
        return {
            name = self._name,
            type = self.Type,
            data = {
                MasterPlatoonFunction = self._function or self._useFunction,
                PlatoonData = self._data or self._useData,
                Priority = self._priority
            },
            quantity = self._quantity,
            lock = self._lock,
            formation = self._formation,
            childrenState = self._childrenState,
            remove = self._remove,
            buildConditions = self._buildConditions,
            categories = self._categories,
            count = self._count
        }
    end,


}
