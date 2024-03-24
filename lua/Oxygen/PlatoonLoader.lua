---Creates Platoon loader for given base manager
---@alias PlatoonLoaderInit fun(baseManager:BaseManager):PlatoonLoader

---@deprecated
---@type PlatoonLoaderInit
---@class PlatoonLoader
---@field _bm BaseManager
PlatoonLoader = ClassSimple
{
    ---@type PlatoonLoaderInit
    __init = function(self, baseManager)
        self._bm = baseManager
    end,

    ---comment
    ---@param self PlatoonLoader
    ---@param platoons PlatoonSpecTable[]
    LoadPlatoons = function(self, platoons)
        local location = self._bm.BaseName
        local aiBrain = self._bm.AIBrain
        for _, platoon in platoons do
            if platoon.LocationType ~= location then
                local prevLocation = platoon.LocationType
                platoon.LocationType = location
                aiBrain:PBMAddPlatoon(platoon)
                platoon.LocationType = prevLocation
            else
                aiBrain:PBMAddPlatoon(platoon)
            end
        end
    end,

    ---comment
    ---@param self PlatoonLoader
    ---@param opAIs OpAITable[]
    LoadOpAIs = function(self, opAIs)
        local bm = self._bm
        for _, opAItable --[[@as OpAITable]]in opAIs do

        
            if opAItable.unitGroup then
                ---@type OpAIData
                local data = opAItable.data
                local buildCondition = opAItable.buildCondition
                if buildCondition then
                    data.BuildCondition = {
                        {
                            buildCondition.name,
                            buildCondition.func,
                            buildCondition.condition
                        }
                    }
                end
                bm:AddUnitAI(
                    opAItable.unitGroup,
                    data
                )
            else
                local opAI = bm:AddOpAI(
                    opAItable.type,
                    opAItable.name,
                    opAItable.data
                )

                for childrenType, quantity in opAItable.quantity do
                    opAI:SetChildQuantity(childrenType, quantity)
                end

                for childrenType, state in opAItable.childrenState do
                    opAI:SetChildActive(childrenType, state)
                end

                for lockType, lockData in opAItable.lock do
                    opAI:SetLockingStyle(lockType, lockData)
                end
                if opAItable.buildCondition then
                    opAI:AddBuildCondition(
                        opAItable.buildCondition.name,
                        opAItable.buildCondition.func,
                        opAItable.buildCondition.condition
                    )
                end
                if opAItable.remove then
                    opAI:RemoveChildren(opAItable.remove)
                end

                if opAItable.formation then
                    opAI:SetFormation(opAItable.formation)
                end
            end
        end

    end,

}
