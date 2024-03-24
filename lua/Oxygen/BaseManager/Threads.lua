local Buff = import("/lua/sim/Buff.lua")
local BaseManagerThreads = import("/lua/ai/opai/BaseManagerPlatoonThreads.lua")

---@type UnitDestroyedTrigger
local engineerDestroyedTrigger = Oxygen.Triggers.UnitDestroyedTrigger(BaseManagerThreads.BaseManagerSingleDestroyed)


--- Split the platoon into single unit platoons
---@param platoon Platoon
function BaseManagerEngineerPlatoonSplit(platoon)
    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local units = platoon:GetPlatoonUnits()
    local baseName = platoon.PlatoonData.BaseName
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then
        aiBrain:DisbandPlatoon(platoon)
        return
    end
    for _, v in units do
        if v.Dead then
            continue
        end

        if EntityCategoryContains(categories.ENGINEER, v) and
            bManager.EngineerQuantity > bManager.CurrentEngineerCount then
            if bManager.EngineerBuildRateBuff then
                Buff.ApplyBuff(v, bManager.EngineerBuildRateBuff)
            end

            ---@type Platoon
            local engPlat = aiBrain:MakePlatoon('', '')
            aiBrain:AssignUnitsToPlatoon(engPlat, { v }, 'Support', 'None')
            engPlat.PlatoonData = table.deepcopy(platoon.PlatoonData)
            v.BaseName = baseName
            engPlat:ForkAIThread(BaseManagerThreads.BaseManagerSingleEngineerPlatoon)

            if not EntityCategoryContains(categories.COMMAND, v) then
                bManager:AddCurrentEngineer()

                -- Only add death callback if it hasnt been set yet
                if not v.Subtracted then
                    engineerDestroyedTrigger:Add(v)
                end

                -- If the base is building engineers, subtract one from the amount being built
                if bManager:GetEngineersBuilding() > 0 then
                    bManager:SetEngineersBuilding(-1)
                end
            end
        end
    end

    aiBrain:DisbandPlatoon(platoon)
end
