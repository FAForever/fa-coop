local ScenarioFramework = import('/lua/ScenarioFramework.lua')

Add = ScenarioFramework.AddRestriction
Remove = ScenarioFramework.RemoveRestriction

---Ignores build restrictions during callback
---@param callback function
function Ignore(callback)
    ScenarioFramework.IgnoreRestrictions(true)
    callback()
    ScenarioFramework.IgnoreRestrictions(false)
end
