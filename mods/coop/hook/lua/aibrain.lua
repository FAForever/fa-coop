local oldAIBrain = AIBrain
-- Uses 'Naval Rally Point' for naval factories instead of classic one
AIBrain = Class(oldAIBrain) {
    PBMSetRallyPoint = function(self, factories, location, rallyLoc, markerType)
        if table.getn(factories) > 0 then
            local rally
            local position = factories[1]:GetPosition()
            for facNum, facData in factories do
                if facNum > 1 then
                    position[1] = position[1] + facData:GetPosition()[1]
                    position[3] = position[3] + facData:GetPosition()[3]
                end
            end

            position[1] = position[1] / table.getn(factories)
            position[3] = position[3] / table.getn(factories)
            if not rallyLoc and not location.UseCenterPoint then
                local pnt
                if not markerType then
                    markerType = 'Rally Point'
                    if EntityCategoryContains(categories.NAVAL, factories[1]) then
                        markerType = 'Naval Rally Point'
                    end
                    pnt = AIUtils.AIGetClosestMarkerLocation(self, markerType, position[1], position[3])
                    -- In case Naval Rally Point is not present, to keep compatibility until the missions are changed to have one.
                    if not pnt then
                        pnt = AIUtils.AIGetClosestMarkerLocation(self, 'Rally Point', position[1], position[3])
                    end
                else
                    pnt = AIUtils.AIGetClosestMarkerLocation(self, markerType, position[1], position[3])
                end
                if pnt and table.getn(pnt) == 3 then
                    rally = Vector(pnt[1], pnt[2], pnt[3])
                end
            elseif not rallyLoc and location.UseCenterPoint then
                rally = location.Location
            elseif rallyLoc then
                rally = rallyLoc
            else
                error('*ERROR: PBMSetRallyPoint - Missing Rally Location and Marker Type', 2)
                return false
            end

            if rally then
                for _, v in factories do
                    IssueClearFactoryCommands({v})
                    IssueFactoryRallyPoint({v}, rally)
                end
            end
        end
        return true
    end,
}