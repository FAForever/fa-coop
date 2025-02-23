local unpack = unpack

local BaseManager = import('/lua/ai/opai/basemanager.lua').BaseManager
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Factions = import('/lua/factions.lua').Factions

local BMBC = '/lua/editor/BaseManagerBuildConditions.lua'
local ABMBC = '/lua/Oxygen/BaseManager/AdvancedBaseManagerBuildConditions.lua'


---@alias ConditionType "ANY" | "ALL"

---@class ConditionFuncAndArgs
---@field func fun(...):boolean
---@field args ...

---@class BuildStructuresCondition
---@field Type ConditionType
---@field BuildConditions BuildCondition[]
---@field Priority number
---@field DifficultySeparate boolean


---@class BuildStructuresFunctionCondition
---@field type ConditionType
---@field conditions ConditionFuncAndArgs[]
---@field difficultySeparate boolean
---@field priority number

---@class AdvancedBaseManager : BaseManager
---@field BuildStructuresConditions table<UnitGroup, BuildStructuresFunctionCondition>
---@field TransportsNeeded integer
---@field TransportsTech 1|2|3
AdvancedBaseManager = Class(BaseManager)
{

    ---@param self AdvancedBaseManager
    ---@param brain AIBrain?
    ---@param baseName UnitGroup?
    ---@param markerName Marker?
    ---@param radius number?
    ---@param levelTable any?
    __init = function(self, brain, baseName, markerName, radius, levelTable)
        self:Create()
        if brain and baseName and markerName and radius then
            self:Initialize(brain, baseName, markerName, radius, levelTable)
        end
    end,

    ---Creates AdvancedBaseManager
    ---@param self AdvancedBaseManager
    Create = function(self)
        BaseManager.Create(self)
        self.BuildStructuresConditions = {}
        self.TransportsNeeded = 0
        self.TransportsTech = 1
    end,

    ---Initializes AdvancedBaseManager
    ---@param self AdvancedBaseManager
    ---@param brain AIBrain
    ---@param baseName UnitGroup
    ---@param markerName Marker
    ---@param radius number
    ---@param levelTable table<UnitGroup, number>
    ---@param diffultySeparate boolean
    Initialize = function(self, brain, baseName, markerName, radius, levelTable, diffultySeparate)
        BaseManager.Initialize(self, brain, baseName, markerName, radius, levelTable, diffultySeparate)
        self:LoadTransportPlatoonTemplate()
        self:ForkThread(self.CheckBuildStructuresConditions)
    end,

    --- Initialises the base manager using the _D1, _D2 and _D3 difficulty tables.
    ---@param self AdvancedBaseManager
    ---@param brain AIBrain
    ---@param baseName UnitGroup
    ---@param markerName Marker
    ---@param radius number
    ---@param levelTable any
    InitializeDifficultyTables = function(self, brain, baseName, markerName, radius, levelTable)
        self:Initialize(brain, baseName, markerName, radius, levelTable, true)
    end,

    ---Adds build structures condition
    ---@param self AdvancedBaseManager
    ---@param groupName UnitGroup
    ---@param conditions BuildStructuresCondition
    AddBuildStructures = function(self, groupName, conditions)
        assert(self.BuildStructuresConditions[groupName] == nil,
            "AdvancedBaseManager.AddBuildStructures: given UnitGroup " .. groupName .. " already presents in conditions")

        assert(conditions.Priority, "AdvancedBaseManager.AddBuildStructures: Priority must be a number, not nil")

        local bcs = conditions.BuildConditions

        assert(bcs,
            "AdvancedBaseManager.AddBuildStructures: BuildConditions must be a references to a functions: {<MODULE PATH>,<FUNCTION NAME>,{<ARGS>}")

        ---@type ConditionFuncAndArgs[]
        local conditionsAndArgs = {}
        for _, bc in bcs do

            assert(bc[1] and bc[2],
                "AdvancedBaseManager.AddBuildStructures: BuildCondition must contain a reference to a function!")

            local func = import(bc[1])[ bc[2] ]

            assert(func ~= nil,
                "AdvancedBaseManager.AddBuildStructures: (" .. bc[1] .. ") " .. bc[2] .. " does not exist!")

            table.insert(conditionsAndArgs,
                {
                    func = func,
                    args = bc[3],
                })
        end
        self.BuildStructuresConditions[groupName] = {
            type = conditions.Type or "ANY",
            priority = conditions.Priority,
            conditions = conditionsAndArgs,
            difficultySeparate = conditions.DifficultySeparate,
        }
    end,

    ---Checks conditions for build groups
    ---@param self AdvancedBaseManager
    ---@param conditions ConditionFuncAndArgs[]
    ---@param conditionType ConditionType
    ---@return boolean
    CheckConditions = function(self, conditions, conditionType)
        if conditionType == "ANY" then
            for _, condition in conditions do
                if condition.func(self.AIBrain, unpack(condition.args)) then
                    return true
                end
            end
            return false
        end
        for _, condition in conditions do
            if not condition.func(self.AIBrain, unpack(condition.args)) then
                return false
            end
        end
        return true
    end,

    ---Thread function to check build structures conditions
    ---@param self AdvancedBaseManager
    CheckBuildStructuresConditions = function(self)
        local buildConditions = self.BuildStructuresConditions
        while true do
            if self.Active then
                for groupName, buildCondition in buildConditions do
                    if self:CheckConditions(buildCondition.conditions, buildCondition.type) then
                        if buildCondition.difficultySeparate then
                            self:AddBuildGroupDifficulty(groupName, buildCondition.priority, false, false)
                        else
                            self:AddBuildGroup(groupName, buildCondition.priority, false, false)
                        end
                        buildConditions[groupName] = nil
                    end
                end
            end
            WaitSeconds(Random(3, 5))
        end
    end,

    ---Loads platoons from file
    ---It must have these contents:
    ---```lua
    ---function Land(baseManager)
    ---end
    ---
    ---function Air(baseManager)
    ---end
    ---
    ---function Naval(baseManager)
    ---end
    ---```
    ---@param self AdvancedBaseManager
    ---@param path? string
    LoadPlatoonsFromFile = function(self, path)
        path = path or "Platoons_"

        platoonsFilePath = Oxygen.ScenarioFolder(path .. self.BaseName .. ".lua")

        if not exists(platoonsFilePath) then
            WARN(path .. self.BaseName .. ".lua wasnt found during loading platoons, skipping...")
            return
        end

        local PlatoonsModule = import(platoonsFilePath)
        PlatoonsModule.Land(self)
        PlatoonsModule.Air(self)
        PlatoonsModule.Naval(self)
        LOG("Loaded platoons from " .. platoonsFilePath)
    end,

    ---Sets Transporting of AdvancedBaseManager to provided value
    ---@param self AdvancedBaseManager
    ---@param value boolean
    SetBuildTransports = function(self, value)
        self.FunctionalityStates.Transporting = value
    end,

    ---Sets Transporting tech level used (BM will use teches below too)
    ---@param self AdvancedBaseManager
    ---@param value 1|2|3
    SetTransportsTech = function(self, value)
        self.TransportsTech = value
    end,

    ---Loads platoons into base manager
    ---@param self AdvancedBaseManager
    ---@param platoons PlatoonSpecTable[]
    ---@param deepcopy? boolean
    LoadPlatoons = function(self, platoons, deepcopy)
        local location = self.BaseName
        local aiBrain = self.AIBrain
        for i, platoon in platoons do
            if platoon.Difficulty ~= ScenarioInfo.Options.Difficulty then
                continue
            end

            ---@type PlatoonSpecTable
            local _platoon = platoon
            if deepcopy then
                _platoon = table.deepcopy(platoon)
            end

            _platoon.Priority = _platoon.Priority or i * 100

            --keeping track of platoon's basename
            _platoon.PlatoonData.BaseName = _platoon.PlatoonData.BaseName or location

            _platoon.LocationType = location
            aiBrain:PBMAddPlatoon(_platoon)
            LOG("Loaded platoon " .. _platoon.BuilderName)
        end
    end,

    ---@deprecated
    ---Loads OpAIs into base manager
    ---@param self AdvancedBaseManager
    ---@param opAIs OpAITable[]
    LoadOpAIs = function(self, opAIs)
        for _, opAItable --[[@as OpAITable]]in opAIs do
            if opAItable.unitGroup then
                WARN("Unit groups in OpAI loader are deprecated, please dont use OpAI Builder for it")
                WARN(opAItable.unitGroup)
                ---@type OpAIData
                local data = opAItable.data
                local buildCondition = opAItable.buildCondition
                if buildCondition then
                    data.BuildCondition = {
                        {
                            buildCondition[1],
                            buildCondition[2],
                            buildCondition[3]
                        }
                    }
                end
                self:AddUnitAI(
                    opAItable.unitGroup,
                    data
                )
            else
                local opAI = self:AddOpAI(
                    opAItable.type,
                    opAItable.name,
                    opAItable.data
                )
                opAI:SetChildActive('All', false)

                local childrenTable = {}
                local quantityTable = {}
                for childrenType, quantity in opAItable.quantity do
                    table.insert(childrenTable, childrenType)
                    table.insert(quantityTable, quantity)
                end
                if not table.empty(childrenTable) then
                    local r = opAI:SetChildQuantity(childrenTable, quantityTable)
                    assert(r ~= false, "Couldn't setup OpAI!")
                end

                for childrenType, state in opAItable.childrenState do
                    opAI:SetChildActive(childrenType, state)
                end

                if opAItable.count then
                    opAI:SetChildCount(opAItable.count)
                end

                for lockType, lockData in opAItable.lock do
                    opAI:SetLockingStyle(lockType, lockData)
                end
                if opAItable.buildConditions then
                    for _, bc in opAItable.buildConditions do
                        opAI:AddBuildCondition(unpack(bc))
                    end
                end
                if opAItable.remove then
                    opAI:RemoveChildren(opAItable.remove)
                end

                if opAItable.formation then
                    opAI:SetFormation(opAItable.formation)
                end

                if opAItable.categories then
                    opAI:SetTargettingPriorities(opAItable.categories, categories.ALLUNITS)
                end
            end
        end

    end,

    ---@param self AdvancedBaseManager
    LoadTransportPlatoonTemplate = function(self)
        local faction = self.AIBrain:GetFactionIndex()
        local name = self.BaseName
        for tech = 1, 2 do
            local factionName = Factions[faction].Key
            self.AIBrain:PBMAddPlatoon {
                BuilderName = 'BaseManager_TransportPlatoon_' .. name .. factionName .. tech,
                PlatoonTemplate = self:CreateTransportPlatoonTemplate(tech, faction),
                Priority = 200 * tech,
                PlatoonType = 'Air',
                RequiresConstruction = true,
                LocationType = name,
                PlatoonAIFunction = { '/lua/ScenarioPlatoonAI.lua', 'TransportPool' },
                BuildConditions = {
                    { ABMBC, 'TransportsEnabled', { name } },
                    { ABMBC, 'TransportsTechAllowed', { name, tech } },
                    { ABMBC, 'NeedTransports', { name } },
                },
                PlatoonData = {
                    BaseName = name,
                },
                InstanceCount = 2,
            }
        end
        if faction ~= 1 then return end
        self.AIBrain:PBMAddPlatoon {
            BuilderName = 'BaseManager_TransportPlatoon_' .. name .. "UEF3",
            PlatoonTemplate = {
                'TransportTemplate',
                'NoPlan',
                { "xea0306", 1, 1, 'Attack', 'None' },
            },
            Priority = 600,
            PlatoonType = 'Air',
            RequiresConstruction = true,
            LocationType = name,
            PlatoonAIFunction = { '/lua/ScenarioPlatoonAI.lua', 'TransportPool' },
            BuildConditions = {
                { ABMBC, 'TransportsEnabled', { name } },
                { ABMBC, 'TransportsTechAllowed', { name, 3 } },
                { ABMBC, 'NeedTransports', { name } },
            },
            PlatoonData = {
                BaseName = name,
            },
            InstanceCount = 2,
        }
    end,

    CreateTransportPlatoonTemplate = function(self, techLevel, faction)
        faction = faction or self.AIBrain:GetFactionIndex()
        local template = {
            'TransportTemplate',
            'NoPlan',
            { 'uea', 1, 1, 'Attack', 'None' },
        }
        if techLevel == 1 then
            template[3][1] = template[3][1] .. '0107'
        elseif techLevel == 2 then
            template[3][1] = template[3][1] .. '0104'
        end
        template = ScenarioUtils.FactionConvert(template, faction)
        return template
    end,
}


---class of advanced base manager with PlatoonNukeAI in use
---@class NukeBaseManger : AdvancedBaseManager
NukeBaseManger = Class(AdvancedBaseManager)
{
    ---@param self NukeBaseManger
    LoadDefaultBaseNukes = function(self)
        local name = self.BaseName
        self.AIBrain:PBMAddPlatoon {
            BuilderName = 'BaseManager_NukePlatoon_' .. name,
            PlatoonTemplate = self:CreateNukePlatoonTemplate(),
            Priority = 400,
            PlatoonType = 'Any',
            RequiresConstruction = false,
            LocationType = name,
            PlatoonAIFunction = { Oxygen.PlatoonAI.Missiles, 'PlatoonNukeAI' },
            BuildConditions = {
                { BMBC, 'BaseActive', { name } },
                { BMBC, 'NukesEnabled', { name } },
            },
            PlatoonData = {
                BaseName = name,
            },
        }
    end,
}
