local oldAIBrain = AIBrain
AIBrain = Class(oldAIBrain) {
    -- Uses 'Naval Rally Point' for naval factories instead of classic one
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

    -- Full Share, only for human players.
    OnDefeat = function(self)
        self:SetResult("defeat")

        SetArmyOutOfGame(self:GetArmyIndex())

        import('/lua/SimUtils.lua').UpdateUnitCap(self:GetArmyIndex())
        import('/lua/SimPing.lua').OnArmyDefeat(self:GetArmyIndex())

        local function KillArmy()
            -- Human players only.
            if self.BrainType ~= 'Human' then return end
            WaitSeconds(10) -- Wait for commander explosion, then transfer units.
            local selfIndex = self:GetArmyIndex()
            local alivePlayers = {}

            -- Used to have units which were transferred to allies noted permanently as belonging to the new player
            local function TransferOwnershipOfBorrowedUnits(brains)
                for index, brain in brains do
                    local units = brain:GetListOfUnits(categories.ALLUNITS - categories.WALL, false)
                    if units and table.getn(units) > 0 then
                        for _, unit in units do
                            if unit.oldowner == selfIndex then
                                unit.oldowner = nil
                            end
                        end
                    end
                end
            end

            -- Transfer our units to other brains. Wait in between stops transfer of the same units to multiple armies.
            local function TransferUnitsToBrain(brains)
                if table.getn(brains) > 0 then
                    for k, brain in brains do
                        local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL - categories.COMMAND, false)
                        if units and table.getn(units) > 0 then
                            TransferUnitsOwnership(units, brain.index)
                            WaitSeconds(1)
                        end
                    end
                end
            end

            -- Sort the destiniation armies by score
            local function TransferUnitsToHighestBrain(brains)
                if table.getn(brains) > 0 then
                    table.sort(brains, function(a, b) return a.score > b.score end)
                    TransferUnitsToBrain(brains)
                end
            end

            -- Find alive players
            for _, index in ScenarioInfo.HumanPlayers do
                local brain = ArmyBrains[index]
                if not brain:IsDefeated() and selfIndex ~= index then
                    brain.index = index
                    brain.score = CalculateBrainScore(brain)
                    table.insert(alivePlayers, brain)
                end
            end
            WARN('Num' .. table.getn(alivePlayers))
            TransferUnitsToHighestBrain(alivePlayers) -- Transfer things to allies, highest score first
            TransferOwnershipOfBorrowedUnits(alivePlayers) -- Give stuff away permanently

            -- Kill all units left over
            local tokill = self:GetListOfUnits(categories.ALLUNITS - categories.WALL, false)
            if tokill and table.getn(tokill) > 0 then
                for index, unit in tokill do
                    unit:Kill()
                end
            end
        end

        ForkThread(KillArmy)

        if self.Trash then
            self.Trash:Destroy()
        end
    end,
}