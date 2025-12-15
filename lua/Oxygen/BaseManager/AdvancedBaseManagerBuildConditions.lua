---@param aiBrain AIBrain
---@param baseName string
---@return boolean
function TransportsEnabled(aiBrain, baseName)
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end

    return bManager.FunctionalityStates.Transporting
end

---@param aiBrain AIBrain
---@param baseName string
---@param tech integer
---@return boolean
function TransportsTechAllowed(aiBrain, baseName, tech)
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end

    return bManager.TransportsTech >= tech
end

---@param aiBrain AIBrain
---@param baseName string
---@return boolean
function NeedTransports(aiBrain, baseName)
    ---@type AdvancedBaseManager
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end

    local transportPool = aiBrain:GetPlatoonUniquelyNamed(baseName .. "_TransportPool")
    if not transportPool then return true end

    local count = table.getn(transportPool:GetPlatoonUnits())

    if count >= bManager.TransportsNeeded then return false end

    local globalPool = aiBrain:GetPlatoonUniquelyNamed("TransportPool")
    if not globalPool then return true end

    local counter = 0

    for _, transport in globalPool:GetPlatoonUnits() do
        if not transport.Dead then
            aiBrain:AssignUnitsToPlatoon(transportPool, { transport }, 'Scout', "None")
            IssueMove({ transport }, bManager.Position)

            counter = counter + 1
            if counter + count >= bManager.TransportsNeeded then return false end
        end
    end

    return true
end
