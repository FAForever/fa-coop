local MapUtil = import('/lua/ui/maputil.lua')

-- The "imaginary" armies we synthesise for the coop players.
local imaginaryArmyList = MapUtil.GetArmies()
local imaginaryArmySet = {}
for k, v in imaginaryArmyList do
    imaginaryArmySet[v] = true
end

local ReallyOnCreateArmyBrain = OnCreateArmyBrain
function OnCreateArmyBrain(index, brain, name, nickname)
    ReallyOnCreateArmyBrain(index, brain, name, nickname)

    -- Stuff this army into the HumanPlayers set, if applicable.
    if imaginaryArmySet[name] then
        table.insert(ScenarioInfo.HumanPlayers, index)
    end
end

-- SetupSession loads the scenario data into a global. This is the One True Copy of scenario data.
-- This means that now is a really good time to fart about with scenario data.
local ReallySetupSession = SetupSession
function SetupSession()
    ReallySetupSession()

    -- Erase alliances that refer to armies that we don't have players for.
    -- This shouldn't really be necessary, but things catch fire trying to create alliances to
    -- nonexistent armies otherwise.
    for k, army in Scenario.Armies do
        if army.Alliances then
            local newAlliances = {}
            for allianceeName, allianceType in army.Alliances do
                if ScenarioInfo.ArmySetup[allianceeName] then
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

    -- Hide scores for AI's and make them able to place orders outside the playable rect
    for i = 1, table.getn(ArmyBrains) do
        if not table.find(ScenarioInfo.HumanPlayers, i) then
            SetArmyShowScore(i, false)
            SetIgnorePlayableRect(i, true)
        end
    end
end
