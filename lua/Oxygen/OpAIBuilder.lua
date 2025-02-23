local BC = import("BuildConditions.lua")


---@alias OpAIName
--- | "EngineerAttack"
--- | "AirScout"
--- | "AirAttacks"
--- | "LightAirAttack"
--- | "BomberEscort"
--- | "BasicLandAttack"
--- | "LandAssualt"
--- | "HeavyLandAttack"
--- | "LeftoverCleanup"
--- | "NavalAttacks"
--- | "NavalFleet"

---@class OpAIData
---@field MasterPlatoonFunction PlatoonAIFunctionTable
---@field PlatoonData PlatoonDataTable
---@field Priority number
---@field Amount integer?
---@field KeepAlive boolean?
---@field Retry boolean?
---@field MaxAssist integer?
---@field BuildCondition BuildCondition

---@class OpAITable
---@field unitGroup UnitGroup
---@field type OpAIName
---@field name string
---@field data OpAIData
---@field quantity table<string,integer>
---@field lock table<LockType, LockData>
---@field formation FormationType
---@field childrenState table<string, boolean>
---@field remove string|string[]
---@field buildCondition OpAIBuildConditionTable
---@field reactive boolean




---@alias BuildConditionFileName
--- | '/lua/editor/otherarmyunitcountbuildconditions.lua'
--- | '/lua/editor/miscbuildconditions.lua'
--- | '/lua/editor/BaseManagerBuildConditions.lua'
---- | ""


---@alias BuildConditionFuncName string

---@class OpAIBuildConditionTable
---@field name BuildConditionFileName
---@field func BuildConditionFuncName
---@field condition table

---@deprecated
---@class OpAIBuilder
---@field _name string
---@field _type OpAIName
---@field _data OpAIData
---@field _quantity table<string,integer>
---@field _lock table<LockType, LockData>
---@field _formation FormationType
---@field _childrenState table<string, boolean>
---@field _remove string|string[]
---@field _buildCondition BuildCondition
---@field _reactive boolean
---@field _unitGroup UnitGroup
OpAIBuilder = ClassSimple
{

    ---Clears builder
    ---@param self OpAIBuilder
    _Clear = function(self)
        self._type = nil
        self._data = nil
        self._quantity = {}
        self._lock = {}
        self._formation = nil
        self._childrenState = {}
        self._remove = nil
        self._buildCondition = nil
        self._name = nil
        self._reactive = false
        self._unitGroup = nil
    end,

    ---Starts creation of new OpAI for use in Platoon loader
    ---@param self OpAIBuilder
    ---@param name string
    ---@return OpAIBuilder
    New = function(self, name)
        self:_Clear()
        self._name = name
        return self
    end,

    ---comment
    ---@param self OpAIBuilder
    ---@param name string
    ---@return OpAIBuilder
    NewReactive = function(self, name)
        self:New(name)
        self._reactive = true
        return self
    end,

    ---comment
    ---@param self OpAIBuilder
    ---@param unitGroup UnitGroup
    ---@return OpAIBuilder
    NewBuildGroup = function(self, unitGroup)
        self:New(unitGroup)
        self._unitGroup = unitGroup
        return self
    end,

    ---Sets type of OpAI
    ---@param self OpAIBuilder
    ---@param pType OpAIName
    ---@return OpAIBuilder
    Type = function(self, pType)
        self._type = pType
        return self
    end,

    ---Sets data of OpAI
    ---@param self OpAIBuilder
    ---@param data OpAIData
    ---@return OpAIBuilder
    Data = function(self, data)
        self._data = data
        return self
    end,

    ---Sets build condition of OpAI
    ---@param self OpAIBuilder
    ---@param buildCondition BuildCondition
    ---@return OpAIBuilder
    BuildCondition = function(self, buildCondition)
        self._buildCondition = buildCondition
        return self
    end,

    ---Sets build condition depending on human army having given category
    ---
    ---``` lua
    ---:HumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 20)
    ---```
    ---@param self OpAIBuilder
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return OpAIBuilder
    HumansCategoryCondition = function(self, category, compareOp, value)
        return self:BuildCondition(
            BC.HumansCategoryCondition(category, compareOp, value)
        )
    end,


    ---Sets quantity of children for OpAI
    ---@param self OpAIBuilder
    ---@param childrenType string
    ---@param quantity integer
    ---@return OpAIBuilder
    Quantity = function(self, childrenType, quantity)
        self._quantity[childrenType] = quantity
        return self
    end,

    ---Enables children of OpAI
    ---@param self OpAIBuilder
    ---@param childrenType string
    ---@return OpAIBuilder
    EnableChild = function(self, childrenType)
        self._childrenState[childrenType] = true
        return self
    end,

    ---Disables children of OpAI
    ---@param self OpAIBuilder
    ---@param childrenType string
    ---@return OpAIBuilder
    DisableChild = function(self, childrenType)
        self._childrenState[childrenType] = false
        return self
    end,

    ---Removes children of OpAI
    ---@param self OpAIBuilder
    ---@param childrenType string|string[]
    ---@return OpAIBuilder
    RemoveChildren = function(self, childrenType)
        self._remove = childrenType
        return self
    end,

    ---Sets formation of OpAI
    ---@param self OpAIBuilder
    ---@param formation FormationType
    ---@return OpAIBuilder
    Formation = function(self, formation)
        self._formation = formation
        return self
    end,

    ---Sets locking style of OpAI
    ---@param self OpAIBuilder
    ---@param lockType LockType
    ---@param lockData LockData?
    ---@return OpAIBuilder
    LockingStyle = function(self, lockType, lockData)
        self._lock[lockType] = lockData or false
        return self
    end,

    ---completes creation of OpAI for use in platoon builder
    ---@param self OpAIBuilder
    ---@return OpAITable
    Create = function(self)

        return {
            name = self._name,
            type = self._type,
            data = self._data,
            quantity = self._quantity,
            lock = self._lock,
            formation = self._formation,
            childrenState = self._childrenState,
            remove = self._remove,
            buildCondition = self._buildCondition,
            unitGroup = self._unitGroup,
            reactive = self._reactive
        }
    end,


}
