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

--- Campaign maps do this completely differently, defining an ACU army unit for each player and
-- spawning it with a script.
-- Having standardised the location of this definition, we can now exploit this to kinda-sorta show
-- the spawn position.
function GetStartPositions(scenario)
    local saveData = {}
    doscript('/lua/dataInit.lua', saveData)
    doscript(scenario.save, saveData)

    local armyPositions = {}
    local armiesOfInterest = GetArmies()
    for k, armyName in armiesOfInterest do
        local armyTable = saveData.Scenario.Armies[armyName]

        if armyTable['Units'].Units and armyTable['Units'].Units['CybranPlayer'].Position then
            -- Perhaps pick the right one by faction here. For now I just don't care. Such coupling.
            -- ... And they're all the same.
            local pos = armyTable['Units'].Units['CybranPlayer'].Position
            armyPositions[armyName] = {
                pos[1],
                pos[3]
            }
        else
            armyPositions[armyName] = {0, 0}
        end
    end

    return armyPositions
end
