---@param comporator CompareOp @ defaults to ">="
---@param n1 number
---@param n2 number
---@return boolean
local function Compare(comporator, n1, n2)
    if not comporator or comporator == '>=' then
        return n1 >= n2
    elseif comporator == '==' then
        return n1 == n2
    elseif comporator == '<=' then
        return n1 <= n2
    elseif comporator == '>' then
        return n1 > n2
    elseif comporator == '<' then
        return n1 < n2
    else
        return false
    end
end

---Returns true if given target brains are having active or building units with given category satisfying compare operation
---@param aibrain AIBrain
---@param targetBrains ArmyName[]
---@param numReq number
---@param category EntityCategory
---@param compareType CompareOp @ defaults to ">="
---@return boolean
function FocusBrainBeingBuiltOrActiveCategoryCompare(aibrain, targetBrains, numReq, category, compareType)
    local num = 0
    local targetBrainSet = {}
    local armySetup = ScenarioInfo.ArmySetup

    for _, brain in targetBrains do
        if brain == 'HumanPlayers' then
            local tblArmy = ListArmies()
            for _, strArmy in ipairs(tblArmy) do
                if armySetup[strArmy].Human then
                    targetBrainSet[armySetup[strArmy].ArmyName] = true
                end
            end
        else
            targetBrainSet[brain] = true
        end
    end

    for _, testBrain in ipairs(ArmyBrains) do
        if targetBrainSet[testBrain.Name] then
            num = num + testBrain:GetBlueprintStat('Units_BeingBuilt', category) +
                testBrain:GetBlueprintStat('Units_Active', category)
        end
    end

    return Compare(compareType, num, numReq)
end

---@alias EconStat
--- | "MassTrend"
--- | "EnergyTrend"
--- | "MassStorageRatio"
--- | "EnergyStorageRatio"
--- | "EnergyIncome"
--- | "MassIncome"
--- | "EnergyUsage"
--- | "MassUsage"
--- | "EnergyRequested"
--- | "MassRequested"
--- | "MassRequested"
--- | "EnergyStorage"
--- | "MassStorage"
--- | "AvgEnergyIncome"
--- | "AvgMassIncome"

local samplesCount = 16
local Samples = import("AvgValues.lua").Samples

local economyFunctions =
{
    ---@param aiBrain AIBrain
    ---@return number
    AvgEnergyIncome = function(aiBrain)
        ---@type Samples
        aiBrain.EnergyIncomeSamples = aiBrain.EnergyIncomeSamples or Samples(samplesCount)
        local samples = aiBrain.EnergyIncomeSamples
        samples:Add(aiBrain:GetEconomyIncome('ENERGY'))
        return samples:Average() * 10
    end,

    AvgMassIncome = function(aiBrain)
        ---@type Samples
        aiBrain.MassIncomeSamples = aiBrain.MassIncomeSamples or Samples(samplesCount)
        local samples = aiBrain.MassIncomeSamples
        samples:Add(aiBrain:GetEconomyIncome('MASS'))
        return samples:Average() * 10
    end,

    EnergyTrend = function(aiBrain) return aiBrain:GetEconomyTrend('ENERGY') * 10 end,
    MassTrend = function(aiBrain) return aiBrain:GetEconomyTrend('MASS') * 10 end,
    EnergyIncome = function(aiBrain) return aiBrain:GetEconomyIncome('ENERGY') * 10 end,
    MassIncome = function(aiBrain) return aiBrain:GetEconomyIncome('MASS') * 10 end,
    EnergyUsage = function(aiBrain) return aiBrain:GetEconomyUsage('ENERGY') * 10 end,
    MassUsage = function(aiBrain) return aiBrain:GetEconomyUsage('MASS') * 10 end,
    EnergyRequested = function(aiBrain) return aiBrain:GetEconomyRequested('ENERGY') * 10 end,
    MassRequested = function(aiBrain) return aiBrain:GetEconomyRequested('MASS') * 10 end,
    EnergyStorage = function(aiBrain) return aiBrain:GetEconomyStored('ENERGY') end,
    MassStorage = function(aiBrain) return aiBrain:GetEconomyStored('MASS') end,
    EnergyStorageRatio = function(aiBrain) return aiBrain:GetEconomyStoredRatio('ENERGY') end,
    MassStorageRatio = function(aiBrain) return aiBrain:GetEconomyStoredRatio('MASS') end,
}

---Returns true if given target brains are having active or building units with given category satisfying compare operation
---@param aibrain AIBrain
---@param targetBrains ArmyName[]
---@param numReq number
---@param econStat EconStat
---@param compareType CompareOp @ defaults to ">="
---@return boolean
function BrainsCompareEconomyStats(aibrain, targetBrains, numReq, econStat, compareType)
    local num = 0
    local targetBrainSet = {}
    local armySetup = ScenarioInfo.ArmySetup

    for _, brain in targetBrains do
        if brain == 'HumanPlayers' then
            local tblArmy = ListArmies()
            for _, strArmy in ipairs(tblArmy) do
                if armySetup[strArmy].Human then
                    targetBrainSet[armySetup[strArmy].ArmyName] = true
                end
            end
        else
            targetBrainSet[brain] = true
        end
    end

    for _, testBrain in ipairs(ArmyBrains) do
        if targetBrainSet[testBrain.Name] then
            num = num + economyFunctions[econStat](testBrain)
        end
    end

    return Compare(compareType, num, numReq)
end

---@param aibrain AIBrain
---@param numReq number
---@param econStat EconStat
---@param compareType CompareOp
---@return boolean
function BrainCompareEconomy(aibrain, numReq, econStat, compareType)
    local num = economyFunctions[econStat](aibrain)
    return Compare(compareType, num, numReq)
end

---@param aibrain AIBrain
---@param numReq number
---@param category EntityCategory
---@param compareType CompareOp
---@return boolean
function BrainCompareNumCategory(aibrain, numReq, category, compareType)
    local num = aibrain:GetCurrentUnits(category)
    return Compare(compareType, num, numReq)
end
