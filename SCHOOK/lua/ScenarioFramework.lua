local FactionData = import('/lua/factions.lua')

-- ZeP decided that having map scripts call this function to set up the scenario was a good idea.
-- *sigh*
-- We can kill this once we've updated all the maps to not be stupid.
-- It would probably be worth bringing the maps into a VCS somewhere first...
function fillCoop() end

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
end
