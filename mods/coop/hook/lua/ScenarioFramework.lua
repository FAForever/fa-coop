local FactionData = import('/lua/factions.lua')

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
    local unitCap = number / table.getn(ScenarioInfo.HumanPlayers)
    for _, player in ScenarioInfo.HumanPlayers do
        SetArmyUnitCap(player, unitCap)
    end
end

-- Utility functions for losing

--- Called when one of the players is killed
--
-- @param deadCommander A reference to the player ACU that got killed.
-- @param failureDialogue A VO to play explaining how much of a failure you are (if any).
-- @param currentObjectives The AssignedObjectives from the map.
function PlayerDeath(deadCommander, failureDialogue, currentObjectives)
    if ScenarioInfo.OpEnded then
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
    if failureDialogue then
        FlushDialogueQueue()
        Dialogue(failureDialogue, continuation, true)
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
        UnlockInput()
        EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
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
