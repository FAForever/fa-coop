function BrainsCompareNumCategory( airBrain, targetBrains, numReq, category, compareType )
    local numUnits = 0
    
    local targetBrainSet = {}
    for _,brain in targetBrains do
        if brain == 'HumanPlayers' then        
            local tblArmy = ListArmies()
            for _, strArmy in pairs(tblArmy) do
                if ScenarioInfo.ArmySetup[strArmy].Human then
                    targetBrainSet[ScenarioInfo.ArmySetup[strArmy].ArmyName] = true
                end
            end
        else
            targetBrainSet[brain] = true
        end
    end

    for brain,_ in targetBrainSet do
        for _,testBrain in ArmyBrains do
            if testBrain.Name == brain then
                numUnits = numUnits + testBrain:GetCurrentUnits(category)
            end
        end
    end

    if compareType == '>=' then
        if numUnits >= numReq then
            return true
        end
    elseif compareType == '<=' then
        if numUnits <= numReq then
            return true
        end
    elseif compareType == '>' then
        if numUnits > numReq then
            return true
        end
    elseif compareType == '<' then
        if numUnits < numReq then
            return true
        end
    end
    return false
end

--#############################################################################################################
-- function: FocusBrainBeingBuiltOrActiveCategoryCompare = BuildCondition   doc = "Please work function docs."
--
-- parameter 0: string  aiBrain     = "default_brain"
-- parameter 1: int numReq      = 0         doc = "docs for param1"
-- parameter 2: expr    categories  = categories.ALLUNITS           doc = "param2 docs"
-- parameter 3: string compareType = ">="
--
--#############################################################################################################
function FocusBrainBeingBuiltOrActiveCategoryCompare( aiBrain, numReq, categories, compareType )
    local num = 0
    local tblArmy = ListArmies()
    for iArmy, strArmy in pairs(tblArmy) do
        if ScenarioInfo.ArmySetup[strArmy].Human then
            local testBrain = GetArmyBrain(strArmy)
                for k,v in categories do
                    num = num + testBrain:GetBlueprintStat('Units_BeingBuilt', v)
                    num = num + testBrain:GetBlueprintStat('Units_Active', v)
                end            
        end
    end

    if not compareType or compareType == '>=' then
        if num >= numReq then
            return true
        end
    elseif compareType == '==' then
        if num == numReq then
            return true
        end
    elseif compareType == '<=' then
        if num <= numReq then
            return true
        end
    elseif compareType == '>' then
        if num > numReq then
            return true
        end
    elseif compareType == '<' then
        if num < numReq then
            return true
        end
    end
    return false
end