local EmptyFunc = function() end

---@alias ObjectiveFunc
--- | "ControlGroup"
--- | "Kill"
--- | "Capture"
--- | "KillOrCapture"
--- | "Reclaim"
--- | "ReclaimProp"
--- | "Locate"
--- | "SpecificUnitsInArea"
--- | "CategoriesInArea"
--- | "Protect"
--- | "Timer"
--- | "Unknown"
--- | "Basic"
--- | "ArmyStatCompare"
--- | "Damage"

---@alias ObjectiveAction
--- | "kill"
--- | "capture"
--- | "build"
--- | "protect"
--- | "timer"
--- | "move"
--- | "reclaim"
--- | "repair"
--- | "locate"
--- | "group"
--- | "killorcapture"
--- | "damage"


local actionToFunction =
{
    ["damage"] = "Damage",
    ["kill"] = "Kill",
    ["capture"] = "Capture",
    ["build"] = "CategoriesInArea",
    ["protect"] = "Protect",
    ["timer"] = "Timer",
    ["move"] = "Basic",
    ["reclaim"] = "Reclaim",
    ["repair"] = "Basic",
    ["locate"] = "Locate",
    ["group"] = "ControlGroup",
    ["killorcapture"] = "KillOrCapture",
}

---@alias CompareOp
--- | '<='
--- | '>='
--- | '<'
--- | '>'
--- | '=='

---@class ObjectiveTargetRequirements
---@field Area Area
---@field Category EntityCategory
---@field CompareOp CompareOp
---@field Value number
---@field ArmyIndex integer?
---@field Armies  ArmyName[]?

---@class ObjectiveTargetRequirementsArray
---@field [1] Area
---@field [2] EntityCategory
---@field [3] CompareOp
---@field [4] number
---@field [5] integer|(ArmyName[])


---More compact variant of ObjectiveTargetRequirements
---``` lua
---RequireIn('AREA1', category.STRUCTURE, '==', 0, QAI )
---RequireIn('AREA1', category.STRUCTURE, '==', 0, 'HumanPlayers' )
---RequireIn('AREA1', category.STRUCTURE, '==', 0, {'HumanPlayers'} )
---```
---@param area  Area
---@param category  EntityCategory
---@param compareOp  CompareOp
---@param value  number
---@param army  integer|(ArmyName[])
---@return ObjectiveTargetRequirements
function RequireIn(area, category, compareOp, value, army)
    if type(army) == "number" then
        return {
            Area = area,
            Category = category,
            CompareOp = compareOp,
            Value = value,
            ArmyIndex = army,
        }
    elseif type(army) == "string" then
        return {
            Area = area,
            Category = category,
            CompareOp = compareOp,
            Value = value,
            Armies = { army },
        }
    else
        return {
            Area = area,
            Category = category,
            CompareOp = compareOp,
            Value = value,
            Armies = army,
        }
    end
end

---@alias ArmyName string|"HumanPlayers"
---@alias StatName 'Units_Active'| 'Enemies_Killed' |'Units_History'|

---@class ObjectiveTarget
---@field MarkUnits boolean?
---@field MarkArea boolean?
---@field FlashVisible boolean?
---@field AlwaysVisible boolean?
---@field Hidden boolean?
---@field Units Unit[]?
---@field Area Area?
---@field ShowProgress boolean?
---@field Requirements (ObjectiveTargetRequirements | ObjectiveTargetRequirementsArray)[]?
---@field Timer integer?
---@field NumRequired integer?
---@field ExpireResult 'complete' | 'failed'?
---@field ShowFaction 'UEF' | 'Cybran' | 'Aeon' | 'Seraphim'?
---@field Armies ArmyName[]?
---@field StatName StatName?
---@field CompareOp CompareOp?
---@field Value integer?
---@field Category EntityCategory?
---@field Amount number? @For "Damage"
---@field RepeatNum integer? @For "Damage"



---@class ObjectiveTable
---@field name string
---@field func ObjectiveFunc
---@field action ObjectiveAction
---@field target ObjectiveTarget
---@field complete ObjectiveStatus
---@field type ObjectiveType
---@field title string
---@field startDelay number
---@field delay number
---@field description string
---@field onSuccessFunc fun()
---@field onFailFunc fun()
---@field onStartFunc fun():ObjectiveTarget?
---@field onProgressFunc fun()
---@field next string | string[]
---@field nextExpansion string | string[]
---@field expansionTimer integer
---@field class IObjective

---@class ObjectiveBuilder
---@field name string
---@field _func ObjectiveFunc
---@field _action ObjectiveAction
---@field _target ObjectiveTarget | nil
---@field _complete ObjectiveStatus
---@field _type ObjectiveType
---@field _title string
---@field _startDelay number
---@field _delay number
---@field _description string
---@field _onSuccessFunc fun()
---@field _onFailFunc fun()
---@field _onProgressFunc fun()
---@field _onStartFunc fun():ObjectiveTarget?
---@field _next string | string[]
---@field _nextExpansion string | string[]
---@field _expansionTimer integer
---@field _class IObjective
---@overload fun():ObjectiveBuilder
ObjectiveBuilder = ClassSimple
{
    ---Starts creation of new primary objective with given name
    ---@param self ObjectiveBuilder
    ---@param name string
    ---@return ObjectiveBuilder
    New = function(self, name)
        self._action = nil
        self._func = nil
        self._target = nil
        self._startDelay = nil
        self._delay = nil
        self._complete = "incomplete"
        self._type = "primary"
        self._title = nil
        self._description = nil
        self._onSuccessFunc = EmptyFunc
        self._onFailFunc = nil
        self._onStartFunc = EmptyFunc
        self._onProgressFunc = nil
        self._next = nil
        self._class = nil
        self.name = name
        return self
    end,

    ---Starts creation of new secondary objective with given name
    ---@param self ObjectiveBuilder
    ---@param name string
    ---@return ObjectiveBuilder
    NewSecondary = function(self, name)
        self:New(name)
        self._type = 'secondary'
        return self
    end,

    ---Starts creation of new bonus objective with given name
    ---@param self ObjectiveBuilder
    ---@param name string
    ---@return ObjectiveBuilder
    NewBonus = function(self, name)
        self:New(name)
        self._type = 'bonus'
        return self
    end,

    ---Sets given function name to call
    ---@param self ObjectiveBuilder
    ---@param func ObjectiveFunc
    ---@return ObjectiveBuilder
    Function = function(self, func)
        self._func = func
        return self
    end,

    ---Sets given action
    ---@param self ObjectiveBuilder
    ---@param action ObjectiveAction
    ---@return ObjectiveBuilder
    Action = function(self, action)
        self._action = action
        return self
    end,

    ---Sets given action and function if not specified
    ---@overload fun(self:ObjectiveBuilder, action:IObjective):ObjectiveBuilder
    ---@param self ObjectiveBuilder
    ---@param action ObjectiveAction
    ---@return ObjectiveBuilder
    To = function(self, action)
        if type(action) == "string" then
            self._action = action:lower()
            self._func = self._func or actionToFunction[self._action]
        elseif type(action) == "table" then
            self._class = action
        end
        return self
    end,

    ---Sets type of objective
    ---@param self ObjectiveBuilder
    ---@param objType ObjectiveType
    ---@return ObjectiveBuilder
    Type = function(self, objType)
        self._type = objType
        return self
    end,

    ---Sets type of objective
    ---@param self ObjectiveBuilder
    ---@param state boolean
    ---@return ObjectiveBuilder
    IsComplete = function(self, state)
        self._complete = state and "complete" or "incomplete"
        return self
    end,

    ---Sets title of objective
    ---@param self ObjectiveBuilder
    ---@param title string
    ---@return ObjectiveBuilder
    Title = function(self, title)
        self._title = title
        return self
    end,

    ---Sets description of objective
    ---@param self ObjectiveBuilder
    ---@param description string
    ---@return ObjectiveBuilder
    Description = function(self, description)
        self._description = description
        return self
    end,

    ---Translates requirements from array form into table form
    ---@param self ObjectiveBuilder
    _TranslateRequirements = function(self)
        local requirements = self._target.Requirements
        for i, requirement in requirements do
            if requirement[1] then
                requirements[i] = RequireIn(unpack(requirement))
            end
        end
    end,

    ---Sets target of objective, if empty, objective manager will use result of onStart function
    ---@param self ObjectiveBuilder
    ---@param target ObjectiveTarget | nil
    ---@return ObjectiveBuilder
    Target = function(self, target)
        self._target = target
        if self._target.Requirements then
            self:_TranslateRequirements()
        end
        return self
    end,

    ---Sets function which will be called on start of the objective, must return target table, if not specified
    ---@param self ObjectiveBuilder
    ---@param onStartFunc fun():ObjectiveTarget
    ---@return ObjectiveBuilder
    OnStart = function(self, onStartFunc)
        self._onStartFunc = onStartFunc
        return self
    end,

    ---Sets function which will be called on success of the objective
    ---@param self ObjectiveBuilder
    ---@param onSuccessFunc fun()
    ---@return ObjectiveBuilder
    OnSuccess = function(self, onSuccessFunc)
        self._onSuccessFunc = onSuccessFunc
        return self
    end,

    ---Sets function which will be called on fail of the objective
    ---@param self ObjectiveBuilder
    ---@param onFailFunc fun()
    ---@return ObjectiveBuilder
    OnFail = function(self, onFailFunc)
        self._onFailFunc = onFailFunc
        return self
    end,

    ---Sets delay in seconds for start function
    ---@param self ObjectiveBuilder
    ---@param seconds number
    ---@return ObjectiveBuilder
    StartDelay = function(self, seconds)
        self._startDelay = seconds
        return self
    end,

    ---Sets delay in seconds after start function
    ---@param self ObjectiveBuilder
    ---@param seconds number
    ---@return ObjectiveBuilder
    Delay = function(self, seconds)
        self._delay = seconds
        return self
    end,

    ---Sets expansion timer for an objective, works if corresponding option is on
    ---@param self ObjectiveBuilder
    ---@param seconds integer
    ---@return ObjectiveBuilder
    ExpansionTimer = function(self, seconds)
        self._expansionTimer = seconds
        return self
    end,

    ---Sets next objectives after expansion timer runs out
    ---@param self ObjectiveBuilder
    ---@param nextObj string | string[]
    ---@return ObjectiveBuilder
    NextExpansion = function(self, nextObj)
        self._nextExpansion = nextObj
        return self
    end,

    ---Sets function which will be called each time objective progresses
    ---@param self ObjectiveBuilder
    ---@param onProgressFunc fun()
    ---@return ObjectiveBuilder
    OnProgress = function(self, onProgressFunc)
        self._onProgressFunc = onProgressFunc
        return self
    end,

    ---Sets next objectives that will be called after success of this one
    ---@param self ObjectiveBuilder
    ---@param nextObj string | string[]
    ---@return ObjectiveBuilder
    Next = function(self, nextObj)
        self._next = nextObj
        return self
    end,

    ---comment
    ---@param self ObjectiveBuilder
    _Validate = function(self)
        if (self._func ~= nil or self._class ~= nil)
            and self._complete ~= nil
            and self._type ~= nil
            and self._title ~= nil
            and self._description ~= nil
            and self._onSuccessFunc ~= nil
            and self._onStartFunc ~= nil
            and self.name ~= nil
        then
            return
        end
        error(debug.traceback "incomplete objective")
    end,

    ---Returns objective build table for use in Objective Manager
    ---@param self ObjectiveBuilder
    ---@return ObjectiveTable
    Create = function(self)
        self:_Validate()

        return {
            name = self.name,
            title = self._title,
            description = self._description,
            func = self._func,
            type = self._type,
            complete = self._complete,
            action = self._action,
            target = self._target,
            next = self._next,
            nextExpansion = self._nextExpansion,
            startDelay = self._startDelay,
            delay = self._delay,
            onStartFunc = self._onStartFunc,
            onSuccessFunc = self._onSuccessFunc,
            onFailFunc = self._onFailFunc,
            onProgressFunc = self._onProgressFunc,
            expansionTimer = self._expansionTimer,
            class = self._class
        }
    end
}
