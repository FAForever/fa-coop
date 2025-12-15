local CountObjective = import("IObjective.lua").CountObjective

---@class LocateObjective : CountObjective
---@field UnitLocatedTrigger PlayerUnitIntelTrigger
---@field Located table<Unit, true>
LocateObjective = Class(CountObjective)
{
    Icon = "Locate",

    ---@param self LocateObjective
    OnCreate = function(self)
        CountObjective.OnCreate(self)
        self.Located = {}

        self.UnitLocatedTrigger = Oxygen.Triggers.PlayerUnitIntelTrigger(
            function(unit)
                self:OnUnitLocated(unit)
            end
        )
    end,

    ---@param self LocateObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)

        for _, unit in args.Units do
            self.UnitLocatedTrigger:Add(unit)
        end

        self:UpdateProgressUI(self.Count, self.Total)
    end,

    ---@param self LocateObjective
    ---@param unit Unit
    OnUnitLocated = function(self, unit)
        if not self.Active or self.Located[unit] then return end

        self.Located[unit] = true

        self.Count = self.Count + 1

        self:UpdateProgressUI(self.Count, self.Total)
        self:OnProgress(self.Count, self.Total)

        if self.Count == self.Total then
            self:Success()
        end
    end
}
