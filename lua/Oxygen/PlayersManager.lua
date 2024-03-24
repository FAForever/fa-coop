local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Factions = import('/lua/factions.lua').Factions
local Utils = import("Utils.lua")

---@alias Enhancement
--- | "AdvancedEngineering"
--- | "T3Engineering"
--- | "ResourceAllocation"
--- | "ResourceAllocationAdvanced"
--- | "EnhancedSensors"
--- | "StealthGenerator"
--- | "CloakingGenerator"
--- | "Shield"
--- | "ShieldGeneratorField"
--- | "EngineeringThroughput"
--- | "DamageStabilization"
--- | "DamageStabilizationAdvanced"
--- | "MicrowaveLaserGenerator"
--- | "HeatSink"
--- | "ShieldHeavy"
--- | "CrysalisBeam"
--- | "RegenAura"
--- | "AdvancedRegenAura"
--- | "NaniteTorpedoTube"
--- | "AdvancedCoolingUpgrade"
--- | "HighExplosiveOrdnance"
--- | "FocusConvertor"
--- | "SelfRepairSystem"
--- | "Switchback"
--- | "HeavyAntiMatterCannon"
--- | "Teleporter"
--- | "BlastAttack"
--- | "RateOfFire"


---@alias ACUEnhancementCommon
--- | "Teleporter"
--- | "AdvancedEngineering"
--- | "T3Engineering"
--- | "ResourceAllocation"

---@alias CybranEnhancement
--- | "StealthGenerator"
--- | "CloakingGenerator"
--- | "MicrowaveLaserGenerator"
--- | "NaniteTorpedoTube"
--- | "CoolingUpgrade"

---@alias UEFEnhancement
--- | "Shield"
--- | "ShieldGeneratorField"
--- | "DamageStabilization"
--- | "HeavyAntiMatterCannon"
--- | "LeftPod"
--- | "RightPod"
--- | "TacticalMissile"
--- | "TacticalNukeMissile"

---@alias AeonEnhancement
--- | "Shield"
--- | "ResourceAllocationAdvanced"
--- | "EnhancedSensors"
--- | "HeatSink"
--- | "ShieldHeavy"
--- | "CrysalisBeam"
--- | "ChronoDampener"

---@alias SeraphimEnhancement
--- | "ResourceAllocationAdvanced"
--- | "DamageStabilizationAdvanced"
--- | "RegenAura"
--- | "AdvancedRegenAura"
--- | "BlastAttack"
--- | "DamageStabilization"
--- | "Missile"
--- | "RateOfFire"





---@alias UnitMarkerName string
---@alias Enhancements Enhancement[]

---@class FactionUnitMap
---@field UEF UnitMarkerName?
---@field Cybran UnitMarkerName?
---@field Aeon UnitMarkerName?
---@field Seraphim UnitMarkerName?

---@class FactionEnhancementMap
---@field UEF (UEFEnhancement | ACUEnhancementCommon)[]?
---@field Cybran (CybranEnhancement |  ACUEnhancementCommon)[]?
---@field Aeon (AeonEnhancement | ACUEnhancementCommon)[]?
---@field Seraphim (SeraphimEnhancement | ACUEnhancementCommon)[]?



---@class PlayerSpawnData
---@field units FactionUnitMap
---@field color Color?
---@field enhancements FactionEnhancementMap?
---@field name string?
---@field delay number?
---@field faction string

---@alias PlayersData table<ArmyName,PlayerSpawnData>



local function MapPlayerNameToIndex()
    local armies = ScenarioInfo.Configurations.standard.teams[1].armies

    local map = {}
    local i = 1
    for iArmy, strArmy in armies do
        if StringStartsWith(strArmy, "Player") then
            map[strArmy] = i
            i = i + 1
        end
    end
    reprsl(map)
    return map
end

---@class CommonPlayersData
---@field enhancements FactionEnhancementMap?

---@class PlayersManager
---@field _players PlayersData
---@overload fun():PlayersManager
PlayersManager = ClassSimple
{
    ---Inits players with given options
    ---@param self PlayersManager
    ---@param players PlayerSpawnData[]|CommonPlayersData
    ---@return PlayersData
    Init = function(self, players)
        self._players = {}
        local tblArmy = ListArmies()
        local map = MapPlayerNameToIndex()

        for iArmy, strArmy in pairs(tblArmy) do
            local i = map[strArmy]
            if not i then continue end
            
            local faction = Factions[GetArmyBrain(strArmy):GetFactionIndex()].FactionInUnitBp
            local enhancements = nil
            if players[i].color then
                ScenarioFramework.SetArmyColor(iArmy, Utils.UnpackColor(players[i].color))
            end
            local unit = players[i].units[faction]
            if unit == nil then
                faction, unit = next(players[i].units)
            end
            if players[i].enhancements then
                enhancements = players[i].enhancements[faction]
            elseif players.enhancements then
                enhancements = players.enhancements[faction]
            end
            self._players[strArmy] = {
                color = players[i].color,
                unit = unit,
                enhancements = enhancements,
                name = players[i].name,
                delay = players[i].delay,
                faction = faction
            }

        end
        return self._players
    end,

    ---Spawns players' ACUs and returns list of them
    ---@param self PlayersManager
    ---@param effect 'Warp'|'Gate'
    ---@param playerDeathCallback fun(unit: Unit)?
    ---@return table<string,Unit>
    Spawn = function(self, effect, playerDeathCallback)
        local acus = {}
        for strArmy, player in self._players do
            if player.delay then
                WaitSeconds(player.delay)
            end
            acus[strArmy] = ScenarioFramework.SpawnCommander(
                strArmy,
                player.unit,
                effect,
                player.name or true,
                true,
                playerDeathCallback,
                player.enhancements
            )
        end
        return acus
    end,

    ---Warps in players' ACUs and returns list of them
    ---@param self PlayersManager
    ---@param playerDeathCallback fun(unit: Unit)?
    ---@return table<string,Unit>
    WarpIn = function(self, playerDeathCallback)
        return self:Spawn('Warp', playerDeathCallback)
    end,

    ---Gates in players' ACUs and returns list of them
    ---@param self PlayersManager
    ---@param playerDeathCallback fun(unit: Unit)?
    ---@return table<string,Unit>
    GateIn = function(self, playerDeathCallback)
        return self:Spawn('Gate', playerDeathCallback)
    end,

}
