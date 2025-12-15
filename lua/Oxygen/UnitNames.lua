---@alias UnitName
--- |    'Cybran ACU'
--- |    'Sera ACU'
--- |    'Seraphim ACU'
--- |    'UEF ACU'
--- |    'Aeon ACU'
--- |    "T1 Aeon Engineer"
--- |    "T1 UEF Engineer"
--- |    "T1 Cybran Engineer"
--- |    "T1 Sera Engineer"
--- |    "T2 Aeon Engineer"
--- |
--- |    "T2 UEF Engineer"
--- |
--- |    "T2 Cybran Engineer"
--- |
--- |    "T2 Sera Engineer"
--- |
--- |    "T3 Aeon Engineer"
--- |
--- |    "T3 UEF Engineer"
--- |
--- |    "T3 Cybran Engineer"
--- |
--- |    "T3 Sera Engineer"
--- |
--- |
--- |
--- |
--- |    "Soul Ripper"
--- |    "Exp Bug"
--- |
--- |    "Ahwassa"
--- |    "AssWasher"
--- |    "T4 Mercy"
--- |
--- |    "Czar"
--- |    "Donut"
--- |
--- |    "Monkeylord"
--- |    "Monkey Lord"
--- |    "ML"
--- |    "Spider"
--- |
--- |    "Mega"
--- |    "Megalith"
--- |    "Crab"
--- |
--- |    "Scathis"
--- |
--- |    "Ythota"
--- |    "Chicken"
--- |
--- |    "Galactic Colossus"
--- |    "GC"
--- |
--- |
--- |    "Fatboy"
--- |    "Fatty"
--- |    "Brick"
--- |
--- |
--- |    "Banger"
--- |    "T2 Cybran MAA"
--- |
--- |    "Deceiver"
--- |
--- |    "Gemini"
--- |    "Cybran ASF"
--- |
--- |    "Corsair"
--- |
--- |    "Zeus"
--- |    "T1 Cybran Bomber"
--- |
--- |    "Wailer"
--- |    "T3 Cybran Gunship"
--- |
--- |    "Revenant"
--- |    "T3 Cybran Bomber"
--- |
--- |    "Renegade"
--- |    "T2 Cybran Gunship"
--- |
--- |    "Medusa"
--- |    "T1 Cybran Artillery"
--- |    "T1 Cybran Arty"
--- |
--- |
--- |    "Mantis"
--- |
--- |
--- |
--- |    "Fire Beetle"
--- |    "Beetle"
--- |    "Loyalist"
--- |    "Bouncer"
--- |    "T3 Cybran MAA"
--- |    "Rhino"
--- |    "Cybran RAS SACU"
--- |
--- |    "Mole"
--- |    "Snoop"
--- |    "Spirit"
--- |    "Selen"
--- |
--- |    "Mech Marine"
--- |    "UEF LAB"
--- |    "Flare"
--- |    "Aeon LAB"
--- |    "Hunter"
--- |    "Cybran LAB"
--- |     "Striker"
--- |     "Mantis"
--- |     "T1 Cybran Tank"
--- |     "Striker"
--- |     "T1 UEF Tank"
--- |     "Aurora"
--- |     "T1 Aeon Tank"
--- |     "Thaam"
--- |     "T1 Sera Tank"
--- |     "Lobo"
--- |     "T1 UEF Artillery"
--- |     "Pillar"
--- |     "T2 UEF Tank"
--- |     "T2 UEF MAA"
--- |     "Sky Boxer"
--- |     "Parashield"
--- |     "T2 UEF Mobile Shield"
--- |     "T2 UEF MML"
--- |     "Flapjack"
--- |     "Titan"
--- |     "T3 UEF Bot"
--- |     "Cougar"
--- |     "T3 UEF MAA"
--- |     "Percival"
--- |     "T3 UEF Armored Bot"
--- |     "T2 UEF Field Engineer"
--- |     "Sparky"
--- |     "T2 UEF Flak"
--- |  "Cybran SACU"
--- |  "Cybran RAS SACU"
--- |  "Cybran Rambo SACU"
--- |  "Cybran Combat SACU"
--- |  "UEF SACU"
--- |  "UEF RAS SACU"
--- |  "UEF Rambo SACU"
--- |  "Scorcher"
--- |  "T1 UEF Bomber"
--- |  "Stinger"
--- |  "T2 UEF Gunship"
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |
--- |



---@type table<UnitId, UnitName[]>
local idsToNames = {


    --ACUs
    ['URL0001'] = {
        'Cybran ACU'
    },
    ['XSL0001'] = {
        'Sera ACU',
        'Seraphim ACU'
    },
    ['UEL0001'] = {
        'UEF ACU',
    },
    ['UAL0001'] = {
        'Aeon ACU'
    },




    --T1 engies
    ['UAL0105'] = {
        "T1 Aeon Engineer"
    },
    ['UEL0105'] = {
        "T1 UEF Engineer"
    },
    ['URL0105'] = {
        "T1 Cybran Engineer"
    },
    ['XSL0105'] = {
        "T1 Sera Engineer"
    },

    --T2 engies
    ['UAL0208'] = {
        "T2 Aeon Engineer"
    },
    ['UEL0208'] = {
        "T2 UEF Engineer"
    },
    ['URL0208'] = {
        "T2 Cybran Engineer"
    },
    ['XSL0208'] = {
        "T2 Sera Engineer"
    },

    --T3 engies
    ['UAL0309'] = {
        "T3 Aeon Engineer"
    },
    ['UEL0309'] = {
        "T3 UEF Engineer"
    },
    ['URL0309'] = {
        "T3 Cybran Engineer"
    },
    ['XSL0309'] = {
        "T3 Sera Engineer"
    },


    --air exps
    ["URA0401"] = {
        "Soul Ripper",
        "Exp Bug"
    },
    ["XSA0402"] = {
        "Ahwassa",
        "AssWasher",
        "T4 Mercy",
    },
    ["UAA0310"] = {
        "Czar",
        "Donut"
    },


    --land exps
    ["URL0402"] = {
        "Monkeylord",
        "Monkey Lord",
        "ML",
        "Spider"
    },
    ["XRL0403"] = {
        "Mega",
        "Megalith",
        "Crab",
    },
    ["URL0401"] = {
        "Scathis",
    },

    ["XSL0401"] = {
        "Ythota",
        "Chicken"
    },
    ["UAL0401"] = {
        "Galactic Colossus",
        "GC"
    },

    ["UEL0401"] = {
        "Fatboy",
        "Fatty"
    },




    --

    ["XRL0305"] = {
        "Brick",

    },

    ["URL0205"] = {
        "Banger",
        "T2 Cybran MAA"
    },

    ["URL0306"] = {
        "Deceiver"
    },

    ["URA0303"] = {
        "Gemini",
        "Cybran ASF"
    },

    ["DRA0202"] = {
        "Corsair",
    },

    ["URA0103"] = {
        "Zeus",
        "T1 Cybran Bomber"
    },

    ["UEA0103"] = {
        "Scorcher",
        "T1 UEF Bomber"
    },

    ["XRA0305"] = {
        "Wailer",
        "T3 Cybran Gunship"
    },
    ["URA0304"] = {
        "Revenant",
        "T3 Cybran Bomber"
    },
    ["URA0203"] = {
        "Renegade",
        "T2 Cybran Gunship"
    },

    ["UEA0203"] = {
        "Stinger",
        "T2 UEF Gunship"
    },

    ["URL0103"] = {
        "Medusa",
        "T1 Cybran Artillery",
        "T1 Cybran Arty"
    },


    ["XRL0302"] = {
        "Fire Beetle",
        "Beetle",

    },
    ["URL0303"] = {
        "Loyalist",

    },
    ["DRLK001"] = {
        "Bouncer",
        "T3 Cybran MAA"
    },
    ["URL0202"] = {
        "Rhino"
    },


    ---SACUS
    ---Cybran
    ["URL0301"] = {
        "Cybran SACU"
    },

    ["URL0301_RAS"] = {
        "Cybran RAS SACU"
    },

    ["URL0301_RAMBO"] = {
        "Cybran Rambo SACU"
    },
    ["URL0301_COMBAT"] = {
        "Cybran Combat SACU"
    },

    ---UEF
    ["UEL0301"] = {
        "UEF SACU"
    },

    ["UEL0301_RAS"] = {
        "UEF RAS SACU"
    },

    ["UEL0301_RAMBO"] = {
        "UEF Rambo SACU"
    },

    ["UEL0301_COMBAT"] = {
        "UEF Combat SACU"
    },


    -- t1 land scouts
    ["UEL0101"] = {
        "Snoop"
    },
    ["URL0101"] = {
        "Mole"
    },
    ["UAL0101"] = {
        "Spirit"
    },
    ["XSL0101"] = {
        "Selen"
    },

    --- labs
    ["UEL0106"] = {
        "Mech Marine",
        "UEF LAB"
    },
    ["URL0106"] = {
        "Hunter",
        "Cybran LAB"
    },
    ["UAL0106"] = {
        "Flare",
        "Aeon LAB"
    },


    --- t1 tanks

    ["URL0107"] = {
        "Mantis",
        "T1 Cybran Tank"
    },
    ["UEL0201"] = {
        "Striker",
        "T1 UEF Tank"
    },
    ["UAL0201"] = {
        "Aurora",
        "T1 Aeon Tank"
    },
    ["XSL0201"] = {
        "Thaam",
        "T1 Sera Tank"
    },



    ["UEL0103"] = {
        "Lobo",
        "T1 UEF Artillery"
    },
    ["UEL0202"] = {
        "Pillar",
        "T2 UEF Tank"
    },
    ["UEL0205"] = {
        "T2 UEF MAA",
        "T2 UEF Flak",
        "Sky Boxer"
    },
    ["UEL0307"] = {
        "Parashield",
        "T2 UEF Mobile Shield"
    },
    ["UEL0111"] = {
        "T2 UEF MML",
        "Flapjack"
    },
    ["UEL0303"] = {
        "Titan",
        "T3 UEF Bot"
    },
    ["DELK002"] = {
        "Cougar",
        "T3 UEF MAA"
    },
    ["XEL0305"] = {
        "Percival",
        "T3 UEF Armored Bot"
    },
    ["XEL0209"] = {
        "T2 UEF Field Engineer",
        "Sparky",
    },


    -- TODO
    -- [""]={},
    -- [""]={},

    --- t1 maas

    --- t1 arty











}

FactionParse = import("UnitTypeFactionParser.lua")


local namesToIds = {}

local function Init()
    for _id, names in idsToNames do
        local id = _id:lower()
        for _, name in names do
            name = name:lower()

            assert(namesToIds[name] == nil, "Attempt to assign same name twice " .. name)

            namesToIds[name] = id
        end
        namesToIds[id] = id
    end
    LOG("Assigned nicknames:")
    reprsl(namesToIds)
end

Init()

---Returns unit id by nickname
---@see idsToNames
---@param name UnitName
---@return UnitId
function Get(name)
    name = name:lower()

    assert(namesToIds[name], "There is no unit with name " .. name)

    return namesToIds[name]
end
