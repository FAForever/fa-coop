local TableGetn, unpack = table.getn, unpack

---@class CampaignAIBrain
AIBrain = Class(AIBrain) {

    ---@param self CampaignAIBrain
    ---@param bCs table
    ---@param index number
    ---@return boolean
    PBMCheckBuildConditions = function(self, bCs, index)
        local PBMBuildConditionsTable = self.PBM.BuildConditionsTable
        local isAll = (bCs.Type or "ALL") == "ALL"

        for k, v in bCs do
            if k == "Type" then
                continue
            end

            if not v.LookupNumber then
                v.LookupNumber = {}
            end

            if not v.LookupNumber[index] then
                local found = false
                if v[3][1] == "default_brain" then
                    table.remove(v[3], 1)
                end

                local argc = TableGetn(v[3])

                for num, bcData in PBMBuildConditionsTable do
                    if bcData[1] == v[1] and bcData[2] == v[2] and TableGetn(bcData[3]) == argc then
                        local tablePos = 1
                        found = num
                        while tablePos <= argc do
                            if bcData[3][tablePos] ~= v[3][tablePos] then
                                found = false
                                break
                            end
                            tablePos = tablePos + 1
                        end
                    end
                end

                if found then
                    v.LookupNumber[index] = found
                else
                    table.insert(PBMBuildConditionsTable, v)
                    v.LookupNumber[index] = TableGetn(PBMBuildConditionsTable)
                end
            end

            local conditions = PBMBuildConditionsTable[ v.LookupNumber[index] ]

            if not conditions.Cached[index] then
                if not conditions.Cached then
                    conditions.Cached = {}
                    conditions.CachedVal = {}
                end

                conditions.Cached[index] = true
                conditions.CachedVal[index] = import(conditions[1])[ conditions[2] ](self, unpack(conditions[3]))

                self.BCFuncCalls = self.BCFuncCalls or 0

                if index == 3 then
                    self.BCFuncCalls = self.BCFuncCalls + 1
                end
            end

            local result = conditions.CachedVal[index]

            if isAll then
                if not result then
                    return false
                end
            elseif result then
                return true
            end
        end
        return isAll
    end,

    ---Returns existing platoon with name or makes it
    ---@param self CampaignAIBrain
    ---@param name string
    ---@return Platoon
    GetPlatoonUniquelyNamedOrMake = function(self, name)
        local platoon = self:GetPlatoonUniquelyNamed(name)
        if not platoon then
            platoon = self:MakePlatoon("", "")
            platoon:UniquelyNamePlatoon(name)
        end
        return platoon
    end
}
