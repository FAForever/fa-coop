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

-- Changes the logic of sending number of slots to count only armies that contain "Player"
local oldSetGameOptions = SetGameOptions
function SetGameOptions(options, ignoreRefresh)
    oldSetGameOptions(options, ignoreRefresh)

    for key, val in options do
        if key == 'ScenarioFile' then
            if gameInfo.GameOptions.ScenarioFile and (gameInfo.GameOptions.ScenarioFile ~= '') then
                if DiskGetFileInfo(gameInfo.GameOptions.ScenarioFile) then
                    local scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)
                    if scenarioInfo and scenarioInfo.map and (scenarioInfo.map ~= '') then
                        -- Coop change, count only player slots instead of the whole armies table
                        local num = 0
                        for _, army in scenarioInfo.Configurations.standard.teams[1].armies do
                            if StringStartsWith(army, "Player") then
                                num = num + 1
                            end
                        end
                        GpgNetSend('GameOption', 'Slots', num)
                        return
                    end
                end
            end
        end
    end
end