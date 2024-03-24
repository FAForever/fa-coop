_G.__debug = true

function GetChains()
    return Scenario.Chains
end

function ChainExist(chain)
    return GetChains()[chain] ~= nil
end

function CheckChain(chain)
    if not ChainExist(chain) then
        error(debug.traceback("Given chain " .. chain .. " doesn't exist!"))
    end
end

function CheckAIFunction(fileName, functionName)
    if not exists(fileName) or import(fileName)[functionName] == nil then
        error(debug.traceback(fileName .. " doesnt exist, or there is no " .. functionName))
    end
end

---comment
---@param color Color
---@return integer
function GetAlpha(color)
    return STR_xtoi(string.sub(color, 1, 2))
end

---comment
---@param color Color
---@return integer
function GetRed(color)
    return STR_xtoi(string.sub(color, 3, 4))
end

---comment
---@param color Color
---@return integer
function GetGreen(color)
    return STR_xtoi(string.sub(color, 5, 6))
end

---comment
---@param color Color
---@return integer
function GetBlue(color)
    return STR_xtoi(string.sub(color, 7, 8))
end

---comment
---@param color string
---@return integer
---@return integer
---@return integer
function UnpackColor(color)
    if color:len() == 6 then
        return GetAlpha(color), GetRed(color), GetGreen(color)
    end
    return GetRed(color), GetGreen(color), GetBlue(color)
end
