---@alias EngineerAttacksChildType
--- | 'T3Transports'
--- | 'T2Transports'
--- | 'T1Transports'
--- | 'T3Engineers'
--- | 'T2Engineers'
--- | 'CombatEngineers'
--- | 'T1Engineers'
--- | 'MobileShields'


local VALID_TYPES =
{
    ['T3Transports'] = true,
    ['T2Transports'] = true,
    ['T1Transports'] = true,
    ['T3Engineers'] = true,
    ['T2Engineers'] = true,
    ['CombatEngineers'] = true,
    ['T1Engineers'] = true,
    ['MobileShields'] = true,
}



local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class EngineerAttacksOpAIBuilder : IOpAIBuilder
EngineerAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType
    _Validate = function(self, childrenType)
        assert(VALID_TYPES[childrenType], "Unknown children type " .. childrenType)
    end,


    Type = 'EngineerAttack',
    ---Sets quantity of children for OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType
    ---@param quantity integer
    ---@return EngineerAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        self:_Validate(childrenType)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType
    ---@return EngineerAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType
    ---@return EngineerAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self EngineerAttacksOpAIBuilder
    ---@param childrenType EngineerAttacksChildType
    ---@return EngineerAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
