function stringstarts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local reallyAssignAINames = AssignAINames
--- We want to do some work right before the game launches.
-- Handily, AssignAINames happens right then. So let's hook that. We're maybe going to insert some
-- AIs, though, so we need to run it afterwards.
function AssignAINames()
    -- A tiny bit of possible future-proofing...
    if not lobbyComm:IsHost() then
        WARN(debug.traceback(nil, ("AssignAINames by non-host! Somebody probably refactored something...")))
        return
    end

    -- For mission 2, apply GPG's official *mission 2 specific* mod....
    if gameInfo.GameOptions.ScenarioFile == '/maps/scca_coop_e02_v02/scca_coop_e02_v02_scenario.lua' then
        gameInfo.GameMods["e7846e9b-23a4-4b95-ae3a-fb69b289a585"] = true
        HostUpdateMods()
    end

    -- We do end up doing this twice now. *shrug*
    scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)

    -- Get the armies defined in the scenario.
    local scenarioArmies = MapUtil.ReallyGetArmies(scenarioInfo)

    -- Map the human army-names to their entries in PlayerOptions.
    local addedArmies = {
        Player = gameInfo.PlayerOptions[1],
        Coop1 = gameInfo.PlayerOptions[2],
        Coop2 = gameInfo.PlayerOptions[3],
        Coop3 = gameInfo.PlayerOptions[4]
    }

    -- We need to place each army at the index in PlayerOptions corresponding to the army's index in
    -- the map's army table. There are usually a bunch of other AI armies defined in the table,
    -- which we can probably ignore. I hope.
    -- Some dipshit decided not to standardise this.
    for armyIndex, armyName in scenarioArmies do
        if armyName == "Player" or stringstarts(armyName, "Coop") then
            gameInfo.PlayerOptions[armyIndex] = addedArmies[armyName]
        else
            -- Fill in the other armies with AIs.
            local newPlayer = LobbyComm.GetDefaultPlayerOptions(armyName)
            newPlayer.Human = false
            newPlayer.Faction = 1

            gameInfo.PlayerOptions[armyIndex] = newPlayer
        end
    end

    -- Finally, really assign the AI names (now we're finished farting about with AIs.
    reallyAssignAINames()
end

-- Do some extra logic at the end of CreateUI to delete some buttons that make no sense.
local ReallyCreateUI = CreateUI
function CreateUI()
    ReallyCreateUI()

    local isHost = lobbyComm:IsHost()
    if isHost then
        -- Presets are nonsense here
        GUI.restrictedUnitsOrPresetsBtn:Hide()

        -- The whole top row of host-only buttons also make no sense. Random map? Default options?
        -- Auto teams? What?
        GUI.randMap:Hide()
        GUI.autoTeams:Hide()
        GUI.defaultOptions:Hide()

        -- Expand the observer panel into the space.
        LayoutHelpers.AtLeftTopIn(GUI.observerPanel, GUI.panel, 512, 503)
        GUI.observerPanel.Width:Set(278)
        GUI.observerPanel.Height:Set(206)
    end

    -- Force the teams display to always stay hidden.
    for i= 1, LobbyComm.maxPlayerSlots do
        -- Called when the slot is shown or hidden. Any attempt to Show() the control results in it
        -- being hidden again. This neatly dodges the need to actually do anything clever.
        local teamControl = GUI.slots[i].team
        teamControl.Show = teamControl.Hide
        teamControl:Hide()
    end
end
