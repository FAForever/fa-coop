---@alias AirAttacksChildType
--- | 'Interceptors'
--- | 'LightGunships'
--- | 'Bombers'
--- |
--- | 'TorpedoBombers'
--- | 'GuidedMissiles'
--- | 'Gunships'
--- | 'CombatFighters'
--- |
--- | 'StratBombers'
--- | 'AirSuperiority'
--- | 'HeavyGunships'
--- | 'HeavyTorpedoBombers'


local VALID_TYPES =
{
    ['Interceptors'] = true,
    ['LightGunships'] = true,
    ['Bombers'] = true,
    ['TorpedoBombers'] = true,
    ['GuidedMissiles'] = true,
    ['Gunships'] = true,
    ['CombatFighters'] = true,
    ['StratBombers'] = true,
    ['AirSuperiority'] = true,
    ['HeavyGunships'] = true,
    ['HeavyTorpedoBombers'] = true,
}


local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class AirAttacksOpAIBuilder : IOpAIBuilder
AirAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType
    _Validate = function(self, childrenType)
        assert(VALID_TYPES[childrenType], "Unknown children type " .. childrenType)
    end,

    Type = 'AirAttacks',

    ---Sets quantity of children for OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType
    ---@param quantity integer
    ---@return AirAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        self:_Validate(childrenType)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType
    ---@return AirAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType
    ---@return AirAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self AirAttacksOpAIBuilder
    ---@param childrenType AirAttacksChildType
    ---@return AirAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
