local FactionData = import('/lua/factions.lua')
local FailDialogue = nil
local OldGiveUnitToArmy = GiveUnitToArmy

function GiveUnitToArmy(unit, newArmyIndex, triggerOnGiven)
    local newBrain = GetArmyBrain(newArmyIndex)
    if (ScenarioInfo.Options.CommonArmy == 'true') and StringStartsWith(newBrain.Name, 'Player') then
        newArmyIndex = ScenarioInfo.HumanPlayers['Player1']
    end
    return OldGiveUnitToArmy(unit, newArmyIndex, triggerOnGiven)
end

function GetLeaderAndLocalFactions()
    local leaderFactionIndex = GetArmyBrain('Player1'):GetFactionIndex()
    ScenarioInfo.LeaderFaction = FactionData.Factions[leaderFactionIndex].Key

    local focusArmy = GetFocusArmy()
    if focusArmy ~= -1 then
        local localFactionIndex = GetArmyBrain(focusArmy):GetFactionIndex()
        ScenarioInfo.LocalFaction = FactionData.Factions[localFactionIndex].Key
    else
        ScenarioInfo.LocalFaction = ScenarioInfo.LeaderFaction
    end

    return ScenarioInfo.LeaderFaction, ScenarioInfo.LocalFaction
end

--- Add a unit restriction for all human players.
function AddRestrictionForAllHumans(categories)
    for _, armyID in ScenarioInfo.HumanPlayers do
        AddRestriction(armyID, categories)
    end
end

--- Remove a unit restriction for all human players.
function RemoveRestrictionForAllHumans(categories, unlockDialogue, isSilent)
    for k, armyID in ScenarioInfo.HumanPlayers do
        RemoveRestriction(armyID, categories, isSilent)
    end
    if unlockDialogue then
        PlayUnlockDialogue()
    end
end

--- Refresh build restriction of factories and engineers
-- When spawning base the HQ factories might not be spawned first causing support factories and engineers not being able to build things they should.
function RefreshRestrictions(brain)
    if type(brain) == 'string' then
        brain = GetArmyBrain(brain)
    elseif type(brain) == 'number' then
        brain = ArmyBrains[brain]
    end

    local units = brain:GetListOfUnits(categories.FACTORY + categories.ENGINEER, false)
    for _, v in units do
        v:updateBuildRestrictions()
    end
end

--- Remove a unit restriction for all human players with associated factional voiceover.
--
-- If the local player is of faction VOFaction, play voiceover then unlock the unit identified by
-- categories. Otherwise just unlock the unit.
--
-- @param categories The unit to unlock
-- @param VOFaction The faction the local player needs to be to hear the voiceover.
-- @param voiceover The ID of the voiceover to play, if applicable.
-- @param isSilent The issilent parameter to pass to RemoveRestriction.
function UnrestrictWithVoiceover(categories, VOFaction, voiceover, isSilent)
    if ScenarioInfo.LocalFaction == VOFaction or not VOFaction then
        Dialogue(voiceover)
    end

    RemoveRestrictionForAllHumans(categories, false, isSilent)
end

--- Remove a unit restriction for all human players with associated factional voiceover and delay
--
-- Exactly like UnrestrictWithVoiceover, but uses CreateTimerTrigger to delay execution by the
-- specified number of seconds.
function UnrestrictWithVoiceoverAndDelay(cats, VOFac, delay, VO, silent)
    -- Closure copies.
    local categories = cats
    local VOFaction = VOFac
    local voiceover = VO
    local isSilent = silent

    CreateTimerTrigger(
        function()
            UnrestrictWithVoiceover(categories, VOFaction, voiceover, isSilent)
        end,
        delay
    )
end

-- Sets unit capacity depending on number of the players
function SetSharedUnitCap(number)
    if ScenarioInfo.Options.CommonArmy == 'true' then
        if number >= 0 then
            SetArmyUnitCap(ScenarioInfo.HumanPlayers['Player1'], number)
        end
        return
    end
    -- Find out how many players are still alive
    local aliveCount = 0
    local alive = {}
    for _, index in ScenarioInfo.HumanPlayers do
        if not ArmyBrains[index]:IsDefeated() then
            aliveCount = aliveCount + 1
            table.insert(alive, index)
        end
    end

    -- Distribute the new unit cap among alive players
    if aliveCount > 0 then
        local totalCap = number
        if not totalCap or totalCap == 0 then
            local currentCap = GetArmyUnitCap(alive[1])
            totalCap = (aliveCount + 1) * currentCap
        end

        local newCap = math.floor(totalCap / aliveCount)
        for _, index in alive do
            SetArmyUnitCap(index, newCap)
        end
    end
end

-- Utility functions for losing

--- Called when one of the players is killed
--
-- @param deadCommander A reference to the player ACU that got killed.
-- @param failureDialogue A VO to play explaining how much of a failure you are (if any).
-- @param currentObjectives The AssignedObjectives from the map.
function PlayerDeath(deadCommander, failureDialogue, currentObjectives)
    if failureDialogue then
        FailDialogue = failureDialogue
    end
        local scenarioFuncPtr = debug.getinfo(2, 'f')
        scenarioFuncPtr = scenarioFuncPtr['func']
        local CommanderUnits = GetListOfHumanUnits(categories.COMMAND)
        for _, unit in CommanderUnits do
            if not table.find(unit.EventCallbacks['OnKilled'], scenarioFuncPtr) then
                CreateUnitDeathTrigger(scenarioFuncPtr, unit, true)
            end
        end
    if (table.getsize(CommanderUnits)-1 > 0) or (ScenarioInfo.OpEnded) then
        return
    end

    CDRDeathNISCamera(deadCommander)
    EndOperationSafety()

    local continuation = function()
        ForkThread(
            function()
                WaitSeconds(1)
                PlayerLose(nil, currentObjectives, true)
            end
        )
    end

    -- Play failure dialogue before continuing.
    if FailDialogue then
        FlushDialogueQueue()
        Dialogue(FailDialogue, continuation, true)
    else
        continuation()
    end
end

function PlayerLose(dialogue, currentObjectives, check)
    -- If we get here from PlayerDeath then just end the mission
    if not check then
        if ScenarioInfo.OpEnded then
            return
        end

        EndOperationSafety()
    end

    ScenarioInfo.OpComplete = false
    if currentObjectives then
        for k, v in currentObjectives do
            if v and v.Active then
                v:ManualResult(false)
            end
        end
    end

    -- Wait for any failure dialogue before exiting.
    local terminateMission = function()
        EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false, false)
    end

    if dialogue then
        FlushDialogueQueue()
        Dialogue(dialogue, terminateMission, true)
    else
        terminateMission()
    end
end

-- Reminder mechanism.
-- Each map can provide a "REMINDERS" table, each of which can provide reminders for each objective.

function PlayReminder(reminderSpec, index)
    local reminders = reminderSpec.Reminders

    -- There may not be any more reminders defined.
    local reminder = reminders[index]
    if not reminder then
        return
    end

    local nextDelay = reminder.Delay or reminderSpec.Delay

    local nextIndex = index + 1
    local spec = reminderSpec
    local function next()
        if ScenarioInfo[reminderSpec.CompletionFlag] then
            return
        end
        Dialogue(reminder.Dialogue)
        PlayReminder(spec, nextIndex)
    end

    CreateTimerTrigger(next, nextDelay)
end

--- Start running the reminders from the given reminder specification table. Once the corresponding
-- completion flag is set the messages will stop.
function StartReminders(remindersTable)
    PlayReminder(remindersTable, 1)
end

-- return number of <cat> of all human players, in <area> if specified
function GetNumOfHumanUnits(cat, area)
    return table.getn(GetListOfHumanUnits(cat, area))
end

-- return list of <cat> of all human players, in <area> if specified
function GetListOfHumanUnits(cat, area)
    local result = {}

    if area then
        if type(area) == 'string' then
            area = ScenarioUtils.AreaToRect(area)
        end

        local entities = GetUnitsInRect(area)

        if entities then
            local filteredList = EntityCategoryFilterDown(cat, entities)

            for _, unit in filteredList do
                for _, player in ScenarioInfo.HumanPlayers do
                    if(unit:GetAIBrain() == ArmyBrains[player]) then
                        table.insert(result, unit)
                    end
                end
            end
        end
    else
        for _, player in ScenarioInfo.HumanPlayers do
            result = table.cat(result, ArmyBrains[player]:GetListOfUnits(cat, false))
        end
    end
    return result
end

-- UI announcement for players, <secondaryText> is optional
function SimAnnouncement(text, secondaryText)
    Sync.CreateSimAnnouncement = {text = text, secondaryText = secondaryText}
end

-- Functions for randomly picking scenarios during the mission
function ChooseRandomBases()
    local data = ScenarioInfo.OperationScenarios['M' .. ScenarioInfo.MissionNumber].Bases

    if not ScenarioInfo.MissionNumber then
        error('*RANDOM BASE: ScenarioInfo.MissionNumber needs to be set.')
    elseif not data then
        error('*RANDOM BASE: No bases specified for mission number: ' .. ScenarioInfo.MissionNumber)
    end

    for _, base in data do
        local num = Random(1, table.getn(base.Types))

        base.CallFunction(base.Types[num])
    end
end

function ChooseRandomEvent(useDelay, customDelay)
    local data = ScenarioInfo.OperationScenarios['M' .. ScenarioInfo.MissionNumber].Events
    local num = ScenarioInfo.MissionNumber

    if not num then
        error('*RANDOM EVENT: ScenarioInfo.MissionNumber needs to be set.')
    elseif not data then
        error('*RANDOM EVENT: No events specified for mission number: ' .. num)
    end
    
    -- Randomly pick one event
    local function PickEvent(tblEvents)
        local availableEvents = {}
        local event

        -- Check available events
        for _, event in tblEvents do
            if not event.Used then
                table.insert(availableEvents, event)
            end
        end

        -- Pick one, mark as used
        local num = table.getn(availableEvents)

        if num ~= 0 then
            local event = availableEvents[Random(1, num)]
            event.Used = true

            return event
        else
            -- Reset availability and try to pick again
            for _, event in tblEvents do
                event.Used = false
            end
            
            return PickEvent(tblEvents)
        end
    end

    local event = PickEvent(data)

    ForkThread(StartEvent, event, num, useDelay, customDelay)
end

function StartEvent(event, missionNumber, useDelay, customDelay)
    if useDelay or useDelay == nil then
        local waitTime = customDelay or event.Delay -- Delay passed as a function parametr can over ride the delay from the OperationScenarios table
        local Difficulty = ScenarioInfo.Options.Difficulty

        if type(waitTime) == 'table' then
            WaitSeconds(waitTime[Difficulty])
        else
            WaitSeconds(waitTime)
        end
    end

    -- Check if the mission didn't end while we were waiting
    if ScenarioInfo.MissionNumber ~= missionNumber then
        return
    end

    event.CallFunction()
end