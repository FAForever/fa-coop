local ForkThread, KillThread = ForkThread, KillThread
local unpack, assert = unpack, assert

local ScenarioFramework = import('/lua/ScenarioFramework.lua')

---@alias ThreadFunction fun(...:any):nil

---@class BasicTrigger
---@field private _threadFunc ThreadFunction
BasicTrigger = ClassSimple
{
    ---Initializes Runnable with passed thread function
    ---@param self BasicTrigger
    ---@param threadFunc ThreadFunction
    __init = function(self, threadFunc)
        assert(type(threadFunc) == "function", "Function must be passed into constructor for BasicTrigger")

        self._threadFunc = threadFunc
    end,

    ---Runs thread function that was passed into Runnable
    ---@param self BasicTrigger
    ---@param ... any
    Run = function(self, ...)
        return ForkThread(self._threadFunc, unpack(arg))
    end,
}


---@class IReplaceThreadTrigger : BasicTrigger
---@field MainThreadFunction ThreadFunction
IReplaceThreadTrigger = Class(BasicTrigger)
{
    MainThreadFunction = false,
    ---Replaces thread function with new one, returns old one
    ---@param self IReplaceThreadTrigger
    ---@param newFunc ThreadFunction
    ---@return ThreadFunction
    ReplaceThreadFunction = function(self, newFunc)
        local oldFunc = self._threadFunc
        self._threadFunc = newFunc
        return oldFunc
    end,

    ---@param self IReplaceThreadTrigger
    ---@param ... any
    Run = function(self, ...)
        assert(self.MainThreadFunction, "MainThreadFunction wasn't set")
        local callback = self:ReplaceThreadFunction(self.MainThreadFunction)
        return BasicTrigger.Run(self, callback, unpack(arg))
    end
}

---Callback function with delay
---@param callback ThreadFunction
---@param delay number
---@param ... any
local function DelayedCallbackThreadFunction(callback, delay, ...)
    WaitSeconds(delay)
    callback(unpack(arg))
end

---Callback function with ticking on second passed
---@param callback ThreadFunction
---@param onTickSecond fun(second : integer)
---@param delay number
---@param ... any
local function TickingCallbackThreadFunction(callback, delay, onTickSecond, ...)
    local second = 0
    while second < delay do
        second = second + 1
        WaitSeconds(1)
        onTickSecond(second)
    end
    callback(unpack(arg))
end

---@class TimerTrigger : IReplaceThreadTrigger
---@field _delay number
TimerTrigger = Class(IReplaceThreadTrigger)
{
    MainThreadFunction = DelayedCallbackThreadFunction,

    ---Sets delay in seconds for trigger
    ---@param self TimerTrigger
    ---@param seconds number
    ---@return TimerTrigger
    Delay = function(self, seconds)
        self._delay = seconds
        return self
    end,

    ---Runs thread function that was passed into Runnable
    ---@param self TimerTrigger
    ---@param ... any
    Run = function(self, ...)
        assert(self._delay and self._delay > 0, "Delay for TimerTrigger must be specified in seconds!")

        return IReplaceThreadTrigger.Run(self, self._delay, unpack(arg))
    end,
}

---@class TickingTimerTrigger : TimerTrigger
---@field _onTickSecond fun(second : integer)
TickingTimerTrigger = Class(TimerTrigger)
{
    MainThreadFunction = TickingCallbackThreadFunction,

    ---@param self TickingTimerTrigger
    ---@param callback ThreadFunction
    ---@param onTickSecond fun(second : integer)
    __init = function(self, callback, onTickSecond)
        TimerTrigger.__init(self, callback)
        self._onTickSecond = onTickSecond
        assert(type(self._onTickSecond) == "function", "onTickSecond must be a function!")
    end,

    ---Runs thread function that was passed into Runnable
    ---@param self TickingTimerTrigger
    ---@param ... any
    Run = function(self, ...)
        return TimerTrigger.Run(self, self._onTickSecond, unpack(arg))
    end,
}



---@alias UnitCallback fun(unit: Unit):nil


---Adds callbacks to units
---@param units Unit[]|Unit
---@param callback UnitCallback
---@param callbackType string
local function AddUnitsCallback(units, callback, callbackType)
    if IsEntity(units) then
        units:AddUnitCallback(callback, callbackType)
        return
    end
    for _, unit in units do
        unit:AddUnitCallback(callback, callbackType)
    end
end

---@class IUnitTrigger
---@field _callback UnitCallback
---@field _type string|string[]
IUnitTrigger = ClassSimple
{
    _type = false,
    ---comment
    ---@param self IUnitTrigger
    ---@param callback UnitCallback
    __init = function(self, callback)
        self._callback = callback
    end,



    ---Adds to units a trigger callback
    ---@param self IUnitTrigger
    ---@param units Unit[]
    Add = function(self, units)
        assert(self._type, "Not specified unit callback type!")

        if type(self._type) == "string" then
            AddUnitsCallback(units, self._callback, self._type)
            return
        end

        for _, t in self._type do
            AddUnitsCallback(units, self._callback, t)
        end
    end,

    ---Removes from units trigger callback
    ---@param self IUnitTrigger
    ---@param units Unit[]|Unit
    Remove = function(self, units)
        assert(self._type, "Not specified unit callback type!")

        if IsEntity(units) then
            units:RemoveCallback(self._callback)
            return
        end

        for _, unit in units do
            unit:RemoveCallback(self._callback)
        end
    end

}


---@class UnitStartCaptureTrigger : IUnitTrigger
UnitStartCaptureTrigger = Class(IUnitTrigger) { _type = 'OnStartCapture' }
---@class UnitStopCaptureTrigger : IUnitTrigger
UnitStopCaptureTrigger = Class(IUnitTrigger) { _type = 'OnStopCapture' }
---@class UnitStartBeingCapturedTrigger : IUnitTrigger
UnitStartBeingCapturedTrigger = Class(IUnitTrigger) { _type = 'OnStartBeingCaptured' }
---@class UnitStopBeingCapturedTrigger : IUnitTrigger
UnitStopBeingCapturedTrigger = Class(IUnitTrigger) { _type = 'OnStopBeingCaptured' }
---@class UnitFailedBeingCapturedTrigger : IUnitTrigger
UnitFailedBeingCapturedTrigger = Class(IUnitTrigger) { _type = 'OnFailedBeingCaptured' }
---@class UnitFailedCaptureTrigger : IUnitTrigger
UnitFailedCaptureTrigger = Class(IUnitTrigger) { _type = 'OnFailedCapture' }
---@class UnitStopBeingBuiltTrigger : IUnitTrigger
UnitStopBeingBuiltTrigger = Class(IUnitTrigger) { _type = 'OnStopBeingBuilt' }
---@class UnitGivenTrigger : IUnitTrigger
UnitGivenTrigger = Class(IUnitTrigger) { _type = 'OnGiven' }
---@class UnitVeteranTrigger : IUnitTrigger
UnitVeteranTrigger = Class(IUnitTrigger) { _type = 'OnVeteran' }
---@class UnitFailedToBuildTrigger : IUnitTrigger
UnitFailedToBuildTrigger = Class(IUnitTrigger) { _type = 'OnFailedToBuild' }
---@class UnitDeathTrigger : IUnitTrigger
UnitDeathTrigger = Class(IUnitTrigger) { _type = 'OnKilled' }
---@class UnitReclaimedTrigger : IUnitTrigger
UnitReclaimedTrigger = Class(IUnitTrigger) { _type = 'OnReclaimed' }
---@class UnitDestroyedTrigger : IUnitTrigger
UnitDestroyedTrigger = Class(IUnitTrigger) { _type = { 'OnReclaimed', 'OnCaptured', 'OnKilled' } }
---@class UnitCapturedNewTrigger : IUnitTrigger
UnitCapturedNewTrigger = Class(IUnitTrigger) { _type = 'OnCapturedNewUnit' }
---@class UnitCapturedTrigger : IUnitTrigger
UnitCapturedTrigger = Class(IUnitTrigger) { _type = 'OnCaptured' }


---@class UnitDamagedTrigger : IUnitTrigger
UnitDamagedTrigger = Class(IUnitTrigger) { _type = 'OnDamaged',
    ---Adds to units damaged callback
    ---@param self UnitDamagedTrigger
    ---@param units Unit[] | Unit
    ---@param amount? number
    ---@param repeatNum? number
    Add = function(self, units, amount, repeatNum)
        if IsEntity(units) then
            units:AddOnDamagedCallback(self._callback, amount, repeatNum)
            return
        end
        for _, unit in units do
            unit:AddOnDamagedCallback(self._callback, amount, repeatNum)
        end
    end,
}

---@class UnitBuildTrigger : IUnitTrigger
UnitBuildTrigger = Class(IUnitTrigger) { _type = 'OnUnitBuilt',
    ---Adds to units damaged callback
    ---@param self UnitBuildTrigger
    ---@param units Unit[]| Unit
    ---@param category EntityCategory
    Add = function(self, units, category)
        if IsEntity(units) then
            units:AddOnUnitBuiltCallback(self._callback, category)
            return
        end
        for _, unit in units do
            unit:AddOnUnitBuiltCallback(self._callback, category)
        end
    end,
}

---@class UnitStartBuildTrigger : IUnitTrigger
UnitStartBuildTrigger = Class(IUnitTrigger) { _type = 'OnStartBuild',
    ---Adds to units damaged callback
    ---@param self UnitStartBuildTrigger
    ---@param units Unit[]| Unit
    Add = function(self, units)
        if IsEntity(units) then
            units:AddOnStartBuildCallback(self._callback)
            return
        end
        for _, unit in units do
            unit:AddOnStartBuildCallback(self._callback)
        end
    end,
}





---@class BasicIntelTrigger
---@field _aiBrain AIBrain
---@field _callback UnitCallback
BasicIntelTrigger = ClassSimple
{
    ---@param self BasicIntelTrigger
    ---@param callback UnitCallback
    ---@param aiBrain AIBrain
    __init = function(self, callback, aiBrain)
        self._callback = callback
        self._aiBrain = aiBrain
    end,
}

---@class BasicUnitIntelTrigger : BasicIntelTrigger
BasicUnitIntelTrigger = Class(BasicIntelTrigger)
{
    ---Adds unit intel callback
    ---@param self BasicUnitIntelTrigger
    ---@param unit Unit
    Add = function(self, unit)
        self._aiBrain:SetupArmyIntelTrigger
        {
            CallbackFunction = self._callback,
            Type = 'LOSNow',
            Category = categories.ALLUNITS,
            Blip = unit,
            Value = true,
            OnceOnly = true,
            TargetAIBrain = unit:GetAIBrain(),
        }
    end
}

---@class BasicCategoryIntelTrigger : BasicIntelTrigger
BasicCategoryIntelTrigger = Class(BasicIntelTrigger)
{
    ---Adds category intel trigger for this aibrain
    ---@param self BasicCategoryIntelTrigger
    ---@param category EntityCategory
    ---@param targetBrain AIBrain
    Add = function(self, category, targetBrain)
        self._aiBrain:SetupArmyIntelTrigger
        {
            CallbackFunction = self._callback,
            Type = 'LOSNow',
            Category = category,
            Blip = false,
            Value = true,
            OnceOnly = true,
            TargetAIBrain = targetBrain,
        }
    end
}

---@class PlayerIntelTrigger : BasicIntelTrigger
PlayerIntelTrigger = Class(BasicIntelTrigger)
{
    ---@param self PlayerIntelTrigger
    ---@param callback UnitCallback
    __init = function(self, callback)
        BasicIntelTrigger.__init(self, callback, GetArmyBrain(ScenarioFramework.Objectives.GetPlayerArmy()))
    end
}

---@class PlayerUnitIntelTrigger : PlayerIntelTrigger, BasicUnitIntelTrigger
PlayerUnitIntelTrigger = Class(PlayerIntelTrigger, BasicUnitIntelTrigger) {}

---@class PlayerCategoryIntelTrigger : PlayerIntelTrigger, BasicCategoryIntelTrigger
PlayerCategoryIntelTrigger = Class(PlayerIntelTrigger, BasicCategoryIntelTrigger) {}
