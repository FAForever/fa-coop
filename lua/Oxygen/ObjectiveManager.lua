local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local useActionInFunc = {
    ["CategoryStatCompare"] = true,
    ["UnitStatCompare"] = true,
    ["ArmyStatCompare"] = true,
    ["CategoriesInArea"] = true,
    ["Basic"] = true,
}

---@class ObjectiveManager
---@field _objectives table<string, ObjectiveTable>
---@field _activeObjectives table<string, IObjective>
---@field _timerTrigger TimerTrigger
---@overload fun():ObjectiveManager
ObjectiveManager = ClassSimple
{


    ---@param self ObjectiveManager
    __init = function(self)
        self._objectives = {}
        self._activeObjectives = {}
        self._timerTrigger = Oxygen.Triggers.TimerTrigger(
            function(nextObj)
                self:Start(nextObj)
            end
        )
    end,


    ---Inits ObjectiveManager with table of given objectives
    ---@param self ObjectiveManager
    ---@param objectives table<string, ObjectiveTable>
    ---@return ObjectiveManager
    Init = function(self, objectives)
        for _, obj in objectives do
            self:Add(obj)
        end
        return self
    end,

    ---Adds objective table into ObjectiveManager for further use
    ---@param self ObjectiveManager
    ---@param obj ObjectiveTable
    Add = function(self, obj)
        assert(self._objectives[obj.name] == nil, "Objective " .. obj.name .. " already presents in Objectives Manager!")

        self._objectives[obj.name] = obj
    end,

    _Validate = function(self)

    end,

    ---Starts objective(s) by its(their) name(s)
    ---@param self ObjectiveManager
    ---@param id string | string []
    Start = function(self, id)
        if type(id) == "string" then
            local obj = self._objectives[id]
            ForkThread(self._Start, self, obj)
        elseif type(id) == "table" then
            for _, i in id do
                self:Start(i)
            end
        end
    end,

    ---Internal start objective function
    ---@param self ObjectiveManager
    ---@param objTable ObjectiveTable
    _Start = function(self, objTable)
        if self._activeObjectives[objTable.name] ~= nil then return end
        --objTable.onStartFunc may interrupt objective creation with WaitSeconds,
        --so, we make it true for some time in order to detect and prevent attempt
        --of second creation due to timed expansion for instance
        self._activeObjectives[objTable.name] = true

        if objTable.startDelay then
            WaitSeconds(objTable.startDelay)
        end
        local target = objTable.onStartFunc()
        --merging target table with returnede one for more flexibility
        if target then
            target = table.merged(objTable.target, target)
        else
            target = objTable.target
        end
        if objTable.delay then
            WaitSeconds(objTable.delay)
        end
        ---@type Objective
        local obj
        if objTable.class then
            obj = objTable.class(
                objTable.type,
                objTable.complete,
                objTable.title,
                objTable.description,
                target,
                objTable.action
            )
        elseif useActionInFunc[objTable.func] then
            obj = Objectives[objTable.func](
                objTable.type,
                objTable.complete,
                objTable.title,
                objTable.description,
                objTable.action,
                target
            )
        else
            obj = Objectives[objTable.func](
                objTable.type,
                objTable.complete,
                objTable.title,
                objTable.description,
                target
            )
        end

        local nextObj = objTable.next
        do
            local onSuccessFunc = objTable.onSuccessFunc
            local onFailFunc = objTable.onFailFunc
            obj:AddResultCallback(
                function(success, ...)
                    if success then
                        ForkThread(onSuccessFunc, unpack(arg))
                        if nextObj then
                            self:Start(nextObj)
                        end
                    elseif onFailFunc then
                        ForkThread(onFailFunc, unpack(arg))
                    end
                end
            )
        end

        if objTable.onProgressFunc then
            obj:AddProgressCallback(objTable.onProgressFunc)
        end

        self._activeObjectives[objTable.name] = obj

        --Expansion timer
        if ScenarioInfo.Options.Expansion and objTable.expansionTimer ~= nil then
            if objTable.nextExpansion then
                self._timerTrigger:Delay(objTable.expansionTimer):Run(objTable.nextExpansion)
            elseif nextObj then
                self._timerTrigger:Delay(objTable.expansionTimer):Run(nextObj)
            end
        end
    end,

    ---Returns active objective by its name
    ---@param self ObjectiveManager
    ---@param name string
    ---@return IObjective|boolean
    Get = function(self, name)
        return self._activeObjectives[name]
    end,

    ---Checks if all assigned objectives of given type are complete
    ---@param self ObjectiveManager
    ---@param objType ObjectiveType
    ---@return boolean
    CheckComplete = function(self, objType)
        for name, objTable in self._objectives do
            if objTable.type == objType then
                if not self._activeObjectives[name].Complete then
                    return false
                end
            end
        end
        return true
    end,

    ---Ends game with given success state, callback and safety to given units
    ---@param self ObjectiveManager
    ---@param success boolean
    ---@param callback? fun()
    ---@param safety? boolean
    ---@param units? Unit[]
    EndGame = function(self, success, callback, safety, units)

        if safety then
            ScenarioFramework.EndOperationSafety(units)
        end
        if callback then
            callback()
        end

        ScenarioFramework.EndOperation(
            success,
            self:CheckComplete('primary'),
            self:CheckComplete('secondary'),
            self:CheckComplete('bonus')
        )
    end
}
