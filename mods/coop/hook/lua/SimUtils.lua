local OldTransferUnitsOwnership = TransferUnitsOwnership

function TransferUnitsOwnership(units, ToArmyIndex)
    local newUnits = OldTransferUnitsOwnership(units, ToArmyIndex)
    for index,unit in units do
        local owner = unit:GetArmy()
        local disallowTransfer = owner == ToArmyIndex or
                                     unit:GetParent() ~= unit or (unit.Parent and unit.Parent ~= unit) or
                                     unit.CaptureProgress > 0

        if disallowTransfer then
            continue
        end
        
        unit:OnGive(newUnits[index])
    end
end