local function AllowGiveUnit(Objective, Target, WithObjectiveArrow)

    Objective.AddBasicUnitTarget = function(self, unit)
        Objective:AddUnitTarget( unit )
        if Target.MarkUnits or WithObjectiveArrow then
            local ObjectiveArrow = import('objectiveArrow.lua').ObjectiveArrow
            local arrow = ObjectiveArrow { AttachTo = unit }
            table.insert( Objective.UnitMarkers, arrow )
        end
    end
    
    local function OnGiveUnit(unit, newUnit)
        local index = -1
        for i,v in Target.Units do
            if v == unit then
                index = i
                break
            end
        end
        table.remove(Target.Units, index)
        table.insert(Target.Units, newUnit)
        Objective:AddBasicUnitTarget(newUnit)
    end
    
    for _, v in Target.Units do
        Triggers.CreateGiveUnitTrigger(OnGiveUnit, v )
    end
    
    return Objective
end

local OldKill = Kill
function Kill(Type, Complete, Title, Description, Target)
    local objective = OldKill(Type, Complete, Title, Description, Target)
    return AllowGiveUnit(objective, Target, Target.MarkUnits == nil)
end

local OldCapture = Capture
function Capture(Type, Complete, Title, Description, Target)
    local objective = OldCapture(Type, Complete, Title, Description, Target)
    return AllowGiveUnit(objective, Target, Target.MarkUnits == nil)
end

local OldKillOrCapture = KillOrCapture
function KillOrCapture(Type, Complete, Title, Description, Target)
    local objective = OldKillOrCapture(Type, Complete, Title, Description, Target)
    return AllowGiveUnit(objective, Target, Target.MarkUnits == nil)
end

local OldReclaim = Reclaim
function Reclaim(Type, Complete, Title, Description, Target)
    local objective = OldReclaim(Type, Complete, Title, Description, Target)
    return AllowGiveUnit(objective, Target, true)
end

local OldLocate = Locate
function Locate(Type, Complete, Title, Description, Target)
    local objective = OldLocate(Type,Complete,Title,Description,Target)
    return AllowGiveUnit(objective, Target)
end

local OldSpecificUnitsInArea = SpecificUnitsInArea
function SpecificUnitsInArea(Type, Complete, Title, Description, Target)
    local objective = OldSpecificUnitsInArea(Type,Complete,Title,Description,Target)
    return AllowGiveUnit(objective, Target)
end

local OldProtect = Protect
function Protect(Type, Complete, Title, Description, Target)
    local objective = OldProtect(Type,Complete,Title,Description,Target)
    return AllowGiveUnit(objective, Target)
end