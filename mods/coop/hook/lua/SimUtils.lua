do
    --- Filter out units that were set in the script that they can't be given to other players
    local oldTransferUnitsOwnership = TransferUnitsOwnership
    TransferUnitsOwnership = function(units, ToArmyIndex)
        if not units then return end
        local toGiveUnits = {}
        for _, v in units do
            if v.CanBeGiven then
                table.insert(toGiveUnits, v)
            end
        end
        oldTransferUnitsOwnership(toGiveUnits, ToArmyIndex)
    end
end

--- Update unit cap only for human players
function UpdateUnitCap(deadArmy)
    if ArmyBrains[deadArmy].BrainType ~= 'Human' then return end
    import('/lua/ScenarioFramework.lua').SetSharedUnitCap()
end

