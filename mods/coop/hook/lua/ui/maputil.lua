--- Return all players' armies. Keep the old function available as we need it at
-- launch-time.
ReallyGetArmies = GetArmies
function GetArmies(scenario)
    local retArmies = {}

    if scenario.Configurations.standard and scenario.Configurations.standard.teams then
        -- find the "FFA" team
        for index, teamConfig in scenario.Configurations.standard.teams do
            if teamConfig.name and (teamConfig.name == 'FFA') then
                for _, army in teamConfig.armies do
                    if StringStartsWith(army, "Player") then
                        table.insert(retArmies, army)
                    end
                end
            end
            break
        end
    end

    if table.getn(retArmies) == 0 then
        WARN("No starting armies defined in " .. scenario.file)
    end

    return retArmies
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

-- Campaign maps do this completely differently, defining an ACU army unit for each player and
-- spawning it with a script.
-- We search human armies for units with ACU ID which ends ..l0001 for all factions, searching all subgroups,
-- setting position of ACU as starting position.
function GetStartPositions(scenario)
    local saveData = {}
    doscript('/lua/dataInit.lua', saveData)
    doscript(scenario.save, saveData)
 
    local armyPositions = {}
    local armiesOfInterest = GetArmies(scenario)
    if table.getsize(armiesOfInterest) > 0 then
        for _,army in armiesOfInterest do
            if saveData.Scenario.MasterChain['_MASTERCHAIN_'].Markers[army] then
                pos = saveData.Scenario.MasterChain['_MASTERCHAIN_'].Markers[army].position
                -- x and z value are of interest so ignore y (index 2)
                armyPositions[army] = { pos[1], pos[3] }
            else
                WARN("No initial position marker for army " .. army .. " found in " .. scenario.save)
                armyPositions[army] = { 0, 0 }
            end
        end
    else
        WARN("No start positions defined in " .. scenario.file)
    end
    
    return armyPositions
end