---@alias NavalAttacksChildType
--- | 'Battleships'
--- | 'Destroyers'
--- | 'Cruisers'
--- | 'Frigate'
--- | 'Submarines'
--- | 'Frigates'
--- | 'T2Submarines'
--- | 'UtilityBoats'
--- | 'Carriers'
--- | 'NukeSubmarines'
--- | 'AABoats'
--- | 'MissileShips'
--- | 'T3Submarines'
--- | 'TorpedoBoats'
--- | 'BattleCruisers'

local VALID_TYPES =
{
    ['Battleships'] = true,
    ['Destroyers'] = true,
    ['Cruisers'] = true,
    ['Frigate'] = true,
    ['Submarines'] = true,
    ['Frigates'] = true,
    ['T2Submarines'] = true,
    ['UtilityBoats'] = true,
    ['Carriers'] = true,
    ['NukeSubmarines'] = true,
    ['AABoats'] = true,
    ['MissileShips'] = true,
    ['T3Submarines'] = true,
    ['TorpedoBoats'] = true,
    ['BattleCruisers'] = true,
}


local IOpAIBuilder = import("BasicOpAIBuilder.lua").IOpAIBuilder

---@class NavalAttacksOpAIBuilder : IOpAIBuilder
NavalAttacksOpAIBuilder = Class(IOpAIBuilder)
{
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType
    _Validate = function(self, childrenType)
        assert(VALID_TYPES[childrenType], "Unknown children type " .. childrenType)
    end,

    Type = 'NavalAttacks',
    ---Sets quantity of children for OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType
    ---@param quantity integer
    ---@return NavalAttacksOpAIBuilder
    Quantity = function(self, childrenType, quantity)
        self:_Validate(childrenType)
        return IOpAIBuilder.Quantity(self, childrenType, quantity)
    end,

    ---Enables children of OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType
    ---@return NavalAttacksOpAIBuilder
    EnableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.EnableChild(self, childrenType)
    end,

    ---Disables children of OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType
    ---@return NavalAttacksOpAIBuilder
    DisableChild = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.DisableChild(self, childrenType)
    end,

    ---Removes children of OpAI
    ---@param self NavalAttacksOpAIBuilder
    ---@param childrenType NavalAttacksChildType
    ---@return NavalAttacksOpAIBuilder
    RemoveChildren = function(self, childrenType)
        self:_Validate(childrenType)
        return IOpAIBuilder.RemoveChildren(self, childrenType)
    end,
}
