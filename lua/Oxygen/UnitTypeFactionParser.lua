---@alias UnitType
--- | 'T3Transport'
--- | 'MobileMissilePlatform'
--- | 'MobileShield'
--- | 'HeavyBot'
--- | 'MobileFlak'
--- | 'MobileHeavyArtillery'
--- | 'MobileStealth'
--- | 'SiegeBot'
--- | 'MobileBomb'
--- | 'RangeBot'
--- | 'LightArtillery'
--- | 'AmphibiousTank'
--- | 'LightTank'
--- | 'HeavyMobileAntiAir'
--- | 'MobileMissile'
--- | 'HeavyTank'
--- | 'MobileAntiAir'
--- | 'LightBot'
--- | 'T1Transport'
--- | 'T2Transport'
--- | 'Interceptor'
--- | 'LightGunship'
--- | 'Bomber'
--- | 'TorpedoBomber'
--- | 'GuidedMissile'
--- | 'Gunship'
--- | 'CombatFighter'
--- | 'StratBomber'
--- | 'AirSuperiority'
--- | 'HeavyGunship'
--- | 'HeavyTorpedoBomber'
--- | 'T3Transport'
--- | 'T2Transport'
--- | 'T1Transport'
--- | 'T3Engineer'
--- | 'T2Engineer'
--- | 'CombatEngineer'
--- | 'T1Engineer'
--- | 'MobileShield'
--- | 'Battleship'
--- | 'Destroyer'
--- | 'Cruiser'
--- | 'Frigate'
--- | 'Submarine'
--- | 'Frigate'
--- | 'T2Submarine'
--- | 'UtilityBoat'
--- | 'Carrier'
--- | 'NukeSubmarine'
--- | 'AABoat'
--- | 'MissileShip'
--- | 'T3Submarine'
--- | 'TorpedoBoat'
--- | 'BattleCruiser'
--- | "SACU"
--- | "SACU_RAS"
--- | "SACU_COMBAT"
--- | "SACU_RAMBO"
--- | "SACU_ENGINEER"
--- | "SACU"



---@class FactionUnitIds
---@field UEF UnitId
---@field Cybran UnitId
---@field Aeon UnitId
---@field Seraphim UnitId


---comment
---@param unitId UnitId
---@param factionIndex Faction
---@return UnitId|nil
function FactionConvert(unitId, factionIndex)
    unitId = unitId:lower()
    local newID = unitId

    if factionIndex == 2 then
        if unitId == 'uel0203' then
            newID = 'xal0203'
        elseif unitId == 'xes0204' then
            newID = 'xas0204'
        elseif unitId == 'uea0305' then
            newID = 'xaa0305'
        elseif unitId == 'xel0305' then
            newID = 'xal0305'
        elseif unitId == 'delk002' then
            newID = 'dalk003'
        else
            newID = string.gsub(unitId, 'ue', 'ua', 1)
        end
    elseif factionIndex == 3 then
        if unitId == 'uea0305' then
            newID = 'xra0305'
        elseif unitId == 'xes0204' then
            newID = 'xrs0204'
        elseif unitId == 'xes0205' then
            newID = 'xrs0205'
        elseif unitId == 'xel0305' then
            newID = 'xrl0305'
        elseif unitId == 'uel0307' then
            newID = 'url0306'
        elseif unitId == 'del0204' then
            newID = 'drl0204'
        elseif unitId == 'delk002' then
            newID = 'drlk001'
        else
            newID = string.gsub(unitId, 'ue', 'ur', 1)
        end
    elseif factionIndex == 4 then
        if unitId == 'uel0106' then
            newID = 'xsl0201'
        elseif unitId == 'xel0305' then
            newID = 'xsl0305'
        elseif unitId == 'delk002' then
            newID = 'dslk004'
        else
            newID = string.gsub(unitId, 'ue', 'xs', 1)
        end
    end
    if __blueprints[newID] then
        return newID
    end
    return nil
end

---@param unitId any
---@return FactionUnitIds
local function CreateFactionTable(unitId)
    return {
        UEF = FactionConvert(unitId, 1),
        Cybran = FactionConvert(unitId, 2),
        Aeon = FactionConvert(unitId, 3),
        Seraphim = FactionConvert(unitId, 4),
    }
end

---@type table<UnitType, FactionUnitIds>
unitTypes = {
    ['MobileMissilePlatform'] =
    {
        UEF = "xel0306",
    },
    ['MobileShield'] = CreateFactionTable("UEL0307"),
    ['HeavyBot'] = CreateFactionTable("XEL0305"),
    ['MobileFlak'] = CreateFactionTable("UEL0205"),
    ['MobileHeavyArtillery'] = CreateFactionTable("UEL0304"),
    ['MobileStealth'] =
    {
        Cybran = "url0306",
    },
    ['MobileBomb'] =
    {
        Cybran = "xrl0302",
    },
    ['SiegeBot'] = CreateFactionTable("UEL0303"),
    ['RangeBot'] = CreateFactionTable("DEL0204"),
    ['LightArtillery'] = CreateFactionTable("UEL0103"),
    ['AmphibiousTank'] = CreateFactionTable("UEL0203"),
    ['LightTank'] = CreateFactionTable("UEL0201"),
    ['HeavyMobileAntiAir'] = CreateFactionTable("DELK002"),
    ['MobileMissile'] = CreateFactionTable("UEL0111"),
    ['HeavyTank'] = CreateFactionTable("UEL0202"),
    ['MobileAntiAir'] = CreateFactionTable("UEL0104"),
    ['LightBot'] = CreateFactionTable("UEL0106"),

    --Air
    ['Interceptor'] = CreateFactionTable("UEA0102"),
    ['LightGunship'] =
    {
        Cybran = "xra0105",
    },
    ['Bomber'] = CreateFactionTable("UEA0103"),
    ['TorpedoBomber'] = CreateFactionTable("UEA0204"),
    ['GuidedMissile'] =
    {
        Aeon = "daa0206",
    },
    ['Gunship'] = CreateFactionTable("UEA0203"),
    ['CombatFighter'] =
    {
        UEF = "dea0202",
        Cybran = "dra0202",
        Aeon = "xaa0202",
        Seraphim = "xsa0202",
    },
    ['StratBomber'] = CreateFactionTable("UEA0304"),
    ['AirSuperiority'] = CreateFactionTable("UEA0303"),
    ['HeavyGunship'] = CreateFactionTable("UEA0305"),
    ['HeavyTorpedoBomber'] =
    {
        Aeon = "xaa0306",
    },
    ['T3Transport'] =
    {
        UEF = "xea0306",
    },
    ['T2Transport'] = CreateFactionTable("UEA0104"),
    ['T1Transport'] = CreateFactionTable("UEA0107"),

    --Engineers
    ['T3Engineer'] = CreateFactionTable("UEL0309"),
    ['T2Engineer'] = CreateFactionTable("UEL0208"),
    ['CombatEngineer'] = {
        UEF = "xel0209",
    },
    ['T1Engineer'] = CreateFactionTable("UEL0105"),

    ["SACU"] = CreateFactionTable("UEL0301"),
    ["SACU_ENGINEER"] = CreateFactionTable("UEL0301_ENGINEER"),
    ["SACU_RAMBO"] = CreateFactionTable("UEL0301_RAMBO"),
    ["SACU_COMBAT"] = CreateFactionTable("UEL0301_COMBAT"),
    ["SACU_RAS"] = CreateFactionTable("UEL0301_RAS"),



    -- TODO
    -- Naval
    ['Battleship'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Destroyer'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Cruiser'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Submarine'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Frigate'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['T2Submarine'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['UtilityBoat'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['Carrier'] = {
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['NukeSubmarine'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
    },
    ['AABoat'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['MissileShip'] = {
        Aeon = "",
    },
    ['T3Submarine'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['TorpedoBoat'] = {
        UEF = "",
        Cybran = "",
        Aeon = "",
        Seraphim = "",
    },
    ['BattleCruiser'] = {
        UEF = "",
    },
}

---@alias FactionName
--- | "UEF"
--- | "Cybran"
--- | "Aeon"
--- | "Seraphim"

---@param faction FactionName
---@return fun(unitType: UnitType):UnitId
function FactionUnitParser(faction)
    ---@param unitType UnitType
    ---@return UnitId
    return function(unitType)
        local unit = unitTypes[unitType][faction]
        assert(unit, "UNIT " .. unitType .. " of " .. faction .. " DOES NOT EXIST")
        return unit
    end
end
