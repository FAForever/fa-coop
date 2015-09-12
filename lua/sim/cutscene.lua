local Cinematics = import('/lua/cinematics.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

--- Actual scene class that forwards all calls
-- to the appropriate ScenarioFramework functions
local Scene = Class {
    Dialogue = function(...)
        ScenarioFramework.Dialogue(unpack(args))
    end,
    CameraMoveToMarker = function(...)
        Cinematics.CameraMoveToMarker(unpack(args))
    end,
    CameraTrackEntity = function(...)
        Cinematics.CameraTrackEntity(unpack(args))
    end
}

--- Debugging scene class for skipping
-- everything that takes time, but leaving
-- the ability to spawn units etc.
local DebugScene = Class(Scene) {
    Dialogue = function(...) end,
    WaitSeconds = function(...) end,
    CameraMoveToMarker = function(...) end,
    CameraTrackEntity = function(...) end,
}

--- Start a cutscene
-- @param fn cutscene function, which takes a scene object
function Start(fn)
    local scene
    if not ScenarioInfo.DisableCutscenes then
        scene = Scene()
    else
        scene = DebugScene()
    end
    Cinematics.EnterNISMode()
    fn(scene)
    Cinematics.ExitNISMode()
end
