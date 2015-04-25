-- Add the PatrolLocationFactoriesAI function from Vanilla, because ZeP decided that was a good idea
-- and now a bunch of the coop maps catch fire if it's not there.
-- This should probably be looked at more carefully.

local BasePlatoon = Platoon
Platoon = Class(BasePlatoon) {
    PatrolLocationFactoriesAI = function(self)
        local aiBrain = self:GetBrain()
        local location = self.PlatoonData.LocationType or 'MAIN'
        while aiBrain:PlatoonExists(self) do
            self:Stop()
            local factories = aiBrain:PBMGetLocationFactories(location)
            if factories then
                for fType,fac in factories do
                    if not fac:IsDead() then
                        self:Patrol(fac:GetPosition())
                        local guards = fac:GetGuards()
                        if guards then
                            for num,guard in guards do
                                self:Patrol(guard:GetPosition())
                            end
                        end
                    end
                end
            else
                aiBrain:DisbandPlatoon(self)
            end
            WaitSeconds(71)
        end
    end,
}
