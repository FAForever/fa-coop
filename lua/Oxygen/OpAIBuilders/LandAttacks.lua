---@alias LandAttacksChildType
--- | 'T3Transports'
--- | 'MobileMissilePlatforms'
--- | 'MobileShields'
--- | 'HeavyBots'
--- | 'MobileFlak'
--- | 'MobileHeavyArtillery'
--- | 'MobileStealth'
--- | 'SiegeBots'
--- | 'MobileBombs'
--- | 'RangeBots'
--- | 'LightArtillery'
--- | 'AmphibiousTanks'
--- | 'LightTanks'
--- | 'HeavyMobileAntiAir'
--- | 'MobileMissiles'
--- | 'HeavyTanks'
--- | 'MobileAntiAir'
--- | 'LightBots'
--- | 'T1Transports'
--- | 'T2Transports'


local VALID_TYPES =
{
    ['T3Transports'] = true,
    ['MobileMissilePlatforms'] = true,
    ['MobileShields'] = true,
    ['HeavyBots'] = true,
    ['MobileFlak'] = true,
    ['MobileHeavyArtillery'] = true,
    ['MobileStealth'] = true,
    ['SiegeBots'] = true,
    ['MobileBombs'] = true,
    ['RangeBots'] = true,
    ['LightArtillery'] = true,
    ['AmphibiousTanks'] = true,
    ['LightTanks'] = true,
    ['HeavyMobileAntiAir'] = true,
    ['MobileMissiles'] = true,
    ['HeavyTanks'] = true,
    ['MobileAntiAir'] = true,
    ['LightBots'] = true,
    ['T1Transports'] = true,
    ['T2Transports'] = true,
}

local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class LandAttacksOpAIBuilder : IOpAIBuilder
LandAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType
    _Validate = function(self, childrenType)
        assert(VALID_TYPES[childrenType], "Unknown children type " .. childrenType)
    end,

    Type = "BasicLandAttack",
    ---Sets quantity of children for OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType
    ---@param quantity integer
    ---@return LandAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        self:_Validate(childrenType)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType
    ---@return LandAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType
    ---@return LandAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self LandAttacksOpAIBuilder
    ---@param childrenType LandAttacksChildType
    ---@return LandAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
