-- Ignore unit restrictions in all functions that are spawning units

local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local isCommonArmy = nil
local OldInitializeScenarioArmies = InitializeScenarioArmies
local OldCreatePlatoons = CreatePlatoons

----[  CreateArmyUnit                                                             ]--
----[                                                                             ]--
----[  Creates a named unit in an army.                                           ]--
function CreateArmyUnit(strArmy,strUnit)
    local tblUnit = FindUnit(strUnit,Scenario.Armies[strArmy].Units)
    if isCommonArmy and StringStartsWith(strArmy, 'Player') then
        strArmy = 'Player1'
    end
    local brain = GetArmyBrain(strArmy)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
    ScenarioFramework.IgnoreRestrictions(true)
    if nil ~= tblUnit then
        local unit = CreateUnitHPR(
            tblUnit.type,
            strArmy,
            tblUnit.Position[1], tblUnit.Position[2], tblUnit.Position[3],
            tblUnit.Orientation[1], tblUnit.Orientation[2], tblUnit.Orientation[3]
        )
        if unit:GetBlueprint().Physics.FlattenSkirt then
            unit:CreateTarmac(true, true, true, false, false)
        end
        local platoon
        if tblUnit.platoon ~= nil and tblUnit.platoon ~= '' then
            local i = 3
            while i <= table.getn(Scenario.Platoons[tblUnit.platoon]) do
                if tblUnit.Type == currTemplate[i][1] then
                    platoon = brain:MakePlatoon('None', 'None')
                    brain:AssignUnitsToPlatoon(platoon, {unit}, currTemplate[i][4], currTemplate[i][5])
                    break
                end
                i = i + 1
            end
        end
        local armyIndex = brain:GetArmyIndex()
        if ScenarioInfo.UnitNames[armyIndex] then
            ScenarioInfo.UnitNames[armyIndex][strUnit] = unit
        end
        unit.UnitName = strUnit
        if not brain.IgnoreArmyCaps then
            SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
        end
        ScenarioFramework.IgnoreRestrictions(false)
        return unit, platoon, tblUnit.platoon
    end
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    ScenarioFramework.IgnoreRestrictions(false)
    return nil
end

----[  InitializeScenarioArmies                                                   ]--
----[                                                                             ]--
----[                                                                             ]--
function InitializeScenarioArmies()
    isCommonArmy = ScenarioInfo.Options.CommonArmy == 'true'
    
    if isCommonArmy then
        local humansIndex = 0
        for strArmy, iArmy in ScenarioInfo.HumanPlayers do
            if GetArmyBrain(iArmy).BrainType ~= 'Human' then continue end
            humansIndex = humansIndex + 1
            if strArmy == 'Player1' then continue end
            ArmyGetHandicap(ScenarioInfo.HumanPlayers['Player1'] - 1, humansIndex - 1, true)
            ArmyGetHandicap(iArmy - 1, humansIndex - 1, false)
            if GetFocusArmy() == iArmy then
                ForkThread(
                function(leaderIndex)
                    SimConExecute('SetFocusArmy ' .. leaderIndex - 1)
                end, ScenarioInfo.HumanPlayers['Player1'])
            end
        end
    end
    return OldInitializeScenarioArmies()
end

function CreatePlatoons(strArmy, tblNode, tblResult, platoonList, currPlatoon, treeResult, balance)
    if isCommonArmy and StringStartsWith(strArmy, 'Player') then
        strArmy = 'Player1'
    end
    return OldCreatePlatoons(strArmy, tblNode, tblResult, platoonList, currPlatoon, treeResult, balance)
end

----[  CreateArmySubGroup                                                                      ]--
----[                                                                                          ]--
----[  Creates Army groups from a number of groups specified in order from the Units Hierarchy ]--
function CreateArmySubGroup(strArmy,strGroup,...)
    local tblNode = Scenario.Armies[strArmy].Units
    local tblResult = {}
    local treeResult = {}
    local platoonList = {}
    local brain = GetArmyBrain(strArmy)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
    ScenarioFramework.IgnoreRestrictions(true)
    for strName, tblData in pairs(tblNode.Units) do
        if 'GROUP' == tblData.type then
            if strName == strGroup then
                if arg['n'] >= 1 then
                    platoonList, tblResult, treeResult = CreateSubGroup(tblNode.Units[strName], strArmy, unpack(arg))
                else
                    platoonList, tblResult, treeResult = CreatePlatoons( strArmy, tblNode.Units[strName] )
                end
            end
        end
    end
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    ScenarioFramework.IgnoreRestrictions(false)
    if tblResult == nil then
        error('SCENARIO UTILITIES WARNING: No units found for for Army- ' .. strArmy .. ' Group- ' .. strGroup, 2)
    end
    return tblResult, treeResult, platoonList
end

----[ SpawnPlatoon                                                                ]--
----[ Spawns unit group and assigns to platoon it is a part of                    ]--
function SpawnPlatoon( strArmy, strGroup )
    local tblNode = FindUnitGroup( strGroup, Scenario.Armies[strArmy].Units )
    if nil == tblNode then
        error('SCENARIO UTILITIES WARNING: No Group found for Army- ' .. strArmy .. ' Group- ' .. strGroup, 2)
        return false
    end

    local brain = GetArmyBrain(strArmy)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
    ScenarioFramework.IgnoreRestrictions(true)
    local platoonName
    if nil ~= tblNode.platoon and '' ~= tblNode.platoon then
        platoonName = tblNode.platoon
    end

    local platoonList, tblResult, treeResult = CreatePlatoons(strArmy, tblNode)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    ScenarioFramework.IgnoreRestrictions(false)
    if tblResult == nil then
        error('SCENARIO UTILITIES WARNING: No units found for for Army- ' .. strArmy .. ' Group- ' .. strGroup, 2)
    end
    return platoonList[platoonName], platoonList, tblResult, treeResult
end

function SpawnTableOfPlatoons( strArmy, strGroup )
    local brain = GetArmyBrain(strArmy)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
    ScenarioFramework.IgnoreRestrictions(true)
    local platoonList, tblResult, treeResult = CreatePlatoons(strArmy,
                                                              FindUnitGroup( strGroup, Scenario.Armies[strArmy].Units))
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    ScenarioFramework.IgnoreRestrictions(false)
    if tblResult == nil then
        error('SCENARIO UTILITIES WARNING: No units found for for Army- ' .. strArmy .. ' Group- ' .. strGroup, 2)
    end
    return platoonList, tblResult, treeResult
end

----[  CreateArmyGroup                                                            ]--
----[                                                                             ]--
----[  Creates the specified group in game.                                       ]--
function CreateArmyGroup(strArmy,strGroup,wreckage, balance)
    local brain = GetArmyBrain(strArmy)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
    ScenarioFramework.IgnoreRestrictions(true)
    local platoonList, tblResult, treeResult = CreatePlatoons(strArmy,
                                                              FindUnitGroup( strGroup, Scenario.Armies[strArmy].Units ), nil, nil, nil, nil, balance )

    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    ScenarioFramework.IgnoreRestrictions(false)
    if tblResult == nil and strGroup ~= 'INITIAL' then
        error('SCENARIO UTILITIES WARNING: No units found for for Army- ' .. strArmy .. ' Group- ' .. strGroup, 2)
    end
    if wreckage then
        for num, unit in tblResult do
            unit:CreateWreckageProp(0)
            unit:Destroy()
        end
        return
    end
    return tblResult, treeResult, platoonList
end

-- CreateArmyTree
--
-- Returns tree of units created by the editor. 2nd return is table of units
function CreateArmyTree(strArmy, strGroup)
    local brain = GetArmyBrain(strArmy)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
    ScenarioFramework.IgnoreRestrictions(true)
    local platoonList, tblResult, treeResult = CreatePlatoons(strArmy,
                                                              FindUnitGroup(strGroup, Scenario.Armies[strArmy].Units) )
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    ScenarioFramework.IgnoreRestrictions(false)
    if tblResult == nil then
        error('SCENARIO UTILITIES WARNING: No units found for for Army- ' .. strArmy .. ' Group- ' .. strGroup, 2)
    end
    return treeResult, tblResult, platoonList
end

-- CreateArmyGroupAsPlatoon
--
-- Returns a platoon that is created out of all units in a group and its sub groups.
function CreateArmyGroupAsPlatoon(strArmy, strGroup, formation, tblNode, platoon, balance)
    if ScenarioInfo.LoadBalance.Enabled then
        --note that tblNode in this case is actually the callback function
        table.insert(ScenarioInfo.LoadBalance.PlatoonGroups, {strArmy, strGroup, formation, tblNode})
        return
    end

    local tblNode = tblNode or FindUnitGroup(strGroup, Scenario.Armies[strArmy].Units)
    if not tblNode then
        error('*SCENARIO UTILS ERROR: No group named- ' .. strGroup .. ' found for army- ' .. strArmy, 2)
    end
    if not formation then
        error('*SCENARIO UTILS ERROR: No formation given to CreateArmyGroupAsPlatoon')
    end

    if isCommonArmy and StringStartsWith(strArmy, 'Player') then
        strArmy = 'Player1'
    end

    local brain = GetArmyBrain(strArmy)
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
    ScenarioFramework.IgnoreRestrictions(true)
    local platoon = platoon or brain:MakePlatoon('','')
    local armyIndex = brain:GetArmyIndex()

    local unit = nil
    for strName, tblData in pairs(tblNode.Units) do
        if 'GROUP' == tblData.type then
            platoon = CreateArmyGroupAsPlatoon(strArmy, strGroup, formation, tblData, platoon)
            if not brain.IgnoreArmyCaps then
                SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
            end
            ScenarioFramework.IgnoreRestrictions(false)
        else
            unit = CreateUnitHPR( tblData.type,
                                 strArmy,
                                 tblData.Position[1], tblData.Position[2], tblData.Position[3],
                                 tblData.Orientation[1], tblData.Orientation[2], tblData.Orientation[3]
                             )
            if unit:GetBlueprint().Physics.FlattenSkirt then
                unit:CreateTarmac(true, true, true, false, false)
            end
            if ScenarioInfo.UnitNames[armyIndex] then
                ScenarioInfo.UnitNames[armyIndex][strName] = unit
            end
            unit.UnitName = strName
            brain:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', formation)

            if balance then
                ScenarioInfo.LoadBalance.Accumulator = ScenarioInfo.LoadBalance.Accumulator + 1

                if ScenarioInfo.LoadBalance.Accumulator > ScenarioInfo.LoadBalance.UnitThreshold/5 then
                    WaitSeconds(0)
                    ScenarioInfo.LoadBalance.Accumulator = 0
                end
            end
        end
    end
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
    ScenarioFramework.IgnoreRestrictions(false)
    return platoon
end