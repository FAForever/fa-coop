local OBC = '/lua/Oxygen/BrainsConditions.lua'

---Creates condition for matching categories of armies
---@param armies ArmyName[]
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmiesCategoryCondition(armies, category, compareOp, value)
    assert(not EntityCategoryEmpty(category), "Detected empty category! Condition won't be met!")
    return {
        '/lua/editor/otherarmyunitcountbuildconditions.lua',
        "BrainsCompareNumCategory",
        { armies, value, category, compareOp }
    }
end

---Creates condition for matching categories of an army
---@param category EntityCategory
---@param army ArmyName
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmyCategoryCondition(army, category, compareOp, value)
    return ArmiesCategoryCondition({ army }, category, compareOp, value)
end

---Creates condition for matching categories of Humans
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function HumansCategoryCondition(category, compareOp, value)
    return ArmyCategoryCondition("HumanPlayers", category, compareOp, value)
end

---Creates condition for matching categories of Armies of units that are active or being built
---@param armies ArmyName[]
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmiesBuiltOrActiveCategoryCondition(armies, category, compareOp, value)
    assert(not EntityCategoryEmpty(category), "Detected empty category! Condition won't be met!")
    return {
        OBC,
        "FocusBrainBeingBuiltOrActiveCategoryCompare",
        { armies, value, category, compareOp }
    }
end

---Creates condition for matching categories of an Army of units that are active or being built
---@param category EntityCategory
---@param army ArmyName
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmyBuiltOrActiveCategoryCondition(army, category, compareOp, value)
    return ArmiesBuiltOrActiveCategoryCondition({ army }, category, compareOp, value)
end

---Creates condition for matching categories of Humans of units that are active or being built
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function HumansBuiltOrActiveCategoryCondition(category, compareOp, value)
    return ArmyBuiltOrActiveCategoryCondition("HumanPlayers", category, compareOp, value)
end

---Creates condition for matching Economy stat of Armies
---@param armies ArmyName[]
---@param econStat EconStat
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmiesEconomyCondition(armies, econStat, compareOp, value)
    return {
        OBC,
        "BrainsCompareEconomyStats",
        { armies, value, econStat, compareOp }
    }
end

---Creates condition for matching Economy stat of an Army
---@param army ArmyName
---@param econStat EconStat
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function ArmyEconomyCondition(army, econStat, compareOp, value)
    return ArmiesEconomyCondition({ army }, econStat, compareOp, value)
end

---Creates condition for matching Economy stat of Human
---@param econStat EconStat
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function HumansEconomyCondition(econStat, compareOp, value)
    return ArmyEconomyCondition("HumanPlayers", econStat, compareOp, value)
end

---Creates condition for matching economy of a brain
---@param econStat EconStat
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function BrainEconomyCondition(econStat, compareOp, value)
    return {
        OBC,
        "BrainCompareEconomy",
        { value, econStat, compareOp }
    }
end

---Creates condition for matching category of a brain
---@param category EntityCategory
---@param compareOp CompareOp
---@param value number
---@return BuildCondition
function BrainCategoryCondition(category, compareOp, value)
    assert(not EntityCategoryEmpty(category), "Detected empty category! Condition won't be met!")
    return {
        OBC,
        "BrainCompareNumCategory",
        { value, category, compareOp }
    }
end
