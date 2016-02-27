local FactionData = import('/lua/factions.lua')

function GetLeaderAndLocalFactions()
    local leaderFactionIndex = GetArmyBrain('Player'):GetFactionIndex()
    local LeaderFaction = FactionData.Factions[leaderFactionIndex].Key
    ScenarioInfo.LeaderFaction = LeaderFaction

    local localFactionIndex = GetArmyBrain(GetFocusArmy()):GetFactionIndex()
    local LocalFaction = FactionData.Factions[localFactionIndex].Key
    ScenarioInfo.LocalFaction = LocalFaction

    return LeaderFaction, LocalFaction
end

--- Remove a unit restriction for all human players.
function RemoveRestrictionForAllHumans(categories, isSilent)
    for k, armyID in ScenarioInfo.HumanPlayers do
        RemoveRestriction(armyID, categories, isSilent)
    end

    PlayUnlockDialogue()
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

    RemoveRestrictionForAllHumans(categories, isSilent)
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
    if ScenarioInfo.OpEnded or ScenarioInfo.OperationEnding then
        return
    end
    ScenarioInfo.OperationEnding = true

    CDRDeathNISCamera(deadCommander)
    EndOperationSafety()

    local objectives = currentObjectives
    local continuation = function()
        ForkThread(
            function()
                WaitSeconds(1)
                UnlockInput()
                PlayerLose(nil, objectives)
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

function PlayerLose(dialogue, currentObjectives)
    if ScenarioInfo.OpEnded then
        return
    end

    EndOperationSafety()
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
    if ScenarioInfo[reminderSpec.CompletionFlag] then
        return
    end

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
