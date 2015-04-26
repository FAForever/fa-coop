function stringstarts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

-- While we're in the lobby, let's pretend the seraphim don't exist.
-- This elegantly makes absolutely everything - including randomised factions - work correctly.
local newFactionData = {}
for index, tbl in FactionData.Factions do
    if tbl.Key ~= "seraphim" then
        table.insert(newFactionData, tbl)
    end
end

local realFactionData = FactionData.Factions
FactionData.Factions = newFactionData

local reallySendObserverList = sendObserversList
-- We need to rearrange some players right before we start.
function sendObserversList(arg)
    -- The most brittle thing in the entire universe.
    -- The only time this is called without arguments is the time we want in LaunchGame.
    -- This is the least insane hook-point for a pre-WVT-flattening LaunchGame() tweak. It'll work.
    if arg then
        reallySendObserverList(arg)
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
        Player = 1,
        Coop1 = 2,
        Coop2 = 3,
        Coop3 = 4
    }

    -- We need to place each army at the index in PlayerOptions corresponding to the army's index in
    -- the map's army table. There are usually a bunch of other AI armies defined in the table,
    -- which we can probably ignore. I hope.
    -- Some dipshit decided not to standardise this.
    for armyIndex, armyName in scenarioArmies do
        if armyName == "Player" or stringstarts(armyName, "Coop") then
            local ourArmyIndex = addedArmies[armyName]
            if gameInfo.PlayerOptions[ourArmyIndex] then
                HostUtils.SwapPlayers(ourArmyIndex, armyIndex)
            end
        else
            -- Fill in the other armies with AIs.
            HostUtils.AddAI("", "adaptive", armyIndex)
        end
    end

    -- ... Aaand sacrifice a goat.
    reallySendObserverList()
end

-- Some extra magic is also needed at launch-time for everyone.
local GameReallyLaunched = lobbyComm.GameLaunched
lobbyComm.GameLaunched = function(self)
    -- Okay, okay, the seraphim really exist. Let's not break anything by keeping this pretense up.
    FactionData.Factions = realFactionData

    scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)

    GameReallyLaunched()
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