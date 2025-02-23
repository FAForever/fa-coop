local Cinematics = import('/lua/cinematics.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Triggers = import("Triggers.lua")

---@type TimerTrigger
local delayClearIntel = Triggers
    .TimerTrigger(ScenarioFramework.ClearIntel)
    :Delay(0.1)


---@type table<string, VisionHandler>
local visionMarkers = {}


---@class VisionHandler
---@field _marker VizMarker
---@field clearIntel boolean
---@field toBeDestroyed boolean
VisionHandler = ClassSimple
{
    ---inits VisionHandler
    ---@param self VisionHandler
    ---@param vizMarker VizMarker
    __init = function(self, vizMarker)
        self._marker = vizMarker

    end,

    ---Sets VisionHandler to be destroyed after NIS mode
    ---@param self VisionHandler
    ---@param clearIntel? boolean
    DestroyOnExit = function(self, clearIntel)
        self.clearIntel = clearIntel
        self.toBeDestroyed = true
    end,

    ---Destorys VisionHandler
    ---@param self VisionHandler
    ---@param clearIntel? boolean
    Destroy = function(self, clearIntel)
        if clearIntel then
            delayClearIntel:Run(Vector(self._marker.X, 0, self._marker.Z), self._marker.Radius + 10)
        end
        self._marker:Destroy()
        self._marker = nil
    end,
}

---Creates vision area at location of given radius for army
---@param location Marker
---@param radius number
---@param armyBrain AIBrain
---@param lifetime? number
---@return VisionHandler
function VisionAtLocation(location, radius, armyBrain, lifetime)
    local viz = ScenarioFramework.CreateVisibleAreaLocation(radius, location, lifetime or 0, armyBrain)
    local handler = VisionHandler(viz)
    if not lifetime then
        visionMarkers[location] = handler
    end
    return handler
end

---@param location Marker
---@param clearIntel? boolean
function ClearVisionAtLocation(location, clearIntel)
    if visionMarkers[location] == nil then return end

    visionMarkers[location]:Destroy(clearIntel)
    visionMarkers[location] = nil
end

---Enters NIS mode and after callback Exits, makes units in area(s) invincible
---@param callback fun()
---@param area Area|Area[]?
function NISMode(callback, area)
    Cinematics.EnterNISMode()
    if area then
        Cinematics.SetInvincible(area)
        callback()
        Cinematics.SetInvincible(area, true)
    else
        callback()
    end
    Cinematics.ExitNISMode()
    for k, v in visionMarkers do
        if v.toBeDestroyed then
            v:Destroy(v.clearIntel)
            visionMarkers[k] = nil
        end
    end
end

---Moves camera to marker with name for given amount of seconds
---@param name MarkerChain
---@param seconds number
function MoveTo(name, seconds)
    return Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker(name), seconds)
end

---Displays text with given size, color, position and for duration in seconds
---@param text string
---@param size integer
---@param color Color
---@param position "lefttop"|"leftcenter"|"leftbottom"|"righttop"|"rightcenter"|"rightbottom"|"centertop"|"center"|"centerbottom"|
---@param duration number
function DisplayText(text, size, color, position, duration)
    for s in text:gfind("[^\n]+") do
        PrintText(s, size, color, duration, position)
    end
end
