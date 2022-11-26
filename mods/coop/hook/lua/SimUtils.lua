do
    --- Filter out units that were set in the script that they can't be given to other players
    local oldTransferUnitsOwnership = TransferUnitsOwnership
    TransferUnitsOwnership = function(units, ToArmyIndex, captured)

        reprsl(debug.traceback())

        if not units then
            return
        end

        local toGiveUnits = {}
        for _, v in units do
            if v.CanBeGiven then
                table.insert(toGiveUnits, v)
            end
        end

        return oldTransferUnitsOwnership(toGiveUnits, ToArmyIndex, captured)
    end
end

--- Update unit cap only for human players
function UpdateUnitCap(deadArmy)
    if ArmyBrains[deadArmy].BrainType ~= 'Human' then return end
    import('/lua/ScenarioFramework.lua').SetSharedUnitCap()
end

