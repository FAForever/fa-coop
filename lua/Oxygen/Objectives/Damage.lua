local CountObjective = import("IObjective.lua").CountObjective
local KillObjective = import("Kill.lua").KillObjective

---@class DamageObjective : KillObjective
---@field UnitDamagedTrigger UnitDamagedTrigger
DamageObjective = Class(KillObjective)
{
    Icon = "Kill",

    ---@param self DamageObjective
    OnCreate = function(self)
        CountObjective.OnCreate(self)

        self.UnitDamagedTrigger = Oxygen.Triggers.UnitDamagedTrigger(
            function(unit, instigator)
                self:OnUnitKilled(unit)
            end
        )

        self.UnitGivenTrigger = Oxygen.Triggers.UnitGivenTrigger(
            function(oldUnit, newUnit)
                self:OnUnitGiven(oldUnit, newUnit)
            end
        )

        assert(self.Args.Amount, self.Title .. " :Objective requires 'Amount' specified in Target!")
    end,

    ---@param self DamageObjective
    ---@param unit Unit
    AddTriggers = function(self, unit)
        self.UnitDamagedTrigger:Add(unit, self.Args.Amount, self.Args.RepeatNum)
        self.UnitGivenTrigger:Add(unit)
    end,


}
