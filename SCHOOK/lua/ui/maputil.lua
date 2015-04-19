--- Return a fixed army set for coop games. Keep the old function available as we need it at
-- launch-time.
ReallyGetArmies = GetArmies

function GetArmies(scenario)
    return {"Player", "Coop1", "Coop2", "Coop3"}
end

-- Make the map list show coop scenarios (only)
function EnumerateSkirmishScenarios(nameFilter, sortFunc)
    nameFilter = nameFilter or '*'
    sortFunc = sortFunc or DefaultScenarioSorter

    -- retrieve the map file names
    local scenFiles = DiskFindFiles('/maps', nameFilter .. '_scenario.lua')

    -- load each map in to a table and store in our data structure
    local scenarios = {}
    for index, fileName in scenFiles do
        local scen = LoadScenario(fileName)
        if scen.type == "campaign_coop" then
            table.insert(scenarios, scen)
        end
    end

    -- sort based on name
    table.sort(scenarios, function(a, b) return sortFunc(a.name, b.name) end)

    return scenarios
end
