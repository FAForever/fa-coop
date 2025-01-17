local TimerObjective = import("Timer.lua").TimerObjective
local KillObjective = import("Kill.lua").KillObjective

---@class ProtectObjective : KillObjective, TimerObjective
---@field Required integer
ProtectObjective = Class(KillObjective, TimerObjective)
{
    Icon = "Protect",

    ---@param self ProtectObjective
    OnCreate = function(self)
        KillObjective.OnCreate(self)
        TimerObjective.OnCreate(self)

        self.Required = self.Args.NumRequired or self.Total
    end,

    ---@param self ProtectObjective
    ---@param args ObjectiveArgs
    PostCreate = function(self, args)
        KillObjective.PostCreate(self, args)
        TimerObjective.PostCreate(self, args)

        if args.ShowProgress then
            self:UpdateProgressUI(self.Total, self.Required)
        end
    end,

    ---@param self ProtectObjective
    ---@param unit Unit
    OnUnitKilled = function(self, unit)
        if not self.Active then return end

        self.Total = self.Total - 1

        self:OnProgress(self.Total, self.Required)

        if self.Args.ShowProgress then
            self:UpdateProgressUI(self.Total, self.Required)
            -- TODO
            -- elseif self.Args.PercentProgress then
            --     self:_UpdateUI('Progress', ('(%s%%)'):format(math.ceil(self.Total / max * 100)))
        end

        if self.Total < self.Required then
            self:Fail(unit)
            self:ResetSyncTimer()
        end
    end

}
