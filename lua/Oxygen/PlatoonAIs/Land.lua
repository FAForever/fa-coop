local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')


function PlatoonAttackWithTransportsThreadReturnToPool(platoon, landingChain, attackChain, instant, moveChain)
    ---@type AIBrain
    local aiBrain = platoon:GetBrain()
    local allUnits = platoon:GetPlatoonUnits()
    local startPos = platoon:GetPlatoonPosition()
    local units = {}
    local transports = {}
    for _, unit in allUnits do
        if EntityCategoryContains(categories.TRANSPORTATION, unit) then
            table.insert(transports, unit)
        else
            table.insert(units, unit)
        end
    end

    local landingLocs = ScenarioUtils.ChainToPositions(landingChain)
    local landingLocation = table.random(landingLocs)

    if instant then
        ScenarioFramework.AttachUnitsToTransports(units, transports)
        if moveChain and
            not ScenarioPlatoonAI.MoveAlongRoute(platoon, ScenarioUtils.ChainToPositions(moveChain)) then
            return
        end
        IssueTransportUnload(transports, landingLocation)
        local attached = true
        while attached do
            WaitSeconds(3)
            local allDead = true
            for _, v in transports do
                if not v.Dead then
                    allDead = false
                    break
                end
            end
            if allDead then return end

            attached = false
            for _, unit in units do
                if not unit.Dead and unit:IsUnitState('Attached') then
                    attached = true
                    break
                end
            end
        end
    elseif not import("/lua/ai/aiutilities.lua").UseTransports(units, transports, landingLocation) then
        return
    end

    local attackLocs = ScenarioUtils.ChainToPositions(attackChain)
    for _, loc in attackLocs do
        IssuePatrol(units, loc)
    end

    if not instant then return end

    IssueMove(transports, startPos)

    local tPool = aiBrain:GetPlatoonUniquelyNamedOrMake('TransportPool')
    aiBrain:AssignUnitsToPlatoon(tPool, transports, 'Unassigned', 'None')
end

---@param platoon Platoon
---@param landingChain MarkerChain
---@param attackChain MarkerChain
---@param instant? boolean
---@param moveChain? MarkerChain
function AttackWithTransportsReturnToPool(platoon, landingChain, attackChain, instant, moveChain)
    ForkThread(PlatoonAttackWithTransportsThreadReturnToPool, platoon, landingChain, attackChain, instant, moveChain)
end
