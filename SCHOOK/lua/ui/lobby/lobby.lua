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

-- Some extra magic is also needed at launch-time for everyone.
local GameReallyLaunched = lobbyComm.GameLaunched
lobbyComm.GameLaunched = function(self)
    -- Okay, okay, the seraphim really exist. Let's not break anything by keeping this pretense up.
    FactionData.Factions = realFactionData

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
