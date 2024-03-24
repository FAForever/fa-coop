---Starts platoon NukeAI detaching it from base manager for other nukes to avoid instance count limitaion
---@param platoon Platoon
function PlatoonNukeAI(platoon)
    LOG("started nuke AI")

    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local nukes = platoon:GetPlatoonUnits()
    aiBrain:DisbandPlatoon(platoon)

    ---@type Platoon
    platoon = aiBrain:MakePlatoon('', '')
    aiBrain:AssignUnitsToPlatoon(platoon, nukes, "Attack", "None")
    platoon:ForkAIThread(platoon.NukeAI)

    -- TODO
    -- ---@type AIBrain
    -- local aiBrain = platoon:GetBrain()
    -- local data = platoon.PlatoonData
    -- ---@type AdvancedBaseManager
    -- local bManager = aiBrain.BaseManagers[data.BaseName]
    -- if not bManager then return false end


    -- IssueGuard(bManager.ConstructionEngineers, platoon:GetPlatoonUnits()[1])

end
