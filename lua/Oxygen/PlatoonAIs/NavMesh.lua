local AIBuildStructures = import("/lua/ai/aibuildstructures.lua")
local ScenarioFramework = import("/lua/scenarioframework.lua")
local StructureTemplates = import("/lua/buildingtemplates.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")


local NavGenerator = import('/lua/sim/NavGenerator.lua')
local NavUtils = import('/lua/sim/NavUtils.lua')


---@param platoon Platoon
function PlatoonNavigateToPosition(platoon)
    local destination = platoon.PlatoonData.Destination
    local layer = platoon.PlatoonData.Layer

    assert(destination, "PlatoonNavigateToPosition: PlatoonData.Destination wasnt specified")
    assert(layer, "PlatoonNavigateToPosition: PlatoonData.Layer wasnt specified")

    if not NavGenerator.IsGenerated() then
        NavGenerator.Generate()
    end

    local pos = platoon:GetPlatoonPosition()
    local path, n, length = NavUtils.PathTo(layer, pos, ScenarioUtils.MarkerToPosition(destination))

    assert(path, "PlatoonNavigateToPosition: Unable to find path to " .. destination)

    ScenarioFramework.PlatoonPatrolRoute(platoon, path)
end

