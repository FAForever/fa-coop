local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local SimObjectives = import("/lua/simobjectives.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")


---@class ObjectiveArgs : ObjectiveTarget
---@field Hidden boolean
---@field ShowFaction boolean | 'Cybran'|'Aeon'|'UEF'|'Seraphim'
---@field Image string
---@field Requirements ObjectiveTargetRequirements[]
---@field Timer integer
---@field Category EntityCategory
---@field AlwaysVisible boolean
---@field MarkUnits boolean

---@class UserTarget
---@field Type string


---@class IObjective
---@field Type ObjectiveType
---@field Title string
---@field Tag string
---@field Description string
---@field Active boolean
---@field Complete boolean
---@field Hidden boolean
---@field UnitMarkers TrashBag
---@field VizMarkers TrashBag
---@field Trash TrashBag
---@field Decals TrashBag
---@field IconOverrides Unit[]
---@field NextTargetTag integer
---@field PositionUpdateThreads thread[]
---@field SimStartTime number
---@field ResultCallbacks function[]
---@field ProgressCallbacks function[]
---@field Args ObjectiveArgs
IObjective = ClassSimple
{
    Icon = "",

    ---@param self IObjective
    ---@param objType ObjectiveType
    ---@param complete ObjectiveStatus
    ---@param title string
    ---@param description string
    ---@param objArgs ObjectiveArgs
    ---@param action? ObjectiveAction
    __init = function(self, objType, complete, title, description, objArgs, action)

        self.Type = objType
        self.Title = title
        self.Description = description

        self.Tag = ObjectiveHandlers.GetUniqueTag()

        self.Active = true
        self.Complete = false

        self.Hidden = objArgs.Hidden

        self.Trash = TrashBag()
        self.Decals = TrashBag()
        self.UnitMarkers = TrashBag()
        self.VizMarkers = TrashBag()

        self.IconOverrides = setmetatable({}, { __mode = "v" })

        self.NextTargetTag = 0
        self.PositionUpdateThreads = setmetatable({}, { __mode = "v" })

        self.SimStartTime = GetGameTimeSeconds()


        self.Args = objArgs

        self.ResultCallbacks = {}
        self.ProgressCallbacks = {}

        self:OnCreate()
        self:ProcessArgs(objArgs)

        if not Sync.ObjectivesTable then
            Sync.ObjectivesTable = {}
        end
        Sync.ObjectivesTable[self.Tag] = {
            tag = self.Tag,
            type = self.Type,
            complete = complete,
            hidden = self.Hidden,
            title = self.Title,
            description = self.Description,
            actionImage = ObjectiveHandlers.GetActionIcon(action or self.Icon),
            targetImage = objArgs.Image,
            progress = "",
            targets = self:_FormUserTargets(objArgs),
            loading = false,
            StartTime = self.SimStartTime,
        }
        self:PostCreate(objArgs)
    end,

    ---@param self IObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
    end,

    ---@param self IObjective
    OnCreate = function(self)
    end,

    ---Adds result callback for an objective
    ---@param self IObjective
    ---@param callback function
    AddResultCallback = function(self, callback)
        table.insert(self.ResultCallbacks, callback)
    end,

    ---Adds progress callback for an objective
    ---@param self IObjective
    ---@param callback function
    AddProgressCallback = function(self, callback)
        table.insert(self.ProgressCallbacks, callback)
    end,


    ---@param self IObjective
    ---@param success boolean
    ---@param data? any
    OnResult = function(self, success, data)
        self.Complete = success
        for _, v in self.ResultCallbacks do v(success, data) end

        self.Trash:Destroy()
        self.Decals:Destroy()
        self.VizMarkers:Destroy()
        self.UnitMarkers:Destroy()

        -- Revert strategic icons
        for _, v in self.IconOverrides do
            if not v:BeenDestroyed() then
                v:SetStrategicUnderlay("")
            end
        end

        if self.PositionUpdateThreads then
            for k, v in self.PositionUpdateThreads do
                if v then
                    KillThread(self.PositionUpdateThreads[k])
                    self.PositionUpdateThreads[k] = nil
                end
            end
        end
    end,


    ---@param self IObjective
    ---@param current integer
    ---@param total integer
    OnProgress = function(self, current, total)
        for _, v in self.ProgressCallbacks do v(current, total) end
    end,

    ---End objective with success
    ---@param self IObjective
    ---@param data? any
    Success = function(self, data)
        self:ManualResult(true, data)
    end,

    ---Fail of an objective
    ---@param self IObjective
    ---@param data? any
    Fail = function(self, data)
        self:ManualResult(false, data)
    end,

    ---@param self IObjective
    ---@param result boolean
    ---@param data? any
    ManualResult = function(self, result, data)
        self.Active = false
        self:OnResult(result, data)
        self:_UpdateUI('complete', result and 'complete' or 'failed')
    end,

    ---Updates UI of objective
    ---@param self IObjective
    ---@param field string
    ---@param data any
    _UpdateUI = function(self, field, data)
        SimObjectives.UpdateObjective(self.Title, field, data, self.Tag)
    end,


    ---@param self IObjective
    ---@param args ObjectiveArgs
    ProcessArgs = function(self, args)
        if not args then return end

        if args.ShowFaction then
            args.Image = ObjectiveHandlers.GetFactionImage(args.ShowFaction)
        end

        if args.Units then
            for _, v in args.Units do
                if v and v.IsDead and not v.Dead then
                    self:AddUnitTarget(v)
                end
            end
        end

        if args.Unit and not args.Unit.Dead then
            self:AddUnitTarget(args.Unit)
        end

        if args.Areas then
            for _, v in args.Areas do
                self:AddAreaTarget(v)
            end
        end

        if args.Area then
            self:AddAreaTarget(args.Area)
        end

    end,

    ---Forms user targets to be displayed in UI
    ---@param self IObjective
    ---@param args ObjectiveArgs
    ---@return UserTarget[]
    _FormUserTargets = function(self, args)
        ---@type UserTarget[]
        local userTargets = {}

        if args and args.Requirements then
            for _, req in args.Requirements do
                if req.Area then
                    table.insert(userTargets, { Type = 'Area', Value = ScenarioUtils.AreaToRect(req.Area) })
                end
            end
        elseif args and args.Timer then
            userTargets = { Type = 'Timer', Time = args.Timer }
        end

        if args.Category then
            local bps = EntityCategoryGetUnitList(args.Category)
            if not table.empty(bps) then
                table.insert(userTargets, { Type = 'Blueprint', BlueprintId = bps[1] })
            end
        end

        return userTargets
    end,


    ---@param self IObjective
    ---@param unit Unit
    AddUnitTarget = function(self, unit)
        self.NextTargetTag = self.NextTargetTag + 1
        if unit.Army == ObjectiveHandlers.GetPlayerArmy() then
            ObjectiveHandlers.SetupFocusNotify(self, unit, self.NextTargetTag)
        else
            ObjectiveHandlers.SetupNotify(self, unit, self.NextTargetTag)
        end
        if self.Args.AlwaysVisible then
            ObjectiveHandlers.SetupVizMarker(self, unit)
        end

        -- Mark the units unless MarkUnits == false
        if self.Args.MarkUnits == nil or self.Args.MarkUnits then
            local icon = ObjectiveHandlers.GetUnderlayIcon(self.Type)
            if icon then
                unit:SetStrategicUnderlay(icon)
            end
            table.insert(self.IconOverrides, unit)
        end
    end,


    ---@param self IObjective
    ---@param area Area
    AddAreaTarget = function(self, area)
        self.NextTargetTag = self.NextTargetTag + 1

        self:_UpdateUI('Target',
            {
                Type = 'Area',
                Value = ScenarioUtils.AreaToRect(area),
                TargetTag = self.NextTargetTag
            })

        if self.Args.AlwaysVisible then
            ObjectiveHandlers.SetupVizMarker(self, area)
        end
    end,

    ---Updates progress UI
    ---@param self IObjective
    ---@param current integer
    ---@param total integer
    UpdateProgressUI = function(self, current, total)
        self:_UpdateUI('Progress', ('%i/%i'):format(current, total))
    end
}


---@class CountObjective : IObjective
---@field Count integer
---@field Total integer
CountObjective = Class(IObjective)
{
    ---@param self CountObjective
    OnCreate = function(self)
        assert(self.Args.Units, self.Title .. " :Objective requires Units in Target specified!")
        
        self.Count = 0
        self.Total = table.getn(self.Args.Units)
    end,
}
