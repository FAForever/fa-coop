---@declare-global
if not table.random then
    function table.random(array)
        return array[Random(1, table.getn(array))]
    end
end

---@type FileName
local mapFolder


---Oxygen is Framework for creating coop missions for Supreme Commander FAF.
---Less code -- more Oxygen
_G.Oxygen = {}
Oxygen.Callbacks = import("Callbacks.lua")
Oxygen.Triggers = import("Triggers.lua")
Oxygen.Utils = import("Utils.lua")

Oxygen.DifficultyValue = import("DifficultyValue.lua")

Oxygen.Cinematics = import("AdvancedCinematics.lua")

Oxygen.UnitNames = import("UnitNames.lua")

Oxygen.AdvancedBaseManager = import("BaseManager/__Init__.lua").BaseManagers.AdvancedBaseManager
Oxygen.BaseManagers = import("BaseManager/__Init__.lua").BaseManagers
Oxygen.BaseManager = import("BaseManager/__Init__.lua")

Oxygen.PlayersManager = import("PlayersManager.lua").PlayersManager

Oxygen.RequireIn = import("ObjectiveBuilder.lua").RequireIn
Oxygen.ObjectiveBuilder = import("ObjectiveBuilder.lua").ObjectiveBuilder
Oxygen.ObjectiveManager = import("ObjectiveManager.lua").ObjectiveManager

Oxygen.PlatoonBuilder = import("PlatoonBuilder.lua").PlatoonBuilder
Oxygen.PlatoonLoader = import("PlatoonLoader.lua").PlatoonLoader
---@deprecated
Oxygen.OpAIBuilder = import("OpAIBuilder.lua").OpAIBuilder

Oxygen.OpAIBuilders = {
    NavalAttacks = import("OpAIBuilders/NavalAttacks.lua").NavalAttacksOpAIBuilder,
    AirAttacks = import("OpAIBuilders/AirAttacks.lua").AirAttacksOpAIBuilder,
    LandAttacks = import("OpAIBuilders/LandAttacks.lua").LandAttacksOpAIBuilder,
    EngineerAttacks = import("OpAIBuilders/EngineerAttacks.lua").EngineerAttacksOpAIBuilder,
}

Oxygen.BuildConditions = import("BuildConditions.lua")

Oxygen.UnitsController = import("UnitsController.lua").UnitsController
Oxygen.PlatoonController = import("PlatoonController.lua").PlatoonController

Oxygen.Game = import("GameManager.lua")

Oxygen.DifficultyValues = import("DifficultyValue.lua").values
Oxygen.Misc = import("Misc.lua")



Oxygen.Objective = {
    Kill = import("Objectives/Kill.lua").KillObjective,
    Capture = import("Objectives/Capture.lua").CaptureObjective,
    CategoriesInArea = import("Objectives/CategoriesInArea.lua").CategoriesInAreaObjective,
    Locate = import("Objectives/Locate.lua").LocateObjective,
    Damage = import("Objectives/Damage.lua").DamageObjective,
    Timer = import("Objectives/Timer.lua").TimerObjective,
    Protect = import("Objectives/Protect.lua").ProtectObjective,
    SpecificUnitsInArea = import("Objectives/SpecificUnitsInArea.lua").SpecificUnitsInAreaObjective,

}

local basePath = "/lua/Oxygen/"
Oxygen.PlatoonAI = {
    Land = basePath .. "PlatoonAIs/Land.lua",
    Missiles = basePath .. "PlatoonAIs/Missiles.lua",
    Air = basePath .. "PlatoonAIs/Air.lua",
    Naval = basePath .. "PlatoonAIs/Naval.lua",
    Economy = basePath .. "PlatoonAIs/Economy.lua",
    Common = basePath .. "PlatoonAIs/Common.lua",
    Expansion = basePath .. "PlatoonAIs/Expansion.lua",
    NavMesh = basePath .. "PlatoonAIs/NavMesh.lua",
}

Oxygen.Platoons = import("Platoons.lua")

---Use this table for intellisence support:
---```lua
---Oxygen.Brains.Aeon = ArmyBrains[2]
---...
---```
---@type table<string, AIBrain>
Oxygen.Brains = {}

---adds scenario folder path to given path of file, if nil returns scenario folder
---@param path? string
---@return FileName
Oxygen.ScenarioFolder = function(path)
    mapFolder = mapFolder or ScenarioInfo.script:gsub("[^/]*%.lua$", "")
    return mapFolder .. (path or "")
end
