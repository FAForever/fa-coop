--- We want to do some work right before the game launches.
-- Handily, AssignAINames happens right then. So let's hook that. We're maybe going to insert some
-- AIs, though, so we need to run it afterwards.

local reallyAssignAINames = AssignAINames
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

    -- A list of the armies we've added (the three additional co-op players)
    local addedArmies = {}
    for spot, army in gameInfo.PlayerOptions do
        if spot ~= 1 then
            table.insert(addedArmies, army)
        end
    end

    local addedArmyIndex = 1
    for armyIndex, armyName in scenarioArmies do
        -- The scenario may define other armies.
        -- Until this point, we've behaved as if the scenario only contains the fixed set:
        -- {"Player", "Coop1", "Coop2", "Coop3"}
        -- This fixed set is the armies we use for the four players, though the scenario may have a
        -- variety of other armies in it, which we here populate with AIs.
        -- We also must place our players in the right slot in PlayerOptions for their corresponding
        -- army, which is also handled here.
        if armyName ~= "Player" and not stringstarts(armyName, "Coop") then
            local newPlayer = LobbyComm.GetDefaultPlayerOptions(armyName)
            newPlayer.Human = false
            newPlayer.Faction = 1

            gameInfo.PlayerOptions[armyIndex] = newPlayer
        elseif stringstarts(armyName, "Coop") and table.getn(addedArmies) >= addedArmyIndex then
            gameInfo.PlayerOptions[armyIndex] = addedArmies[addedArmyIndex]
            addedArmyIndex = addedArmyIndex + 1
        end
    end

    -- Finally, really assign the AI names (now we're finished farting about with AIs.
    reallyAssignAINames()
end
