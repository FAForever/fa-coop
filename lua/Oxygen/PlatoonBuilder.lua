local BC = import("BuildConditions.lua")


---@class PlatoonTemplateName : string
---@class PlatoonTemplatePlan : string
---@class UnitId : string

---@alias OrderType 'Attack'|

---@alias PlatoonType 'Air' | 'Land' | 'Sea' | "Gate" | "Any"


---@alias FormationType
--- | 'GrowthFormation'
--- | "AttackFormation"
--- | "NoFormation"

---@alias PlatoonPlan 'NoPlan'|

---@class PlatoonTemplateEntry
---@field [1] UnitId
---@field [2] integer
---@field [3] integer @ quantity
---@field [4] PlatoonSquadType
---@field [5] FormationType


---@class UnitEntry
---@field [1] UnitId
---@field [2] integer @ quantity
---@field [3] PlatoonSquadType
---@field [4] FormationType


---@class PlatoonTemplateTable
---@field [1] PlatoonTemplateName
---@field [2] PlatoonPlan
---@field [3] PlatoonTemplateEntry
---@field [4] PlatoonTemplateEntry?
---@field [5] PlatoonTemplateEntry?
---....

---@class PlatoonAIFunctionTable
---@field [1] FileName
---@field [2] FunctionName


---@class PlatoonSpecTable
---@field public BuilderName string #Unique name of platoon spec
---@field public PlatoonTemplate PlatoonTemplateTable #Units and their setup
---@field public InstanceCount integer #Count of instances of this platoon spec
---@field public Priority number #Base Manager builds platoons with higher priority first
---@field public PlatoonType PlatoonType #In what factory type build platoon, "Any" = {"Land", "Sea", "Air"}  (used for engineers or with RequiresConstruction = false)
---@field public RequiresConstruction boolean #if true then builds platoon units in factiories else tries to form from existing ones
---@field public LocationType UnitGroup #Base Manager name
---@field public PlatoonBuildCallbacks PlatoonAIFunctionTable[] #Callbacks when platoon starts to build
---@field public PlatoonAddFunctions PlatoonAIFunctionTable[] #Callbacks when platoon is complete
---@field public PlatoonAIFunction PlatoonAIFunctionTable #Main Platoon AI function
---@field public PlatoonData PlatoonDataTable #Data that is being passed into AI functions
---@field public BuildConditions BuildCondition? #Platoon wont be built or formed before conditions met
---@field public BuildTimeOut integer 
---@field public Difficulty DifficultyLevel #On what difficulties to build platoon


---@class PlatoonTemplateBuilder
---@field _useFunction PlatoonAIFunctionTable
---@field _useType PlatoonType
---@field _useLocation UnitGroup
---@field _useData PlatoonDataTable
---@field _name string
---@field _template PlatoonTemplateTable
---@field _instanceCount integer
---@field _priority number
---@field _type PlatoonType
---@field _requiresconstruction boolean
---@field _location UnitGroup
---@field _function PlatoonAIFunctionTable
---@field _addFunctions PlatoonAIFunctionTable[]
---@field _startFunctions PlatoonAIFunctionTable[]
---@field _data PlatoonDataTable
---@field _conditions BuildCondition
---@field _buildTimeout integer
---@field _difficulty DifficultyLevel
---@field _allowNoPriority boolean
---@field _conditionType ConditionType
PlatoonBuilder = ClassSimple
{
    ---Uses given UnitGroup for all new Platoons
    ---@param location UnitGroup
    ---@return PlatoonTemplateBuilder
    UseLocation = function(self, location)
        self._useLocation = location
        return self
    end,

    ---Uses given FileName and FunctionName for all new Platoons
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonTemplateBuilder
    UseAIFunction = function(self, fileName, functionName)
        self._useFunction = { fileName, functionName }
        return self
    end,

    ---Uses given PlatoonType for all new Platoons
    ---@param platoonType PlatoonType
    ---@return PlatoonTemplateBuilder
    UseType = function(self, platoonType)
        self._useType = platoonType
        return self
    end,

    ---Uses given PlatoonDataTable for all new Platoons
    ---@param self PlatoonTemplateBuilder
    ---@param data PlatoonDataTable
    ---@return PlatoonTemplateBuilder
    UseData = function(self, data)
        self._useData = data
        return self
    end,

    ---@param self PlatoonTemplateBuilder
    _Clear = function(self)
        self._name = nil
        self._conditions = nil
        self._location = nil
        self._priority = nil
        self._template = nil
        self._type = nil
        self._function = nil
        self._instanceCount = nil
        self._data = nil
        self._buildTimeout = nil
        self._difficulty = nil
        self._addFunctions = nil
        self._startFunctions = nil
        self._conditionType = nil
    end,

    ---Starts creation of new Platoon
    ---@param self PlatoonTemplateBuilder
    ---@param name string
    ---@return PlatoonTemplateBuilder
    New = function(self, name)
        self:_Clear()
        self._name = name
        self._instanceCount = 1
        self._template = {
            name .. 'template',
            'NoPlan',
        }
        return self
    end,

    ---@deprecated
    ---Starts creation of new land Platoon with default
    ---PlatoonTemplate with NoPlan
    ---InstanceCount = 1
    ---RequiresConstruction = true
    ---@param self PlatoonTemplateBuilder
    ---@param name string
    ---@return PlatoonTemplateBuilder
    NewDefault = function(self, name)
        self:New(name)
        return self
    end,

    ---Sets PlatoonData of platoon template, merges if alreay presents
    ---@param self PlatoonTemplateBuilder
    ---@param data PlatoonDataTable
    ---@return PlatoonTemplateBuilder
    Data = function(self, data)
        self._data = table.merged(self._data, data)
        return self
    end,

    ---Merges passed data into data or use data table
    ---@param self PlatoonTemplateBuilder
    ---@param data PlatoonDataTable
    ---@return PlatoonTemplateBuilder
    MergeData = function(self, data)
        self._data = table.merged(data, self._data or self._useData)
        return self
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param priority number
    ---@return PlatoonTemplateBuilder
    Priority = function(self, priority)
        self._priority = priority
        return self
    end,


    ---Makes priority to be set by build manager during loading
    ---based on order of items in list
    ---@param self PlatoonTemplateBuilder
    ---@param value boolean
    ---@return PlatoonTemplateBuilder
    UseOrderPriority = function(self, value)
        self._allowNoPriority = value
        return self
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param location UnitGroup
    ---@return PlatoonTemplateBuilder
    Location = function(self, location)
        self._location = location
        return self
    end,
    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param pType PlatoonType
    ---@return PlatoonTemplateBuilder
    Type = function(self, pType)
        self._type = pType
        return self
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonTemplateBuilder
    AIFunction = function(self, fileName, functionName)
        self._function = { fileName, functionName }
        return self
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param count integer
    ---@return PlatoonTemplateBuilder
    InstanceCount = function(self, count)
        self._instanceCount = count
        return self
    end,

    ---Adds new unit into template
    ---@param self PlatoonTemplateBuilder
    ---@param unitId UnitId
    ---@param quantity? integer @defaults to 1
    ---@param squad? PlatoonSquadType @defaults to 'Attack'
    ---@param formationType? FormationType @defaults to 'AttackFormation'
    ---@return PlatoonTemplateBuilder
    AddUnit = function(self, unitId, quantity, squad, formationType)
        if quantity == 0 then return self end
        assert(self._template, "PlatoonTemplate wasnt initialized")
        table.insert(self._template,
            { unitId, 1, quantity or 1, squad or 'Attack', formationType or 'AttackFormation' })
        return self
    end,

    ---Adds units to platoon template
    ---@param self PlatoonTemplateBuilder
    ---@param units UnitEntry[]
    ---@return PlatoonTemplateBuilder
    AddUnits = function(self, units)
        for _, unitDef in units do
            self:AddUnit(unpack(unitDef))
        end
        return self
    end,

    ---Sets condition type:
    ---
    --- "ALL" - all conditions must be met (default)
    ---
    --- "ANY" - any of conditions must be met
    ---@param self PlatoonTemplateBuilder
    ---@param cType ConditionType
    ---@return PlatoonTemplateBuilder
    ConditionType = function(self, cType)
        self._conditionType = cType
        return self
    end,

    ---@param self PlatoonTemplateBuilder
    ---@param condition BuildCondition
    ---@return PlatoonTemplateBuilder
    AddCondition = function(self, condition)
        if not self._conditions then
            self._conditions = {}
        end
        table.insert(self._conditions, condition)
        return self
    end,

    ---Adds build condition depending on human army having given category
    ---
    ---``` lua
    ---:AddHumansCategoryCondition(categories.LAND * categories.MOBILE, ">=", 20)
    ---```
    ---@param self PlatoonTemplateBuilder
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonTemplateBuilder
    AddHumansCategoryCondition = function(self, category, compareOp, value)
        return self:AddArmyCategoryCondition("HumanPlayers", category, compareOp, value)
    end,

    ---@param self PlatoonTemplateBuilder
    ---@param army ArmyName
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonTemplateBuilder
    AddArmyCategoryCondition = function(self, army, category, compareOp, value)
        return self:AddArmiesCategoryCondition({ army }, category, compareOp, value)
    end,

    ---@param self PlatoonTemplateBuilder
    ---@param armies ArmyName[]
    ---@param category EntityCategory
    ---@param compareOp CompareOp
    ---@param value number
    ---@return PlatoonTemplateBuilder
    AddArmiesCategoryCondition = function(self, armies, category, compareOp, value)
        return self:AddCondition(BC.ArmiesCategoryCondition(armies, category, compareOp, value))
    end,

    ---comment
    ---@param self PlatoonTemplateBuilder
    ---@param time integer
    ---@return PlatoonTemplateBuilder
    BuildTimeOut = function(self, time)
        self._buildTimeout = time
        return self
    end,

    ---Makes platoon to be built only on listed difficulty
    ---@param self PlatoonTemplateBuilder
    ---@param difficulty DifficultyStrings
    ---@return PlatoonTemplateBuilder
    Difficulty = function(self, difficulty)
        self._difficulty = Oxygen.DifficultyValue.ParseDifficulty(difficulty)
        return self
    end,

    ---Makes platoon to be built only on listed difficulties
    ---@param self PlatoonTemplateBuilder
    ---@param difficulties DifficultyStrings[]
    ---@return PlatoonTemplateBuilder
    Difficulties = function(self, difficulties)
        self._difficulty = Oxygen.DifficultyValue.ParseDifficulty(difficulties)
        return self
    end,

    ---Adds callback when platoon is started being built
    ---@param self PlatoonTemplateBuilder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonTemplateBuilder
    AddStartCallback = function(self, fileName, functionName)
        self._startFunctions = self._startFunctions or {}
        table.insert(self._startFunctions, { fileName, functionName })
        return self
    end,

    ---Adds callback when platoon is completed being built
    ---@param self PlatoonTemplateBuilder
    ---@param fileName FileName
    ---@param functionName FunctionName
    ---@return PlatoonTemplateBuilder
    AddCompleteCallback = function(self, fileName, functionName)
        self._addFunctions = self._addFunctions or {}
        table.insert(self._addFunctions, { fileName, functionName })
        return self
    end,

    ---Makes platoon to be built once
    ---@param self PlatoonTemplateBuilder
    ---@return PlatoonTemplateBuilder
    BuildOnce = function(self)
        return self:AddCompleteCallback('/lua/scenarioplatoonai.lua', 'BuildOnce')
    end,

    ---Enables stealth on platoon units
    ---@param self PlatoonTemplateBuilder
    ---@return PlatoonTemplateBuilder
    EnableStealth = function(self)
        return self:AddCompleteCallback('/lua/scenarioplatoonai.lua', 'PlatoonEnableStealth')
    end,

    ---Enables jamming on platoon units
    ---@param self PlatoonTemplateBuilder
    ---@return PlatoonTemplateBuilder
    EnableJamming = function(self)
        return self:AddCompleteCallback(Oxygen.PlatoonAI.Common, 'PlatoonEnableJamming')
    end,

    ---@param self PlatoonTemplateBuilder
    _Verify = function(self)
        assert(self._name, "Platoon Spec must have a name!")
        assert(self._priority or self._allowNoPriority, "Priority Spec must be a number")
        assert(self._template, "Platoon Spec must have a unit template!")
        assert(self._function or self._useFunction, "Platoon Spec must have AI function!")
        assert(self._data or self._useData, "Platoon Spec must have PlatoonData set!")
    end,

    ---Creates Platoon template. If fn passed, applies that function to platoon builder
    ---@param self PlatoonTemplateBuilder
    ---@param fn? fun(platoonBuilder:PlatoonTemplateBuilder)
    ---@return PlatoonSpecTable
    Create = function(self, fn)
        if fn then
            fn(self)
        end
        self:_Verify()
        if self._conditions then
            self._conditions.Type = self._conditionType or "ALL"
        end

        ---@type PlatoonSpecTable
        local result = {
            BuilderName           = self._name,
            BuildConditions       = self._conditions,
            LocationType          = self._location or self._useLocation,
            Priority              = self._priority,
            PlatoonTemplate       = self._template,
            PlatoonType           = self._type or self._useType or "Any",
            PlatoonAIFunction     = self._function or self._useFunction,
            InstanceCount         = self._instanceCount or 1,
            PlatoonData           = self._data or self._useData,
            RequiresConstruction  = true,
            BuildTimeOut          = self._buildTimeout,
            Difficulty            = self._difficulty or ScenarioInfo.Options.Difficulty,
            PlatoonAddFunctions   = self._addFunctions,
            PlatoonBuildCallbacks = self._startFunctions,
        }

        return result
    end
}
