---@alias DifficultyStrings
--- |    "Hard"
--- |    "Medium"
--- |    "Easy"

---@alias DifficultyData (DifficultyStrings[])|DifficultyStrings
---@alias DifficultyLevel 1|2|3


local diffDataToLevel =
{
    ["Hard"] = 3,
    ["Medium"] = 2,
    ["Easy"] = 1,
}

local difficulty

---returns difficulty level based on difficulty data
---@param diffData DifficultyData
---@return DifficultyLevel
function ParseDifficulty(diffData)
    difficulty = difficulty or ScenarioInfo.Options.Difficulty or 1

    if type(diffData) == "string" then
        return diffDataToLevel[diffData]
    end

    for _, diffString in diffData do
        if diffDataToLevel[diffString] == difficulty then
            return difficulty
        end
    end

    return 0 -- didnt match any
end

local difficultyValuesRegister = {}


function Add(key, value)
    difficulty = difficulty or ScenarioInfo.Options.Difficulty or 1
    difficultyValuesRegister[key] = value
end

function Extend(tbl)
    for k, v in tbl do
        Add(k, v)
    end
end

---@deprecated
function Get(key)
    return difficultyValuesRegister[key][difficulty]
end

local difficultyMetaTable = {
    __index = function(tbl, key)
        return difficultyValuesRegister[key][difficulty]
    end,

    __newindex = function(tbl, key, value)
        difficulty = difficulty or ScenarioInfo.Options.Difficulty or 1
        difficultyValuesRegister[key] = value
    end
}

---@type table<string, any>
values = setmetatable({}, difficultyMetaTable)


if __debug then
    function Add(key, value)
        if difficultyValuesRegister[key] ~= nil then
            error(debug.traceback("Difficulty value " .. key .. " already exists, attempt to overwrite!"))
        end
        difficulty = difficulty or ScenarioInfo.Options.Difficulty or 1
        difficultyValuesRegister[key] = value
    end

    function Get(key)
        if difficultyValuesRegister[key] == nil then
            error(debug.traceback("Attempt to get difficulty value that doesnt exist!"))
        end
        return difficultyValuesRegister[key][difficulty]
    end
end
