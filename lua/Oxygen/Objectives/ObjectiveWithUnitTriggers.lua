local IObjective = import("IObjective.lua").IObjective
local Triggers = Oxygen.Triggers

---@class ObjectiveWithUnitTriggers : IObjective
---@field UnitGivenTrigger IUnitTrigger?
---@field UnitReclaimedTrigger IUnitTrigger?
---@field UnitKilledTrigger IUnitTrigger?
---@field UnitCapturedTrigger IUnitTrigger?
ObjectiveWithUnitTriggers = Class(IObjective)
{
    UnitGivenTriggerType = Triggers.UnitGivenTrigger,
    UnitReclaimedTriggerType = Triggers.UnitReclaimedTrigger,
    UnitKilledTriggerType = Triggers.UnitDeathTrigger,
    UnitCapturedTriggerType = Triggers.UnitCapturedNewTrigger,

    ---@param self ObjectiveWithUnitTriggers
    OnCreate = function(self)
        self:CreateTriggers()
    end,

    ---@param self ObjectiveWithUnitTriggers
    CreateTriggers = function(self)
        if self.UnitGivenTriggerType then
            self.UnitGivenTrigger = self.UnitGivenTriggerType(
                function(oldUnit, newUnit)
                    self:OnUnitGiven(oldUnit, newUnit)
                end
            )
        end
        if self.UnitReclaimedTriggerType then
            self.UnitReclaimedTrigger = self.UnitReclaimedTriggerType
            (
                function(unit, reclaimer)
                    self:OnUnitReclaimed(unit, reclaimer)
                end
            )
        end
        if self.UnitKilledTriggerType then
            self.UnitKilledTrigger = self.UnitKilledTriggerType(
                function(unit)
                    self:OnUnitKilled(unit)
                end
            )
        end
        if self.UnitCapturedTriggerType then
            self.UnitCapturedTrigger = self.UnitCapturedTriggerType(
                function(unit, captor)
                    self:OnUnitCaptured(unit, captor)
                end
            )
        end
    end,

    ---@param self ObjectiveWithUnitTriggers
    ---@param unit Unit
    AddTriggersToUnit = function(self, unit)
        if self.UnitGivenTrigger then
            self.UnitGivenTrigger:Add(unit)
        end
        if self.UnitReclaimedTrigger then
            self.UnitReclaimedTrigger:Add(unit)
        end
        if self.UnitKilledTrigger then
            self.UnitKilledTrigger:Add(unit)
        end
        if self.UnitCapturedTrigger then
            self.UnitCapturedTrigger:Add(unit)
        end
    end,


    ---@param self ObjectiveWithUnitTriggers
    ---@param unit Unit
    ---@param captor Unit
    OnUnitCaptured = function(self, unit, captor)
    end,

    ---@param self ObjectiveWithUnitTriggers
    ---@param unit Unit
    OnUnitKilled = function(self, unit)
    end,

    ---@param self ObjectiveWithUnitTriggers
    ---@param oldUnit Unit
    ---@param newUnit Unit
    OnUnitGiven = function(self, oldUnit, newUnit)
    end,

    ---@param self ObjectiveWithUnitTriggers
    ---@param unit Unit
    OnUnitReclaimed = function(self, unit, reclaimer)
    end

}
