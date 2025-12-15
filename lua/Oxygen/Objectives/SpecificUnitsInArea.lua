local EntityCategoryContains = EntityCategoryContains
local CountObjective = import("IObjective.lua").CountObjective
local ObjectiveHandlers = import("ObjectiveHandlers.lua")
local ObjectiveArrow = import("/lua/objectivearrow.lua").ObjectiveArrow
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")

local KillObjective = import("Kill.lua").KillObjective

---@class SpecificUnitsInAreaObjective : KillObjective
---@field Required integer
---@field Rect Rectangle
SpecificUnitsInAreaObjective = Class(KillObjective)
{
    Icon = "Move",

    ---@param self SpecificUnitsInAreaObjective
    OnCreate = function(self)
        KillObjective.OnCreate(self)

        self.Required = self.Args.NumRequired or self.Total
    end,

    ---@param self SpecificUnitsInAreaObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        KillObjective.PostCreate(self, args)

        assert(args.Area, self.Title .. " :Objective requires 'Area' in Target!")

        self.Rect = ScenarioUtils.AreaToRect(args.Area)

        if args.MarkArea then
            self.Decals:Add(ObjectiveHandlers.CreateAreaObjectiveDecal(args.Area))
        end

        self.Trash:Add(ForkThread(self.WatchAreaThread, self))

        if args.ShowProgress then
            self:UpdateProgressUI(self.Count, self.Required)
        end
    end,


    ---@param self SpecificUnitsInAreaObjective
    WatchAreaThread = function(self)
        local rect = self.Rect
        local args = self.Args
        local units = args.Units

        while self.Active do
            local cnt = 0
            for _, unit in units do
                if not unit.Dead and ScenarioUtils.InRect(unit:GetPosition(), rect) then
                    cnt = cnt + 1
                end
            end

            if cnt ~= self.Count then
                self.Count = cnt

                if args.ShowProgress then
                    self:UpdateProgressUI(self.Count, self.Required)
                end
                self:OnProgress(self.Count, self.Required)
            end

            if cnt >= self.Required then
                self:OnUnitsReached(units)
                return
            end
            WaitTicks(5)
        end
    end,


    ---@param self SpecificUnitsInAreaObjective
    ---@param unit Unit
    OnUnitKilled = function(self, unit)
        if not self.Active then return end

        self.Total = self.Total - 1

        if self.Args.ShowProgress then
            self:UpdateProgressUI(self.Count, self.Required)
        end
        self:OnProgress(self.Count, self.Required)

        if self.Total < self.Required then
            self:Fail(self.Args.Units)
        end
    end,

    ---Called when all required amount of units reached objective area
    ---@param self SpecificUnitsInAreaObjective
    ---@param units Unit[]
    OnUnitsReached = function(self, units)
        self:Success(units)
    end,

}
