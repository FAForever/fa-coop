
function AreaTriggerThread(callbackFunction, rectangleTable, category, onceOnly, invert, aiBrain, number, requireBuilt, name)
    local recTable = {}
    for k,v in rectangleTable do
        if type(v) == 'string' then
            table.insert(recTable,ScenarioUtils.AreaToRect(v))
        else
            table.insert(recTable, v)
        end
    end
    while true do
        local amount = 0
        local totalEntities = {}
        for k, v in recTable do
            local entities = GetUnitsInRect( v )
            if entities then
                for ke, ve in entities do
                    totalEntities[table.getn(totalEntities) + 1] = ve
                end
            end
        end
        local triggered = false
        local triggeringEntity
        local numEntities = table.getn(totalEntities)
        if numEntities > 0 then
            for k, v in totalEntities do
                local contains = EntityCategoryContains(category, v)
                if contains and (aiBrain and v:GetAIBrain() == aiBrain) and (not requireBuilt or (requireBuilt and not v:IsBeingBuilt())) then
                    amount = amount + 1
                    --If we want to trigger as soon as one of a type is in there, kick out immediately.
                    if not number then
                        triggeringEntity = v
                        triggered = true
                        break
                    --If we want to trigger on an amount, then add the entity into the triggeringEntity table
                    --so we can pass that table back to the callback function.
                    else
                        if not triggeringEntity then
                            triggeringEntity = {}
                        end
                        table.insert(triggeringEntity, v)
                    end
                end
            end
        end
        --Check to see if we have a triggering amount inside in the area.
        if number and ((amount >= number and not invert) or (amount < number and invert)) then
            triggered = true
        end
        --TRIGGER IF:
        --You don't want a specific amount and the correct unit category entered
        --You don't want a specific amount, there are no longer the category inside and you wanted the test inverted
        --You want a specific amount and we have enough.
        if ( triggered and not invert and not number) or (not triggered and invert and not number) or (triggered and number) then
            if name then
                callbackFunction(TriggerManager, name, triggeringEntity)
            else
                callbackFunction(triggeringEntity)
            end
            if onceOnly then
                return
            end
        end
        WaitTicks(1)
    end
end


function ThreatTriggerAroundUnitThread(callbackFunction, aiBrain, unit, rings, onceOnly, value, greater, name)
    while not unit:IsDead() do
        local threat = aiBrain:GetThreatAtPosition(unit:GetPosition(), rings, true)
        if greater and threat >= value then
            if name then
                callbackFunction(TriggerManager, name)
            else
                callbackFunction()
            end
            if onceOnly then
                return
            end
        elseif not greater and threat <= value then
            if name then
                callbackFunction(TriggerManager, name)
            else
                callbackFunction()
            end
            if onceOnly then
                return
            end
        end
        WaitSeconds(0.5)
    end
end


function ThreatTriggerAroundPositionThread(callbackFunction, aiBrain, posVector, rings, onceOnly, value, greater, name)
    if type(posVector) == 'string' then
        posVector = ScenarioUtils.MarkerToPosition(posVector)
    end
    while true do
        local threat = aiBrain:GetThreatAtPosition(posVector, rings, true)
        if greater and threat >= value then
            if name then
                callbackFunction(TriggerManager, name)
            else
                callbackFunction()
            end
            if onceOnly then
                return
            end
        elseif not greater and threat <= value then
            if name then
                callbackFunction(TriggerManager, name)
            else
                callbackFunction()
            end
            if onceOnly then
                return
            end
        end
        WaitSeconds(0.5)
    end
end

function CreateUnitNearTypeTriggerThread( callbackFunction, unit, brain, category, distance, name )
    local fired = false
    while not fired do
        if unit:IsDead() then
            return
        else
            local position = unit:GetPosition()
            for k,catUnit in brain:GetListOfUnits(category, false) do
                if (VDist3( position, catUnit:GetPosition() ) < distance) and not catUnit:IsBeingBuilt() then
                    fired = true
                    if name then
                        callbackFunction(TriggerManager, name, unit, catUnit)
                        return
                    else
                        callbackFunction(unit, catUnit)
                        return
                    end
                end
            end
        end
        WaitSeconds(.5)
    end
end