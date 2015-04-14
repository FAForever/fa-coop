--- It's kind dumb that the options aren't stored like this to start with...
function getOption(byKey, optionsTable)
    for k, v in optionsTable do
        if v.key == byKey then
            return v
        end
    end
end

-- The only victory condition option needs to be "Sandbox".
local victoryOption = getOption("Victory", globalOpts)
victoryOption.default = 1
victoryOption.values = {
    {
        text = "<LOC lobui_0128>Sandbox",
        help = "<LOC lobui_0129>Game never ends",
        key = 'sandbox',
    }
}

-- The only spawn option needs to be "Fixed".
local spawnOption = getOption("TeamSpawn", teamOptions)
spawnOption.default = 1
spawnOption.values = {
    {
        text = "<LOC lobui_0092>Fixed",
        help = "<LOC lobui_0093>Spawn everyone in fixed locations (determined by slot)",
        key = 'fixed',
    },
}

-- Add the "Difficulty" option.
table.insert(globalOpts,
    {
        default = 3,
        label = "<LOC coop_001>Difficulty",
        help = "<LOC coop_002>Determines how challenging the campaign is",
        key = 'Difficulty',
        values = {
            {
                text = "<LOC coop_003>Easy",
                help = "<LOC coop_004>Fairly dull",
                key = 'easy',
            },
            {
                text = "<LOC coop_005>Medium",
                help = "<LOC coop_006>A moderate challenge",
                key = 'medium',
            },
            {
                text = "<LOC coop_007>Hard",
                help = "<LOC coop_008>You will cry",
                key = 'hard',
            }
        },
    }
)
