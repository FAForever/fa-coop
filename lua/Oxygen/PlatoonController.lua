local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local PlatoonAIsLand = import("PlatoonAIs/Land.lua")


---@class PlatoonController
---@field platoon Platoon
PlatoonController = ClassSimple
{

    ---Initializes the platoon controller
    ---@param self PlatoonController
    ---@param platoon? Platoon
    __init = function(self, platoon)
        if platoon then
            self:Platoon(platoon)
        end
    end,

    ---Applies given function to units of platoon
    ---@param self PlatoonController
    ---@param fn fun(unit:Unit)
    ---@return PlatoonController
    ApplyToUnits = function(self, fn)
        for _, unit in self.platoon:GetPlatoonUnits() do
            fn(unit)
        end
        return self
    end,

    ---Assigns platoon to be used by the controller
    ---@param self PlatoonController
    ---@param platoon Platoon
    ---@return PlatoonController
    Platoon = function(self, platoon)
        self.platoon = assert(platoon)
        return self
    end,

    ---Returns the platoon
    ---@param self PlatoonController
    ---@return Platoon
    GetPlatoon = function(self)
        return self.platoon
    end,

    ---Creates platoon from unit group defined in map and uses it
    ---@param self PlatoonController
    ---@param armyName ArmyName
    ---@param unitGroup UnitGroup
    ---@param formation? FormationType
    ---@return PlatoonController
    FromUnitGroup = function(self, armyName, unitGroup, formation)
        return self:Platoon(ScenarioUtils.CreateArmyGroupAsPlatoon(armyName, unitGroup, formation or 'NoFormation'))
    end,

    ---Creates platoon from unit group defined in map and uses it
    ---@param self PlatoonController
    ---@param armyName ArmyName
    ---@param unitGroup UnitGroup
    ---@param formation? FormationType
    ---@param veterancy? integer
    ---@return PlatoonController
    FromUnitGroupVeteran = function(self, armyName, unitGroup, formation, veterancy)
        return self:Platoon(
            ScenarioUtils.CreateArmyGroupAsPlatoonVeteran(armyName, unitGroup, formation or 'NoFormation', veterancy)
        )
    end,


    ---Creates platoon from given units of aiBrain
    ---@param self PlatoonController
    ---@param units Unit[]
    ---@param aiBrain AIBrain
    ---@param squad PlatoonSquads?
    ---@param formation FormationType?
    ---@return PlatoonController
    FromUnits = function(self, units, aiBrain, squad, formation)
        self.platoon = aiBrain:MakePlatoon("", "")
        aiBrain:AssignUnitsToPlatoon(self.platoon, units, squad or "None", formation or "NoFormation")
        return self
    end,


    ---Adds units to platoon
    ---@param self PlatoonController
    ---@param units Unit[]
    ---@param squad? PlatoonSquads
    ---@param formation? FormationType
    ---@return PlatoonController
    AddUnits = function(self, units, squad, formation)
        assert(self.platoon, "No platoon for PlatoonController specified yet")

        ---@type AIBrain
        local aiBrain = self.platoon:GetBrain()
        aiBrain:AssignUnitsToPlatoon(self.platoon, units, squad or "None", formation or "NoFormation")
        return self
    end,


    AddUnit = function(self, unit, squad, formation)
        return self:AddUnits({ unit }, squad, formation)
    end,

    ---Orders platoon to move along the chain
    ---@param self PlatoonController
    ---@param chain MarkerChain
    ---@param squad? PlatoonSquads
    ---@return PlatoonController
    MoveChain = function(self, chain, squad)
        ScenarioFramework.PlatoonMoveChain(self.platoon, chain, squad)
        return self
    end,

    ---Orders platoon to patrol along the chain
    ---@param self PlatoonController
    ---@param chain MarkerChain
    ---@param squad? PlatoonSquads
    ---@return PlatoonController
    PatrolChain = function(self, chain, squad)
        ScenarioFramework.PlatoonPatrolChain(self.platoon, chain, squad)
        return self
    end,

    ---Orders platoon to attack-move along the chain
    ---@param self PlatoonController
    ---@param chain MarkerChain
    ---@param squad? PlatoonSquads
    ---@return PlatoonController
    AttackChain = function(self, chain, squad)
        ScenarioFramework.PlatoonAttackChain(self.platoon, chain, squad)
        return self
    end,

    ---Orders to platoon to attack with transports with specified landing and attack chains
    ---@param self PlatoonController
    ---@param landingChain MarkerChain
    ---@param attackChain MarkerChain
    ---@param instant? boolean @makes platoon units to be in transport instantly
    ---@param moveChain? MarkerChain @move chain for units to start with
    ---@return PlatoonController
    AttackWithTransports = function(self, landingChain, attackChain, instant, moveChain)
        ScenarioFramework.PlatoonAttackWithTransports(self.platoon, landingChain, attackChain, instant, moveChain)
        return self
    end,

    ---Orders to platoon to attack with transports with specified landing and attack chains and then returns transports into pool
    ---@param self PlatoonController
    ---@param landingChain MarkerChain
    ---@param attackChain MarkerChain
    ---@param instant? boolean @makes platoon units to be in transport instantly
    ---@param moveChain? MarkerChain @move chain for units to start with
    ---@return PlatoonController
    AttackWithTransportsReturnToPool = function(self, landingChain, attackChain, instant, moveChain)
        PlatoonAIsLand.AttackWithTransportsReturnToPool(self.platoon, landingChain, attackChain, instant, moveChain)
        return self
    end,
    
    -- TODO
}
