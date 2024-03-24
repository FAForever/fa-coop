local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local BaseManagerThreads = import("/lua/ai/opai/BaseManagerPlatoonThreads.lua")



---comment
---@param platoon Platoon
function ExpansionPlatoon(platoon)
    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData
    local expansionData = data.ExpansionData



    if data.UseTransports then
        if not ScenarioPlatoonAI.GetLoadTransports(platoon) then
            return
        end
    end

    -- Set Ready and hold for Wait variable
    if not ScenarioPlatoonAI.ReadyWaitVariables(data) then
        return
    end

    -- Move and unload units
    if not ScenarioPlatoonAI.StartBaseTransports(platoon, data, aiBrain) then
        return
    end

    -- assert(aiBrain.BaseManagers[expansionData.BaseName], "Base manager ".. expansionData.BaseName .. " not found")

    -- platoon:MoveToLocation(aiBrain.BaseManagers[expansionData.BaseName].Position, false)

    platoon.PlatoonData = expansionData
    Oxygen.BaseManager.Threads.BaseManagerEngineerPlatoonSplit(platoon)
end
