local FactionData = import('/lua/factions.lua')

function GetLeaderAndLocalFactions()
    local leaderFactionIndex = GetArmyBrain('Player'):GetFactionIndex()
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

--- Remove a unit restriction for all human players.
function RemoveRestrictionForAllHumans(categories, unlockDialogue, isSilent)
    for k, armyID in ScenarioInfo.HumanPlayers do
        RemoveRestriction(armyID, categories, isSilent)
    end
    if unlockDialogue then
        PlayUnlockDialogue()
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

function OperationCameraThread(location, heading, faction, track, unit, unlock, time)
    local cam = import('/lua/simcamera.lua').SimCamera('WorldCamera')
    LockInput()
    cam:UseGameClock()
    WaitTicks(1)
    -- Track the unit; not totally working properly yet
    if track and unit then
        local zoomVar = 50
        local pitch = .4
        if EntityCategoryContains( categories.uaa0310, unit ) then
            zoomVar = 150
            pitch = .3
        end
        local pos = unit:GetPosition()
        local marker = {
            orientation = VECTOR3( heading, .5, 0 ),
            position = { pos[1], pos[2] - 15, pos[3] },
            zoom = zoomVar,
        }

        -- cam:SnapToMarker(marker)
        -- cam:Spin( .03 )
        cam:NoseCam( unit, pitch, zoomVar, 1 )
    else
        -- Only do the 2.5 second wait if a faction is given; that means its a commander
        if faction then
            local marker = {
                orientation = VECTOR3( heading + 3.14149, .2, 0 ),
                position = { location[1], location[2]+1, location[3] },
                zoom = FLOAT( 15 ),
            }
            cam:SnapToMarker(marker)
            WaitSeconds(2.5)
        end
        if faction == 1 then -- uef
            marker = {
                orientation = {heading + 3.14149, .38, 0 },
                position = { location[1], location[2] + 7.5, location[3] },
                zoom = 58,
            }
        elseif faction == 2 then -- aeon
            marker = {
                orientation = VECTOR3( heading + 3.14149, .45, 0 ),
                position = { location[1], location[2], location[3] },
                zoom = FLOAT( 50 ),
            }
        elseif faction == 3 then -- cybran
            marker = {
                orientation = VECTOR3( heading + 3.14149, .45, 0 ),
                position = { location[1], location[2] + 5, location[3] },
                zoom = FLOAT( 45 ),
            }
        else
            marker = {
                orientation = VECTOR3( heading + 3.14149, .38, 0 ),
                position = location,
                zoom = 45,
            }
        end
        cam:SnapToMarker(marker)
        cam:Spin( .03 )
    end
    if (unlock) then
        WaitSeconds(time)
        -- Matt 11/27/06. This is fuctional now, but the snap is pretty harsh. Need someone else to look at it
        -- cam:SyncPlayableRect(ScenarioInfo.MapData.PlayableRect)
        -- local rectangle = ScenarioInfo.MapData.PlayableRect
        -- import('/lua/SimSync.lua').SyncPlayableRect(  Rect(rectangle[1],rectangle[2],rectangle[3],rectangle[4]) )
        cam:RevertRotation()
        -- cam:Reset()
        UnlockInput()
    end
end

function MissionNISCameraThread( unit, blendtime, holdtime, orientationoffset, positionoffset, zoomval )
    if not ScenarioInfo.NIS then
        ScenarioInfo.NIS = true
        local cam = import('/lua/simcamera.lua').SimCamera('WorldCamera')
        LockInput()
        cam:UseGameClock()
        WaitTicks(1)

        local position = unit:GetPosition()
        local heading = unit:GetHeading()
        local marker = {
            orientation = VECTOR3( heading + orientationoffset[1], orientationoffset[2], orientationoffset[3] ),
            position = { position[1] + positionoffset[1], position[2] + positionoffset[2], position[3] + positionoffset[3] },
            zoom = FLOAT( zoomval ),
        }
        cam:MoveToMarker(marker, blendtime)
        WaitSeconds(holdtime)
        cam:RevertRotation()
        UnlockInput()
        ScenarioInfo.NIS = false
    end
end

function OperationNISCameraThread( unitInfo, camInfo )
    if not ScenarioInfo.NIS or camInfo.overrideCam then
        local cam = import('/lua/simcamera.lua').SimCamera('WorldCamera')

        -- Utilities.UserConRequest('UI_RenderIcons false') -- turn strat icons off
        -- Utilities.UserConRequest('UI_RenderUnitBars false') -- turn lifebars off
        -- Utilities.UserConRequest('UI_RenResources false') -- turn deposit icons off

        local position, heading, vizmarker
        -- Setup camera information
        if camInfo.markerCam then
            position = unitInfo
            heading = 0
        else
            position = unitInfo.Position
            heading = unitInfo.Heading
        end

        ScenarioInfo.NIS = true

        LockInput()
        cam:UseGameClock()
        Sync.NISMode = 'on'

        if (camInfo.vizRadius) then
            local spec = {
                X = position[1],
                Z = position[3],
                Radius = camInfo.vizRadius,
                LifeTime = -1,
                Omni = false,
                Vision = true,
                Army = 1,
            }
            vizmarker = VizMarker(spec)
            WaitTicks(3) -- this seems to be needed to prevent them from popping in
        end

        if (camInfo.playableAreaIn) then
            SetPlayableArea(camInfo.playableAreaIn,false)
        end

        WaitTicks(1)

        local marker = {
            orientation = VECTOR3( heading + camInfo.orientationOffset[1], camInfo.orientationOffset[2], camInfo.orientationOffset[3] ),
            position = { position[1] + camInfo.positionOffset[1], position[2] + camInfo.positionOffset[2], position[3] + camInfo.positionOffset[3] },
            zoom = FLOAT( camInfo.zoomVal ),
        }

        -- Run the Camera
        cam:MoveToMarker( marker, camInfo.blendTime )
        WaitSeconds( camInfo.blendTime )

        -- Hold camera in place if desired
        if camInfo.spinSpeed and camInfo.holdTime then
            cam:HoldRotation()
        end

        -- Spin the Camera
        if camInfo.spinSpeed then
            cam:Spin( camInfo.spinSpeed )
        end

        -- Release the camera if it's not the end of the Op
        if camInfo.holdTime then
            WaitSeconds( camInfo.holdTime )
            if camInfo.resetCam then
                cam:Reset()
            else
                cam:RevertRotation()
            end
            UnlockInput()
            Sync.NISMode = 'off'

            -- Utilities.UserConRequest('UI_RenderIcons true') -- turn strat icons back on
            -- Utilities.UserConRequest('UI_RenderUnitBars true') -- turn lifebars back on
            -- Utilities.UserConRequest('UI_RenResources true') -- turn deposit icons back on

            ScenarioInfo.NIS = false
            -- Otherwise just unlock input, allowing them to click on the "Ok" button on the "Operation ended" box
        else
            UnlockInput()
        end

        -- cleanup
        if (camInfo.playableAreaOut) then
            SetPlayableArea(camInfo.playableAreaOut,false)
        end
        if (vizmarker) then
            vizmarker:Destroy()
        end
    end
end