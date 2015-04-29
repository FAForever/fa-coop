local MapUtil = import('/lua/ui/maputil.lua')

-- SetupSession loads the scenario data into a global. This is the One True Copy of scenario data.
-- This means that now is a really good time to fart about with scenario data.
local ReallySetupSession = SetupSession
function SetupSession()
    ReallySetupSession()

    -- Populate the HumanPlayers list in the scenario.
    -- The maps are inconsistent about what they declare to actually be in the list.
    -- So let's just rewrite the fucking thing ourselves.
    local imaginaryArmyList = MapUtil.GetArmies()

    -- A set to track which of the possibly-human armies are absent.
    local absentees = {}

    local newHumanPlayers = {}
    for i, armyName in imaginaryArmyList do
        WARN(i)
        WARN(armyName)
        WARN(repr(ScenarioInfo.ArmySetup[armyName]))
        if ScenarioInfo.ArmySetup[armyName] then
            table.insert(newHumanPlayers, armyName)
        else
            absentees[armyName] = true
        end
    end

    ScenarioInfo.HumanPlayers = newHumanPlayers

    -- Erase alliances that refer to armies that we don't have players for.
    -- This shouldn't really be necessary, but things catch fire trying to create alliances to
    -- nonexistent armies otherwise.
    for k, army in Scenario.Armies do
        if army.Alliances then
            local newAlliances = {}
            for allianceeName, allianceType in army.Alliances do
                if not absentees[allianceeName] then
                    newAlliances[allianceeName] = allianceType
                else
                    WARN("Dropping alliance from " .. k .. " to " .. allianceeName .. " of type " .. allianceType)
                end
            end
            army.Alliances = newAlliances
        end
    end
end

local ReallyBeginSession = BeginSession
function BeginSession()
    ReallyBeginSession()

    -- Hide all but the player army score, and do something mystereous to playable rects.
    for i = 2, table.getn(ScenarioInfo.HumanPlayers) do
        local armyId = ScenarioInfo.HumanPlayers[i]
        SetArmyShowScore(armyId, false)
        SetIgnorePlayableRect(armyId, true)
    end
end
