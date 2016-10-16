-------------------
--Trigger Functions
-------------------


----- Threadfunction that runs the callbackFunction when more/less than a number of units of category owned by any army in aiBrains is inside any of the areas in rectangleTable.
----- Used inderictly by ScenarioFramework.CreateAreaTrigger and ScenarioFramework.CreateMultipleAreaTrigger
-- callbackFunction -> function called when the criteria is met
-- rectangleTable -> table containing all the areas used. (Either strings of area names or rectangles)
-- category -> description of the type units that are counted
-- onceOnly -> boolean stating if the function needs to be called only once.
-- invert -> boolean stating if it the amount needs to be greater/lesser than. (true=greater or equal, false is lesser)
-- aiBrains -> table containing the names(string) of the armies involved. (Or an ArmyBrain to allow old calls to still work)
-- number -> the amount of units threshold
-- requireBuilt -> boolean stating if the units have to be build or can be underconstruction.
-- name -> ???
---- Returns: nothing
function AreaTriggerThread(callbackFunction, rectangleTable, category, onceOnly, invert, aiBrains, number, requireBuilt, name)
    local brainsList = ConvertAIBrains(aiBrains)    
    
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
                if contains and IsEntityOfGroup(v,brainsList) and (not requireBuilt or (requireBuilt and not v:IsBeingBuilt())) then
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


----- Threadfunction that runs the callbackFunction when atleast 1 of the armies in aiBrains has a threat level around unit that is high/low enough.
----- Used inderictly by ScenarioFramework.CreateThreatTriggerAroundUnit
-- callbackFunction -> function called when the criteria is met
-- aiBrains -> table containing the names(string) of the armies involved. (Or an ArmyBrain to allow old calls to still work)
-- unit -> the unit around which the threat is calculated
-- rings -> number value used for aiBrain:GetThreatAtPosition
-- onceOnly -> boolean stating if the function needs to be called only once.
-- value -> the threat level threshold
-- greater -> boolean stating if it the amount needs to be greater/lesser than. (true=greater or equal, false is lesser)
-- name -> ???
---- Returns: nothing
function ThreatTriggerAroundUnitThread(callbackFunction, aiBrains, unit, rings, onceOnly, value, greater, name)
    ThreatTriggerAtPositionLoop(callbackFunction, (function() return unit:IsDead() end), (function() return unit:GetPosition() end), aiBrains, rings, onceOnly, value, greater, name)
end

----- Threadfunction that runs the callbackFunction when atleast 1 of the armies in aiBrains has a threat level around position that is high/low enough
----- Used inderictly by ScenarioFramework.CreateThreatTriggerAroundPosition
-- callbackFunction -> function called when the criteria is met
-- aiBrains -> table containing the names(string) of the armies involved. (Or an ArmyBrain to allow old calls to still work)
-- posVector -> the position around which the threat is calculated (marker name(string) or a positionVector)
-- rings -> number value used for aiBrain:GetThreatAtPosition
-- onceOnly -> boolean stating if the function needs to be called only once.
-- value -> the threat level threshold
-- greater -> boolean stating if it the amount needs to be greater/lesser than. (true=greater or equal, false is lesser)
-- name -> ???
---- Returns: nothing
function ThreatTriggerAroundPositionThread(callbackFunction, aiBrains, posVector, rings, onceOnly, value, greater, name)
    if type(posVector) == 'string' then
        posVector = ScenarioUtils.MarkerToPosition(posVector)
    end
    
    ThreatTriggerAtPositionLoop(callbackFunction, (function() return true end), (function() return posVector end), aiBrains, rings, onceOnly, value, greater, name)
end

function ThreatTriggerAtPositionLoop(callbackFunction, loopFunction, positionFunction, aiBrains, rings, onceOnly, value, greater, name)
    local armyBrainsList = ConvertAIBrains(aiBrains,true)
    
    while loopFunction() do
        highestThreat = -1 --I expect threat to be positive values, correct me if wrong
        for _,armyBrain in armyBrainsList do
            local threat = armyBrain:GetThreatAtPosition(positionFunction(), rings, true)
            highestThreat = math.max(threat,highestThreat)
        end
        
        if greater and highestThreat >= value then
            if name then
                callbackFunction(TriggerManager, name)
            else
                callbackFunction()
            end
            if onceOnly then
                return
            end
        elseif not greater and highestThreat <= value then
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

----- Threadfunction that runs the callbackFunction when unit gets near a unit of category owned by any army in aiBrains
----- Used inderictly by ScenarioFramework.CreateThreatTriggerAroundPosition
-- callbackFunction -> function called when the criteria is met
-- unit -> the unit which has to be near a unit of category
-- aiBrains -> table containing the names(string) of the armies involved. (Or an ArmyBrain to allow old calls to still work)
-- category -> description of the type units that are checked for.
-- distance -> the maximum distance unit has to be from the unit of category to run the callbackFunction
-- name -> ???
---- Returns: nothing
function CreateUnitNearTypeTriggerThread( callbackFunction, unit, aiBrains, category, distance, name )
    local armyBrainsList = ConvertAIBrains(aiBrains,true)
    
    local fired = false
    while not fired do
        if unit:IsDead() then
            return
        else
            local position = unit:GetPosition()
            for _,brain in armyBrainsList do
                for _,catUnit in brain:GetListOfUnits(category, false) do
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
        end
        WaitSeconds(.5)
    end
end

----------------
--Help functions
----------------

---Converts aiBrains to a usable table of strings or ArmyBrains: 
-----removing "HumanPlayers" and putting in the appropriate armies
-----converting single ArmyBrain values into a single element table
--aiBrains -> the value that needs to be converted (either a list of armynames (can contain "HumanPlayers") or a single ArmyBrain)
--asArmyBrain -> boolean stating whether the result needs to contain strings or ArmyBrains
----Returns: table of strings or ArmyBrains based on the information contained in aiBrains
function ConvertAIBrains(aiBrains, asArmyBrain)
    local brainsList = {}
    for _,army in ArmyBrains do
        if army == aiBrains then
            if asArmyBrain then
                return {aiBrains}
            else
                return {aiBrains.Name}
            end
        end
    end
    
    for _,brain in aiBrains do
        if type(brain) != 'string' then
            error('*TRIGGER ERROR: AIBrains in tables need to be of type string, provided type: ' .. type(brain))
        else
            if brain == 'HumanPlayers' then
                local tblArmy = ListArmies()
                for iArmy, strArmy in pairs(tblArmy) do
                    if ScenarioInfo.ArmySetup[strArmy].Human then
                        table.insert(brainsList, ScenarioInfo.ArmySetup[strArmy].ArmyName)
                    end
                end
            else
                table.insert(brainsList,brain)
            end
        end
    end
    
    if asArmyBrain then
        local aiBrainsNamelist = brainsList
        brainsList = {}
        for _,aiBrainName in list do
            for _,army in ArmyBrains do
                if aiBrainName == army.Name then
                    table.insert(brainsList,army)
                end
            end
        end
    end
    
    return brainsList
end

function IsEntityOfGroup(entity, brains)
    for _,brain in brains do
        if (entity and brain and entity:GetAIBrain().Name == brain) then
            return true
        end
    end
    return false
end