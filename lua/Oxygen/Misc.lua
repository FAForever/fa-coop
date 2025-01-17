local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Utils = import("Utils.lua")
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')



---Scatters units on targets with given order
---@param order fun(units:Unit[], target:Unit)
---@param units Unit[]
---@param targets Unit[]
function ScatterUnits(order, units, targets)
    local targetCount = table.getn(targets)
    local unitsCount = table.getn(units)

    local unitsPerTarget = unitsCount / targetCount
    if unitsPerTarget * targetCount < unitsCount then
        unitsPerTarget = unitsPerTarget + 1
    end

    local index = 1
    local curPoolSize = 0
    local pool = {}
    for _, unit in units do
        table.insert(pool, unit)
        curPoolSize = curPoolSize + 1
        if curPoolSize == unitsPerTarget then
            order(pool, targets[index])
            pool = {}
            curPoolSize = 0
            index = index + 1
        end

    end

    if index == targetCount and curPoolSize ~= unitsPerTarget then
        order(pool, targets[index])
    end

end

local function MapGroupToIds(unitGroup, idToCount)
    for _, unit in unitGroup.Units do
        if unit.type == "GROUP" then
            MapGroupToIds(unit, idToCount)
        else
            idToCount[unit.type] = (idToCount[unit.type] or 0) + 1
        end
    end
    return idToCount
end

---Makes from map units UnitEntry list for Platoon Builder
---@param army string
---@param name string
---@param squad? PlatoonSquadType @defaults to 'Attack'
---@param formation? FormationType @defaults to 'AttackFormation'
---@return UnitEntry[]
function FromMapUnits(army, name, squad, formation)
    local unitGroup = ScenarioUtils.FindUnitGroup(name, Scenario.Armies[army].Units)

    assert(unitGroup, "Units of " .. army .. " named " .. name .. " not found")

    local idToCount = MapGroupToIds(unitGroup, {})

    local result = {}
    for id, count in idToCount do
        table.insert(result, { id, count, squad, formation })
    end

    return result
end

---Makes from map units UnitEntry list for Platoon Builder with difficulty specified
---@param army string
---@param name string
---@param squad? PlatoonSquadType @defaults to 'Attack'
---@param formation? FormationType @defaults to 'AttackFormation'
---@return UnitEntry[]
function FromMapUnitsDifficulty(army, name, squad, formation)
    return FromMapUnits(army, name .. "_D" .. ScenarioInfo.Options.Difficulty, squad, formation)
end
