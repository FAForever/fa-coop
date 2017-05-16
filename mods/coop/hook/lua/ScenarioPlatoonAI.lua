function StartBaseConstruction(eng, engTable, data, aiBrain)
    local cons = data.Construction
    local buildingTmpl
    if cons and cons.BuildingTemplate then
        buildingTmpl = cons.BuildingTemplate
    end
    local unitBeingBuilt
    if cons and cons.BuildStructures then
        local baseTmpl = aiBrain.BaseTemplates[cons.BaseTemplate].Template
        local closeToBuilder = nil
        if cons.BuildClose then
            closeToBuilder = eng
        end
        for _, v in cons.BuildStructures do
            if string.find(v, 'T2Air') or string.find(v, 'T3Air')
                or string.find(v, 'T2Land') or string.find(v, 'T3Land')
                or string.find(v, 'T2Naval') or string.find(v, 'T3Naval') then
                v = string.gsub(v, '2', '1')
                v = string.gsub(v, '3', '1')
            end
            EngineerBuildStructure(aiBrain, eng, v, baseTmpl, buildingTmpl)
            if eng.UnitBeingBuilt then
                unitBeingBuilt = eng.UnitBeingBuilt
            end
            repeat
                WaitSeconds(7)
                if eng:IsDead() then
                    eng, engTable = AssistOtherEngineer(eng, engTable, unitBeingBuilt)
                    if not eng then
                        return false
                    end
                else
                    unitBeingBuilt = eng.UnitBeingBuilt
                end
            until not (eng:IsUnitState('Building') or eng:IsUnitState('Repairing') or eng:IsUnitState('Moving') or eng:IsUnitState('Reclaiming'))
        end
    end
    return true
end
